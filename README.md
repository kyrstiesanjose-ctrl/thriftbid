# ThriftBid

![PHP](https://img.shields.io/badge/PHP-8-777BB4?logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-schema--driven-4479A1?logo=mysql&logoColor=white)
![Status](https://img.shields.io/badge/status-in--development-yellow)

An online auction/bidding marketplace for thrifted (secondhand) items. Buyers bid on time-limited auctions for listed items, sellers list and manage inventory, and admins moderate listings, verify authenticity, and handle disputes.

## Table of contents

- [Stack](#stack)
- [Directory structure](#directory-structure)
- [Core domain model](#core-domain-model)
- [Notable features](#notable-features)
- [Security](#security)
- [Getting started](#getting-started)
- [Known issues](#known-issues)

## Stack

| Layer | Details |
|---|---|
| Backend | PHP (procedural, page-per-file), PDO for MySQL access |
| Database | MySQL — 33 tables, with a lot of business logic implemented as **triggers and stored procedures** rather than in PHP |
| Frontend | Server-rendered PHP pages + a shared `includes/layout.php`, plain CSS (`public/style.css`) |
| Email | Raw-socket SMTP via Gmail (App Password), with PHPMailer and a local log file as fallbacks — used for registration and checkout OTP |
| Routing | `.htaccess` rewrites everything through `index.php`, and blocks direct access to `includes/` |

There's also a `server.js` (Express + MySQL2 + bcrypt) in the repo root. It targets a `USERS` table that doesn't exist in `schema.sql` (the real schema uses separate `ADMIN` / `SELLER` / `BUYER` tables), and none of the PHP pages call it — it looks like an earlier prototype that was superseded by the PHP app.

## Directory structure

```
includes/       Shared PHP: db.php (PDO singleton), auth.php (sessions/roles/CSRF),
                 config.php (env + DB/mail settings), currency.php (live FX rates),
                 mailer.php (OTP email), layout.php (shared header/nav/footer)
pages/
  customer/     Browsing, listing detail, live auction room, checkout, orders, cart
  seller/       Create/edit listings, active auctions, to-ship, analytics, transactions
  admin/        Dashboard, moderation, authenticity review, disputes, penalties, reports
api/            Small JSON endpoints (cart, notifications popup, logout, etc.)
schema.sql      Full DB schema: tables, triggers, stored procedures
seed.sql        Sample/seed data
uploads/        Uploaded listing images
storage/        mail_log.txt fallback email log
CBDAD/MCOV1/    An older, partially-diverged duplicate copy of the whole project
                 (see Known issues)
```

## Core domain model

Three separate user tables — `ADMIN`, `SELLER`, `BUYER` — rather than one shared `USERS` table with a role column. `auth.php` looks up login by email/username/phone across all three, since a phone number or username has to be unique *across* roles, not just within one table.

Key tables: `LISTINGS` → `AUCTIONS` → `BIDDINGS`, `ORDERS` → `PAYMENTS` → `TRANSACTIONS`, `SHIPMENTS` → `TRACKING_LOGS`, plus `DISPUTES`, `PENALTIES`, `SELLER_AWARDS`, `FRAUD_FLAGS`, `AUTHENTICATION`, `REVIEWS`, `NOTIFICATIONS`, `CART_ITEMS`, `BROWSING_HISTORY`, `CURRENCY_RATES`, `AUDIT_LOGS`, `EMAIL_OTPS` / `EMAIL_QUEUE`.

## Notable features

- **Live bidding with server-enforced rules.** `auction_room.php` deliberately does *not* re-implement bid validation in PHP — it inserts a row into `BIDDINGS` and lets DB triggers (`before_bid_validate_amount`, `after_bid_update_auction`) enforce that the auction is active and the bid clears the minimum increment, bump the current highest bid, and apply an anti-sniping extension when a bid lands in the closing seconds.
- **Multi-currency display (PHP / USD / KRW).** `currency.php` fetches live rates once a day from a free FX API, caches them in `CURRENCY_RATES`, and falls back to the most recent cached rate (or a hardcoded default) if the API is unreachable.
- **Trigger-driven order lifecycle.** Payments, shipments, and status changes cascade automatically: `after_payment_insert_create_transaction`, `after_shipment_status_change`, `after_order_status_change_notify_buyer`, `after_order_insert_deactivate_listing`, and more.
- **Trust & safety tooling for admins.** Listing authenticity verification (`AUTHENTICATION` table + `authenticity.php`), dispute handling, seller penalties with escalation (`after_penalty_insert_escalate`), fraud flags, and an append-only `AUDIT_LOGS` table for every admin action.
- **OTP-based verification.** Email OTP for registration and checkout, sent via direct SMTP to Gmail, with a `DEV_SHOW_OTP` flag to display OTPs on-screen during development instead of relying on email delivery.

## Security

- **Auth & sessions.** `auth.php` runs its own PHP session (`THRIFTBID_SESSION`, `httponly` + `SameSite=Lax` cookie) rather than PDO/DB-backed sessions. `requireLogin()` / `requireRole()` gate pages by checking `$_SESSION['auth']`.
- **SQL access.** All queries go through `DB::query()` in `db.php`, which uses PDO prepared statements with `PDO::ATTR_EMULATE_PREPARES => false` — real server-side prepares, not string interpolation.
- **Secrets.** `config.php` loads `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `SESSION_SECRET`, `SMTP_USER`, and `SMTP_PASS` from a `.env` file at the project root — **but every one of them also has a real, working credential hardcoded as the fallback default** if `.env` is missing. That means the actual DB password and the Gmail App Password used for OTP delivery are committed to this repo in plaintext.
  - ⚠️ **Action needed:** rotate the DB password and the Gmail App Password, then change each `define(...)` in `config.php` to fail loudly (e.g. `throw new RuntimeException(...)`) when the corresponding `.env` value is missing, instead of falling back to a real secret.
- **CSRF / routing.** `.htaccess` blocks direct access to `includes/` and routes everything through `index.php`.

## Getting started

**Prerequisites:** PHP 8+, MySQL access (this project connects to a shared DLSU `ccscloud` database — see `config.php`), Apache (XAMPP is what this was built against).

1. Clone the repo into your `htdocs` folder.
2. Create a `.env` file at the project root (same level as `index.php`) with at minimum:
   ```
   DB_HOST=ccscloud.dlsu.edu.ph
   DB_PORT=22003
   DB_USER=your_db_user
   DB_PASSWORD=your_db_password
   DB_NAME=thriftbid_db2
   SESSION_SECRET=generate_your_own_random_string
   SMTP_USER=your_gmail_address
   SMTP_PASS=your_gmail_app_password
   ```
3. If you're working against your own local copy of the schema instead of the shared cloud DB, import `schema.sql` then `seed.sql` into your local MySQL.
4. Visit the project through Apache (e.g. `http://localhost/thriftbid/`) — `index.php` handles routing from there.

**BidBot (the RAG chatbot widget)** is a separate FastAPI service and has its own setup (Python venv, its own `.env`, an SSH tunnel or direct connection to the DB, and an Apache reverse-proxy rule for `/bidbot-api/chat`). Currently it only exists inside the `CBDAD/MCOV1/` duplicate copy — see [Known issues](#known-issues) below.

## Known issues

- **`CBDAD/MCOV1/thriftbid/` is a full duplicate of the project root**, and the two have diverged — most notably, `bidbot/` (the FastAPI RAG chatbot backend) only exists in the duplicate, not at the repo root. Until that's reconciled, BidBot only works when running from inside `CBDAD/MCOV1/thriftbid/`, not from a plain clone of the root.
- **`server.js`** (Express + MySQL2 + bcrypt) in the repo root targets a `USERS` table that doesn't exist in `schema.sql` and isn't called by any PHP page — looks like an abandoned earlier prototype. Safe to remove once confirmed unused.
- **Hardcoded secrets in `config.php`** — see [Security](#security) above.
- **`DEV_SHOW_OTP` is currently `true`** in `config.php`, meaning OTP codes are shown on-screen instead of relying solely on email delivery. Fine for development; should be `false` before anything resembling a real deployment.
- **Port mismatch worth investigating:** `config.php` connects directly to `ccscloud.dlsu.edu.ph:22003` (no SSH tunnel), while the MySQL Workbench connection used for admin access tunnels through SSH on port `21003` to reach MySQL on `127.0.0.1:3306` from the server's side. Both apparently reach the same database, which suggests `22003` may be a direct MySQL port exposed alongside the SSH-only path — worth confirming, since it could simplify BidBot's own DB connection.
