import os

from dotenv import load_dotenv
import mysql.connector
import chromadb
from sentence_transformers import SentenceTransformer

load_dotenv()

from db_tunnel import get_db_port
from indexing import BULK_LISTING_QUERY, listing_to_document, listing_to_metadata

embedder = SentenceTransformer("all-MiniLM-L6-v2")
chroma_client = chromadb.PersistentClient(path=os.environ.get("CHROMA_PATH", "./chroma_db"))
collection = chroma_client.get_or_create_collection("thriftbid_listings")


def build_index():
    conn = mysql.connector.connect(
        host="127.0.0.1",
        port=get_db_port(),
        user=os.environ.get("DB_USER", "root"),
        password=os.environ.get("DB_PASSWORD", ""),
        database=os.environ.get("DB_NAME", "thriftbid_db2"),
    )
    cursor = conn.cursor(dictionary=True)
    cursor.execute(BULK_LISTING_QUERY)
    rows = cursor.fetchall()
    conn.close()

    if not rows:
        print("No listings found. Check your DB connection/table name.")
        return

    docs = [listing_to_document(r) for r in rows]
    ids = [str(r["listing_id"]) for r in rows]
    metadatas = [listing_to_metadata(r) for r in rows]

    embeddings = embedder.encode(docs).tolist()
    collection.upsert(documents=docs, embeddings=embeddings, ids=ids, metadatas=metadatas)
    print(f"Indexed {len(docs)} listings.")


if __name__ == "__main__":
    build_index()