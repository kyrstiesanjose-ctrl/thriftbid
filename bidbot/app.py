import os
import json
from datetime import datetime
from typing import List, Dict, Any

from dotenv import load_dotenv
from mysql.connector import pooling
import chromadb
from sentence_transformers import SentenceTransformer
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from groq import Groq

load_dotenv()

app = FastAPI()

ALLOWED_ORIGINS = [o.strip() for o in os.environ.get("ALLOWED_ORIGINS", "").split(",") if o.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS or ["http://localhost"],
    allow_credentials=True,
    allow_methods=["POST"],
    allow_headers=["*"],
)

client = Groq(api_key=os.environ["GROQ_API_KEY"])

embedder = SentenceTransformer("all-MiniLM-L6-v2")
chroma_client = chromadb.PersistentClient(path=os.environ.get("CHROMA_PATH", "./chroma_db"))
collection = chroma_client.get_or_create_collection("thriftbid_listings")

from db_tunnel import get_tunnel

_tunnel = get_tunnel()

db_pool = pooling.MySQLConnectionPool(
    pool_name="thriftbid_pool",
    pool_size=5,
    pool_reset_session=True,
    host="127.0.0.1",
    port=_tunnel.local_bind_port,
    user=os.environ.get("DB_USER", "root"),
    password=os.environ.get("DB_PASSWORD", ""),
    database=os.environ.get("DB_NAME", "thriftbid_db2"),
)


class ChatRequest(BaseModel):
    messages: List[Dict[str, Any]]


def serialize_message(msg):
    if isinstance(msg, dict):
        return msg
    return msg.model_dump(exclude_none=True)


def get_auction_details(listing_id: int) -> str:
    conn = None
    try:
        conn = db_pool.get_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
            SELECT l.title, a.start_bid, a.current_highest_bid, a.min_increment, a.end_time
            FROM AUCTIONS a
            JOIN LISTINGS l ON a.listing_id = l.listing_id
            WHERE l.listing_id = %s AND a.status = 'Active' AND l.deleted_at IS NULL
        """
        cursor.execute(query, (listing_id,))
        result = cursor.fetchone()

        if not result:
            return "No active auction found for that item ID in the database."

        highest = result["current_highest_bid"] or 0
        base = highest if highest > 0 else result["start_bid"]
        min_bid_to_win = base + result["min_increment"] if highest > 0 else base

        remaining = result["end_time"] - datetime.now()
        if remaining.total_seconds() <= 0:
            time_left = "auction is closing/closed"
        else:
            total_minutes = int(remaining.total_seconds() // 60)
            days, rem_minutes = divmod(total_minutes, 1440)
            hours, minutes = divmod(rem_minutes, 60)
            pieces = []
            if days:
                pieces.append(f"{days}d")
            if hours:
                pieces.append(f"{hours}h")
            pieces.append(f"{minutes}m")
            time_left = " ".join(pieces) + " remaining"

        return (
            f"Item: {result['title']}, Current Bid: PHP {highest:,.2f}, "
            f"Minimum Increment: PHP {result['min_increment']:,.2f}, "
            f"Minimum Bid to Win: PHP {min_bid_to_win:,.2f}, "
            f"Ends: {result['end_time']} ({time_left})"
        )

    except Exception as err:
        return f"Database connection error: {str(err)}"

    finally:
        if conn is not None and conn.is_connected():
            cursor.close()
            conn.close()


def search_listings(query: str, max_price: float = None, top_k: int = 3) -> str:
    try:
        query_embedding = embedder.encode([query]).tolist()

        where_clause = None
        if max_price is not None:
            where_clause = {"price": {"$lte": float(max_price)}}

        results = collection.query(
            query_embeddings=query_embedding,
            n_results=top_k,
            where=where_clause,
        )

        if not results["documents"][0]:
            return "No matching listings found."

        return "\n".join(results["documents"][0])

    except Exception as e:
        return f"Search error: {str(e)}"


def convert_item_price(listing_id: int, target_currency: str) -> str:
    conn = None
    try:
        target_currency = target_currency.upper()
        if target_currency not in ("PHP", "USD", "KRW"):
            return "Unsupported currency. I can convert to PHP, USD, or KRW."

        conn = db_pool.get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT l.title,
                   COALESCE(NULLIF(a.current_highest_bid, 0), a.start_bid, l.price) AS amount_php
            FROM LISTINGS l
            LEFT JOIN AUCTIONS a ON a.listing_id = l.listing_id AND a.status = 'Active'
            WHERE l.listing_id = %s AND l.deleted_at IS NULL
            LIMIT 1
        """,
            (listing_id,),
        )
        listing = cursor.fetchone()

        if not listing:
            return "No listing found for that item ID in the database."

        amount_php = listing["amount_php"]

        if target_currency == "PHP":
            return f"{listing['title']}: PHP {amount_php:,.2f}"

        cursor.execute(
            """
            SELECT exchange_rate
            FROM CURRENCY_RATES
            WHERE base_currency = 'PHP' AND target_currency = %s
            ORDER BY recorded_date DESC
            LIMIT 1
        """,
            (target_currency,),
        )
        rate_row = cursor.fetchone()

        if not rate_row:
            return f"No exchange rate on file for PHP to {target_currency}."

        converted = amount_php * rate_row["exchange_rate"]
        return f"{listing['title']}: PHP {amount_php:,.2f} \u2248 {target_currency} {converted:,.2f}"

    except Exception as err:
        return f"Database connection error: {str(err)}"

    finally:
        if conn is not None and conn.is_connected():
            cursor.close()
            conn.close()


TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "get_auction_details",
            "description": "Retrieves real time live bidding data and minimum increments for an auction.",
            "parameters": {
                "type": "object",
                "properties": {
                    "listing_id": {
                        "type": "integer",
                        "description": "The exact integer ID of the listing obtained from search_listings.",
                    }
                },
                "required": ["listing_id"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "search_listings",
            "description": "Semantically search listing titles and descriptions for fuzzy or descriptive queries.",
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "What the user is looking for, in natural language.",
                    },
                    "max_price": {
                        "type": "number",
                        "description": "The maximum price in PHP the user is willing to pay. Omit if no budget is specified.",
                    },
                },
                "required": ["query"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "convert_item_price",
            "description": "Converts a specific listing's current price/bid into PHP, USD, or KRW.",
            "parameters": {
                "type": "object",
                "properties": {
                    "listing_id": {
                        "type": "integer",
                        "description": "The exact integer ID of the listing to convert.",
                    },
                    "target_currency": {
                        "type": "string",
                        "enum": ["PHP", "USD", "KRW"],
                        "description": "The currency to convert into.",
                    },
                },
                "required": ["listing_id", "target_currency"],
            },
        },
    },
]

TOOL_FUNCTIONS = {
    "get_auction_details": lambda args: get_auction_details(args.get("listing_id")),
    "search_listings": lambda args: search_listings(args.get("query"), args.get("max_price")),
    "convert_item_price": lambda args: convert_item_price(args.get("listing_id"), args.get("target_currency")),
}


@app.post("/api/chat")
def chat_endpoint(req: ChatRequest):
    try:
        recent_history = req.messages[-12:]

        while recent_history and recent_history[0].get("role") == "tool":
            recent_history.pop(0)

        messages = [
            {
                "role": "system",
                "content": (
                    "You are BidBot. First use search_listings to find items and obtain their listing_id. "
                    "Then use get_auction_details or convert_item_price using that exact listing_id. "
                    "Keep answers concise and helpful.\n\n"
                    "CRITICAL RULES:\n"
                    "1. When mentioning an item, ALWAYS make its name a clickable link using Markdown: [Item Name](listing.php?id=LISTING_ID). NEVER print the ID in plain text, only use it inside the URL.\n"
                    "2. Never use Markdown tables (pipes or grids) to display search results. Always present items using clean bullet points with asterisks (*).\n"
                    "3. Do not use hyphens or dashes anywhere in your formatting or text output; use asterisks (*) or colons (:) instead.\n"
                    "4. When calling a tool, output ONLY the raw tool call payload without internal reasoning or preamble."
                ),
            }
        ]

        messages.extend(recent_history)

        for _ in range(3):
            response = client.chat.completions.create(
                model="openai/gpt-oss-20b",
                messages=messages,
                tools=TOOLS,
                tool_choice="auto",
                temperature=0.0,
                max_tokens=1024,
            )

            response_message = response.choices[0].message
            tool_calls = response_message.tool_calls

            if not tool_calls:
                messages.append(response_message)
                history_out = [serialize_message(m) for m in messages[1:]]
                return {"reply": response_message.content, "history": history_out}

            messages.append(response_message)

            for tool_call in tool_calls:
                fn_name = tool_call.function.name
                fn = TOOL_FUNCTIONS.get(fn_name)

                if fn is None:
                    result = f"Unknown tool: {fn_name}"
                else:
                    args = json.loads(tool_call.function.arguments)
                    result = fn(args)

                messages.append(
                    {
                        "tool_call_id": tool_call.id,
                        "role": "tool",
                        "name": fn_name,
                        "content": str(result),
                    }
                )

        return {
            "reply": "I am having trouble retrieving that information. Could you try asking in a slightly different way?",
            "history": req.messages,
        }

    except Exception as e:
        return {"reply": f"Groq API Error: {str(e)}", "history": req.messages}