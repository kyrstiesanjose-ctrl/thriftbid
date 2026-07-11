// ============================================================
// ThriftBid - Backend Server (Node.js / Express)  [FIXED]
// Fixes:
//   1. /profile route renamed to /api/profile (matches frontend)
//   2. Added GET /logout (profile.html uses <a href="/logout">)
//   3. Keep-alive pool settings retained
// ============================================================
require('dotenv').config();

const express = require('express');
const bcrypt  = require('bcrypt');
const session = require('express-session');
const mysql   = require('mysql2/promise');
const path    = require('path');

const app  = express();
const PORT = process.env.PORT || 3000;

// ── Database Connection Pool ──────────────────────────────
const db = mysql.createPool({
    host    : process.env.DB_HOST,
    port    : process.env.DB_PORT    || 3306,
    user    : process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections     : true,
    connectionLimit        : 10,
    enableKeepAlive        : true,
    keepAliveInitialDelay  : 10000,
});

// ── Middleware ────────────────────────────────────────────
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files from the same folder as server.js
app.use(express.static(path.join(__dirname, 'public')));
app.use(session({
    secret           : process.env.SESSION_SECRET || 'thriftbid_secret',
    resave           : false,
    saveUninitialized: false,
    cookie           : { secure: false, maxAge: 1000 * 60 * 60 * 24 }, // 24h
}));

// ── Auth Guard Middleware ─────────────────────────────────
function requireLogin(req, res, next) {
    if (req.session && req.session.user) return next();
    return res.status(401).json({ success: false, message: 'Unauthorized. Please log in.' });
}

// ── POST /register ────────────────────────────────────────
app.post('/register', async (req, res) => {
    try {
        const { username, email, password, phone_number, address } = req.body;

        if (!username || !email || !password) {
            return res.status(400).json({ success: false, message: 'Missing required fields.' });
        }

        const [existing] = await db.execute(
            'SELECT user_id FROM USERS WHERE email = ? OR username = ?',
            [email, username]
        );
        if (existing.length > 0) {
            return res.status(400).json({ success: false, message: 'Username or Email already taken.' });
        }

        const hashedPw = await bcrypt.hash(password, 10);

        const [result] = await db.execute(
            'INSERT INTO USERS (username, password_hash, email, phone_number, address, role) VALUES (?, ?, ?, ?, ?, ?)',
            [username, hashedPw, email, phone_number || null, address || null, 'buyer']
        );

        // Create matching BUYER profile row
        await db.execute('INSERT INTO BUYER (user_id, shipping_address) VALUES (?, ?)', [result.insertId, address || null]);

        return res.json({ success: true, message: 'Registration successful!' });
    } catch (err) {
        console.error('Registration error:', err);
        return res.status(500).json({ success: false, message: 'Server error during registration.' });
    }
});

// ── POST /login ───────────────────────────────────────────
app.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ success: false, message: 'Email and password required.' });
        }

        const [rows] = await db.execute('SELECT * FROM USERS WHERE email = ?', [email]);
        if (rows.length === 0) {
            return res.status(401).json({ success: false, message: 'Invalid email or password.' });
        }

        const user  = rows[0];
        const match = await bcrypt.compare(password, user.password_hash);
        if (!match) {
            return res.status(401).json({ success: false, message: 'Invalid email or password.' });
        }

        req.session.user = {
            user_id    : user.user_id,
            username   : user.username,
            email      : user.email,
            role       : user.role,
            is_verified: user.is_verified,
        };

        return res.json({ success: true, message: 'Logged in successfully.' });
    } catch (err) {
        console.error('Login error:', err);
        return res.status(500).json({ success: false, message: 'Server error.' });
    }
});

// ── POST /logout  (called via fetch from JS) ──────────────
app.post('/logout', (req, res) => {
    req.session.destroy(err => {
        if (err) return res.status(500).json({ success: false, message: 'Logout failed.' });
        res.clearCookie('connect.sid');
        return res.json({ success: true, message: 'Logged out successfully.' });
    });
});

// ── GET /logout  (called via <a href="/logout"> link) ─────
app.get('/logout', (req, res) => {
    req.session.destroy(() => {
        res.clearCookie('connect.sid');
        res.redirect('/login.html');
    });
});

// ── GET /api/profile  (FIXED — was /profile, mismatched frontend) ──
app.get('/api/profile', requireLogin, async (req, res) => {
    try {
        const [rows] = await db.execute(
            'SELECT username, email, phone_number, address, role, is_verified FROM USERS WHERE user_id = ?',
            [req.session.user.user_id]
        );
        if (rows.length === 0) return res.status(404).json({ success: false, message: 'User not found.' });
        return res.json({ success: true, user: rows[0] });
    } catch (err) {
        console.error('Profile fetch error:', err);
        return res.status(500).json({ success: false, message: 'Server error.' });
    }
});

// ── POST /profile/update ─────────────────────────────────
app.post('/profile/update', requireLogin, async (req, res) => {
    try {
        const { username, phone_number, address } = req.body;
        const user_id = req.session.user.user_id;

        if (!username) return res.status(400).json({ success: false, message: 'Username cannot be empty.' });

        await db.execute(
            'UPDATE USERS SET username = ?, phone_number = ?, address = ? WHERE user_id = ?',
            [username, phone_number || null, address || null, user_id]
        );

        req.session.user.username = username;
        return res.json({ success: true, message: 'Profile updated successfully!' });
    } catch (err) {
        console.error('Profile update error:', err);
        return res.status(500).json({ success: false, message: 'Server error.' });
    }
});

// ── GET /api/session-user ─────────────────────────────────
app.get('/api/session-user', requireLogin, (req, res) => {
    res.json({ success: true, user: req.session.user });
});

// ── Start Server ──────────────────────────────────────────
app.listen(PORT, () => {
    console.log(`\n✅ ThriftBid server running at http://localhost:${PORT}`);
    console.log(`📡 DB: ${process.env.DB_HOST}:${process.env.DB_PORT || 3306} / ${process.env.DB_NAME}\n`);
});