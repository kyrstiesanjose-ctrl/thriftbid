<?php
/**
 * ThriftBid - BidBot floating chat widget (buyer-facing)
 *
 * Call renderBidBotWidget() once, near the end of a buyer-facing page
 * (renderFooter() in layout.php already does this for every page that
 * calls it - see the change there). Renders nothing for seller/admin
 * views.
 *
 * Talks to the BidBot FastAPI service (see /bidbot). BIDBOT_API_URL is
 * defined in includes/config.php and defaults to a same-origin path
 * ("/bidbot-api/chat") that's expected to be reverse-proxied to the
 * Python service - see bidbot/README.md for why, and for the direct
 * cross-origin alternative if proxying isn't available on your host.
 */

function renderBidBotWidget(): void {
    $role = currentUser()['role'] ?? 'buyer';
    if (in_array($role, ['seller', 'admin'], true)) return;
    ?>
<style>
#bb-launcher {
    position: fixed; right: 24px; bottom: 24px; z-index: 9999;
    width: 56px; height: 56px; border-radius: 50%;
    background: var(--clr-coral, #ff6b6b); color: #fff; border: none;
    box-shadow: 0 3px 10px rgba(0,0,0,.2); cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    transition: transform 150ms ease, background 150ms ease;
}
#bb-launcher:hover { background: var(--clr-coral-dark, #e05555); transform: scale(1.05); }
#bb-launcher .material-symbols-outlined { font-size: 26px; }

#bb-panel {
    position: fixed; right: 24px; bottom: 92px; z-index: 9999;
    width: 360px; max-width: calc(100vw - 32px); height: 520px; max-height: calc(100vh - 140px);
    background: #fff; border: 1px solid var(--clr-outline, #d8d8d8); border-radius: 10px;
    box-shadow: 0 8px 30px rgba(0,0,0,.18);
    display: none; flex-direction: column; overflow: hidden;
    font-family: 'Inter', system-ui, sans-serif;
}
#bb-panel.open { display: flex; }

.bb-header {
    padding: 14px 16px; border-bottom: 1px solid var(--clr-outline, #d8d8d8);
    display: flex; align-items: center; gap: 8px; background: #fff; flex-shrink: 0;
}
.bb-header h3 {
    font-family: 'Hanken Grotesk', sans-serif; font-weight: 800; font-size: 16px;
    color: var(--clr-text, #1a1c1c); margin: 0;
}
.bb-header .bb-close { margin-left: auto; cursor: pointer; color: var(--clr-tertiary, #6b6b6b); background: none; border: none; }

#bb-history {
    flex: 1; overflow-y: auto; padding: 16px; display: flex; flex-direction: column; gap: 14px;
    background: var(--clr-surface-low, #f9f9f9);
}
.bb-msg-wrapper { display: flex; flex-direction: column; max-width: 88%; }
.bb-user-wrapper { align-self: flex-end; align-items: flex-end; }
.bb-bot-wrapper { align-self: flex-start; align-items: flex-start; }
.bb-msg-bubble {
    padding: 10px 13px; border-radius: 8px; font-size: 13px; line-height: 1.55;
    white-space: pre-wrap; word-wrap: break-word;
}
.bb-user-msg { background: var(--clr-coral, #ff6b6b); color: #fff; border-bottom-right-radius: 2px; }
.bb-bot-msg { background: #fff; border: 1px solid var(--clr-outline, #d8d8d8); color: var(--clr-text-variant, #3d3d3d); border-bottom-left-radius: 2px; }
.bb-bot-msg a { color: var(--clr-coral, #ff6b6b); font-weight: 700; text-decoration: underline; }

.bb-input-area { padding: 12px; background: #fff; border-top: 1px solid var(--clr-outline, #d8d8d8); display: flex; gap: 8px; flex-shrink: 0; }
.bb-input {
    flex: 1; border: 1px solid var(--clr-outline, #d8d8d8); border-radius: 4px; padding: 8px 11px;
    font-size: 13px; font-family: 'Inter', sans-serif; outline: none;
}
.bb-input:focus { border-color: var(--clr-coral, #ff6b6b); box-shadow: 0 0 0 2px rgba(255,107,107,.14); }
.bb-send {
    display: inline-flex; align-items: center; justify-content: center;
    background: var(--clr-coral, #ff6b6b); color: #fff; border: none; border-radius: 9999px;
    width: 36px; height: 36px; cursor: pointer; flex-shrink: 0;
}
.bb-send:disabled { opacity: .45; cursor: not-allowed; }
.bb-typing { align-self: flex-start; font-size: 12px; color: var(--clr-tertiary, #6b6b6b); }
</style>

<button id="bb-launcher" title="Chat with BidBot" onclick="bbToggle()">
    <span class="material-symbols-outlined">smart_toy</span>
</button>

<div id="bb-panel">
    <div class="bb-header">
        <span class="material-symbols-outlined" style="color:var(--clr-coral,#ff6b6b);font-size:22px;">smart_toy</span>
        <h3>BidBot</h3>
        <button class="bb-close" onclick="bbToggle()">
            <span class="material-symbols-outlined" style="font-size:20px;">close</span>
        </button>
    </div>
    <div id="bb-history">
        <div class="bb-msg-wrapper bb-bot-wrapper">
            <div class="bb-msg-bubble bb-bot-msg">Hi! I'm BidBot. Ask me to find items, check a live auction, or convert a price to USD/KRW.</div>
        </div>
    </div>
    <div class="bb-input-area">
        <input type="text" id="bb-userInput" class="bb-input" placeholder="Search auctions or ask a question...">
        <button id="bb-sendBtn" class="bb-send" onclick="bbSendMessage()">
            <span class="material-symbols-outlined" style="font-size:16px;">send</span>
        </button>
    </div>
</div>

<script>
const BIDBOT_API_URL = <?= json_encode(defined('BIDBOT_API_URL') ? BIDBOT_API_URL : '/bidbot-api/chat') ?>;
let bbConversationHistory = [];

function bbToggle() {
    document.getElementById('bb-panel').classList.toggle('open');
}

document.getElementById('bb-userInput').addEventListener('keypress', function (e) {
    if (e.key === 'Enter') bbSendMessage();
});

function bbFormatMessage(text) {
    return text
        .replace(/\*\*(.*?)\*\*/g, '<b>$1</b>')
        .replace(/\*(.*?)\*/g, '<i>$1</i>')
        .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>');
}

async function bbSendMessage() {
    const input = document.getElementById('bb-userInput');
    const sendBtn = document.getElementById('bb-sendBtn');
    const history = document.getElementById('bb-history');
    const message = input.value.trim();
    if (!message) return;

    input.disabled = true;
    sendBtn.disabled = true;

    history.insertAdjacentHTML('beforeend', `
        <div class="bb-msg-wrapper bb-user-wrapper">
            <div class="bb-msg-bubble bb-user-msg"></div>
        </div>`);
    history.lastElementChild.querySelector('.bb-msg-bubble').textContent = message;
    input.value = '';
    history.scrollTop = history.scrollHeight;

    bbConversationHistory.push({ role: 'user', content: message });

    const loadingId = 'bb-load-' + Date.now();
    history.insertAdjacentHTML('beforeend', `<div id="${loadingId}" class="bb-typing">BidBot is typing...</div>`);
    history.scrollTop = history.scrollHeight;

    try {
        const response = await fetch(BIDBOT_API_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ messages: bbConversationHistory }),
        });
        const data = await response.json();

        bbConversationHistory = data.history || [...bbConversationHistory, { role: 'assistant', content: data.reply }];

        document.getElementById(loadingId)?.remove();
        history.insertAdjacentHTML('beforeend', `
            <div class="bb-msg-wrapper bb-bot-wrapper">
                <div class="bb-msg-bubble bb-bot-msg">${bbFormatMessage(data.reply || '')}</div>
            </div>`);
        history.scrollTop = history.scrollHeight;
    } catch (err) {
        document.getElementById(loadingId)?.remove();
        history.insertAdjacentHTML('beforeend', `
            <div class="bb-msg-wrapper bb-bot-wrapper">
                <div class="bb-msg-bubble bb-bot-msg">Sorry, I couldn't connect. Please try again in a moment.</div>
            </div>`);
    } finally {
        input.disabled = false;
        sendBtn.disabled = false;
        input.focus();
    }
}
</script>
    <?php
}
