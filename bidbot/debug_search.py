import os
from dotenv import load_dotenv
load_dotenv()

import chromadb
from sentence_transformers import SentenceTransformer

chroma_client = chromadb.PersistentClient(path=os.environ.get("CHROMA_PATH", "./chroma_db"))
collection = chroma_client.get_or_create_collection("thriftbid_listings")

print("Total items in collection:", collection.count())

# 1. Is listing 315 actually in there at all?
try:
    result = collection.get(ids=["315"])
    if result["ids"]:
        print("\nFOUND listing 315 in the index. Document text:")
        print(result["documents"][0])
    else:
        print("\nlisting 315 is NOT in the index at all.")
except Exception as e:
    print("\nError checking listing 315:", e)

# 2. What does the semantic search actually return for this query, unfiltered?
embedder = SentenceTransformer("all-MiniLM-L6-v2")
query = "louis vitton dark floral pants"
query_embedding = embedder.encode([query]).tolist()

results = collection.query(query_embeddings=query_embedding, n_results=10)
print(f"\nTop 10 results for query: '{query}'")
for i, (doc_id, doc, dist) in enumerate(zip(results["ids"][0], results["documents"][0], results["distances"][0])):
    marker = "  <-- listing 315" if doc_id == "315" else ""
    print(f"{i+1}. [id={doc_id}] distance={dist:.4f}{marker}")
    print(f"   {doc[:100]}")