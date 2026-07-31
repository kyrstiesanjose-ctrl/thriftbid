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

Re-run `build_index.py` whenever listings change meaningfully (new items, edited descriptions). It's not wired to run automatically yet — a simple next step is a cron job or a trigger-driven queue, mirroring how `EMAIL_QUEUE` is flushed on each page load.

## Wiring it to the PHP app: same-origin proxy vs. direct call

The widget (`includes/bidbot_widget.php`) posts to `BIDBOT_API_URL`, defined in `includes/config.php`. Two ways to point it at this service:

**Option A — reverse proxy (recommended).** Apache forwards `/bidbot-api/*` to `http://127.0.0.1:8000/api/*` on the same server, so the browser only ever talks to your one domain — no CORS, and the FastAPI port never needs to be exposed publicly. Requires `mod_proxy` + `mod_proxy_http`:

```apache
ProxyPass /bidbot-api/ http://127.0.0.1:8000/api/
ProxyPassReverse /bidbot-api/ http://127.0.0.1:8000/api/
```

Leave `BIDBOT_API_URL` unset (default `/bidbot-api/chat`) when using this.

**Option B — direct cross-origin call.** If you can't enable Apache modules on your host (e.g. shared/managed hosting), set `BIDBOT_API_URL` in the PHP app's `.env` to the service's full public URL (`http://your-host:8000/api/chat`), and set `ALLOWED_ORIGINS` in `bidbot/.env` to your site's real origin. Simpler to set up, but exposes the Python service's port directly and needs CORS kept in sync with your domain.

## Notes on what changed from the original prototype

- `sandbox_api.py` → `app.py`, `sandbox_ui.html`'s markup → `includes/bidbot_widget.php`. All config (Groq key, DB credentials, CORS origins) moved out of source and into `.env` — the original had a live Groq key and `root`/no-password local DB creds hardcoded.
- CORS went from `allow_origins=["*"]` to an explicit allow-list, since `*` plus `allow_credentials=True` is a combination most browsers won't even honor, and it's unnecessarily permissive regardless.
- The chat UI changed from a standalone full-page demo into a floating launcher + panel (`includes/bidbot_widget.php`), mounted automatically on every buyer-facing page via `renderFooter()` in `layout.php`, hidden for seller/admin views.
