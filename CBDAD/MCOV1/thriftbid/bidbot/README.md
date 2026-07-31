# BidBot

RAG + function-calling chat concierge for ThriftBid's buyer side. A FastAPI service, separate from the PHP app, that:

- **Semantic search** — embeds listing title/description/color/material/origin with `all-MiniLM-L6-v2` and does vector search over a Chroma index (`build_index.py` builds it from `LISTINGS`/`CATEGORIES`/`BRANDS`).
- **Live auction lookups** — function-calls into `AUCTIONS`/`BIDDINGS` for current bid, min increment, and time remaining.
- **Multi-currency conversion** — reads `CURRENCY_RATES` (the same table `includes/currency.php` populates) to quote PHP/USD/KRW.

The LLM (Groq, `openai/gpt-oss-20b`) only ever gets tool *results* back from these functions — it never gets raw DB access itself.

## Why this is a separate service, not more PHP

The embedding model, Chroma, and the RAG/tool-calling loop are Python. There's no clean way to run that inside PHP-FPM/Apache, so it runs as its own long-lived process and the PHP app talks to it over HTTP — same pattern as `api/*.php` being small JSON endpoints the frontend JS calls, just on the other side of a language boundary.

## Setup

```bash
cd bidbot
python -m venv venv && source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env   # fill in GROQ_API_KEY and DB_* (same values as the app's own .env)
python build_index.py  # builds/refreshes the Chroma index from current listings
uvicorn app:app --host 0.0.0.0 --port 8000
```
