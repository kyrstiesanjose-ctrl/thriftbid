# BidBot

RAG + function-calling chat concierge for ThriftBid's buyer side. A FastAPI service, separate from the PHP app, that:

- **Semantic search** — embeds listing title/description/color/material/origin with `all-MiniLM-L6-v2` and does vector search over a Chroma index (`build_index.py` builds it from `LISTINGS` / `CATEGORIES` / `BRANDS`).
- **Live auction lookups** — function-calls into `AUCTIONS` / `BIDDINGS` for current bid, min increment, and time remaining.
- **Multi-currency conversion** — reads `CURRENCY_RATES` (the same table `includes/currency.php` populates) to quote PHP/USD/KRW.

The LLM (Groq, `openai/gpt-oss-20b`) only ever gets tool *results* back from these functions — it never gets raw DB access itself.

## Why this is a separate service, not more PHP

The embedding model, Chroma, and the RAG/tool-calling loop are Python. There's no clean way to run that inside PHP-FPM/Apache, so it runs as its own long-lived process and the PHP app talks to it over HTTP — same pattern as `api/*.php` being small JSON endpoints the frontend JS calls, just on the other side of a language boundary.

## Setup

```bash
cd bidbot
python -m venv venv && source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env    # fill in GROQ_API_KEY and DB_* (same values as the app's own .env)
python build_index.py   # builds/refreshes the Chroma index from current listings
uvicorn app:app --host 0.0.0.0 --port 8000
```

## 🤖 Connecting to the Bidbot Chatbot (Deployed Instance)

The chatbot backend runs persistently on our DLSU cloud server. Since port 8000 isn't publicly forwarded yet, you'll need to open an SSH tunnel to reach it locally instead of running your own instance.

### 1. Open the SSH tunnel

Open PowerShell and run:

```powershell
ssh -p 21003 -L 8000:localhost:8000 kyrstie@ccscloud.dlsu.edu.ph
```

Enter the password when prompted (@Dlsu1234!t).

> ⚠️ **Keep this window open** the whole time you're using the chatbot. Closing it or pressing `Ctrl+C` disconnects the tunnel and breaks the connection.

### 2. Set up your local `.env`

In your local copy of the project, create or edit:

BIDBOT_API_URL=http://localhost:8000/api/chat
BIDBOT_REINDEX_URL=http://localhost:8000/api/reindex-listing
BIDBOT_INTERNAL_KEY=<thriftbid_api_key>

### 3. Restart Apache

Open XAMPP Control Panel → **Stop** Apache → **Start** Apache again.

### 4. Test it

Open the ThriftBid site locally, hard-refresh (`Ctrl+Shift+R`), and try the chat.

### Troubleshooting

| Issue | Fix |
|---|---|
| "Couldn't connect" error in chat | Check your SSH tunnel window is still open and connected |
| Chat still fails after tunnel is open | Verify `BIDBOT_INTERNAL_KEY` matches exactly (no extra spaces) |
| Nothing loads at all | Make sure your own local XAMPP + project files are running — the tunnel doesn't replace this |
