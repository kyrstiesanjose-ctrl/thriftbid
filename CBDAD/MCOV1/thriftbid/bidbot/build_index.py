import os

from dotenv import load_dotenv
import mysql.connector
import chromadb
from sentence_transformers import SentenceTransformer

load_dotenv()

embedder = SentenceTransformer("all-MiniLM-L6-v2")
chroma_client = chromadb.PersistentClient(path=os.environ.get("CHROMA_PATH", "./chroma_db"))
collection = chroma_client.get_or_create_collection("thriftbid_listings")


def build_index():
    conn = mysql.connector.connect(
        host=os.environ.get("DB_HOST", "127.0.0.1"),
        port=int(os.environ.get("DB_PORT", 3306)),
        user=os.environ.get("DB_USER", "root"),
        password=os.environ.get("DB_PASSWORD", ""),
        database=os.environ.get("DB_NAME", "thriftbid_db2"),
    )
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        """
        SELECT
            l.listing_id, l.title, l.description, l.price,
            l.color, l.material, l.made_in,
            c.name AS category_name,
            b.brand_name
        FROM LISTINGS l
        JOIN CATEGORIES c ON l.category_id = c.category_id
        JOIN PRODUCT_LINES pl ON l.product_line_id = pl.product_line_id
        JOIN BRANDS b ON pl.brand_id = b.brand_id
        WHERE l.deleted_at IS NULL AND l.is_active = 1
    """
    )
    rows = cursor.fetchall()
    conn.close()

    if not rows:
        print("No listings found. Check your DB connection/table name.")
        return

    docs, ids, metadatas = [], [], []
    for r in rows:
        parts = [
            f"[ID: {r['listing_id']}] {r['title']} ({r['category_name']}, {r['brand_name']}): {r['description'] or ''} Price: PHP {r['price']}"
        ]
        if r["color"]:
            parts.append(f"Color: {r['color']}.")
        if r["material"]:
            parts.append(f"Material: {r['material']}.")
        if r["made_in"]:
            parts.append(f"Made in {r['made_in']}.")

        docs.append(" ".join(parts))
        ids.append(str(r["listing_id"]))
        metadatas.append(
            {
                "title": r["title"],
                "category": r["category_name"],
                "brand": r["brand_name"],
                "color": r["color"] or "",
                "made_in": r["made_in"] or "",
                "price": float(r["price"]),
            }
        )

    embeddings = embedder.encode(docs).tolist()
    collection.upsert(documents=docs, embeddings=embeddings, ids=ids, metadatas=metadatas)
    print(f"Indexed {len(docs)} listings.")


if __name__ == "__main__":
    build_index()
