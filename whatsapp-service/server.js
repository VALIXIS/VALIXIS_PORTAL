'use strict';

/**
 * VALIXIS WhatsApp Notification Microservice
 *
 * A self-hosted Express.js server powered by whatsapp-web.js (LocalAuth strategy).
 * Scan the QR code once — the session is persisted in `.wwebjs_auth/` so subsequent
 * restarts authenticate automatically without re-scanning.
 *
 * Exposes:
 *   POST /send-task-alert  — Send a WhatsApp message to a developer or group chat.
 *   GET  /status           — Health-check and client readiness probe.
 *
 * Usage:
 *   node server.js
 *
 * Environment variables (copy .env.example → .env to configure):
 *   PORT   — TCP port to listen on (default: 3001)
 */

// ─── Dependencies ────────────────────────────────────────────────────────────

require('dotenv').config();                              // Load .env before anything else

const express       = require('express');
const { Client, LocalAuth, MessageMedia } = require('whatsapp-web.js');
const qrcodeTerminal = require('qrcode-terminal');

// ─── Configuration ───────────────────────────────────────────────────────────

const PORT         = parseInt(process.env.PORT || '3001', 10);
const AUTH_DIR     = './.wwebjs_auth';                   // Persistent session data directory

// ─── Express Application ─────────────────────────────────────────────────────

const app = express();

app.use(express.json());                                 // Parse incoming JSON bodies

// ─── WhatsApp Client ─────────────────────────────────────────────────────────

/**
 * Global flag to track whether the whatsapp-web.js client has authenticated
 * and is ready to send messages. Requests arriving before `ready` are rejected
 * with HTTP 503.
 */
let isClientReady = false;

/**
 * Resolves the path to an installed Chrome / Chromium executable.
 *
 * Resolution order:
 *  1. CHROME_PATH env variable (explicit override)
 *  2. Well-known Windows locations (Program Files 64-bit / 32-bit)
 *  3. macOS application bundle
 *  4. Common Linux Chromium paths
 *  5. undefined — let puppeteer-core use its own downloaded binary (if present)
 */
function resolveChromePath() {
  const { existsSync } = require('fs');

  if (process.env.CHROME_PATH && existsSync(process.env.CHROME_PATH)) {
    return process.env.CHROME_PATH;
  }

  const candidates = [
    // Windows — 64-bit Chrome
    'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    // Windows — 32-bit Chrome
    'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
    // macOS
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    // Linux Chrome
    '/usr/bin/google-chrome',
    '/usr/bin/google-chrome-stable',
    // Linux Chromium
    '/usr/bin/chromium-browser',
    '/usr/bin/chromium',
  ];

  for (const candidate of candidates) {
    if (existsSync(candidate)) {
      return candidate;
    }
  }

  return undefined; // fallback: let puppeteer-core decide
}

const chromePath = resolveChromePath();

if (chromePath) {
  console.log(`  Browser      → ${chromePath}`);
} else {
  console.log('  Browser      → puppeteer-core managed (run: npx puppeteer browsers install chrome if this fails)');
}

/**
 * whatsapp-web.js Client instance.
 *
 * LocalAuth — persists the Chromium session to AUTH_DIR so QR scanning is a
 * one-time setup step. On subsequent restarts the stored credentials are
 * replayed automatically.
 *
 * executablePath — points to the system Chrome installation discovered above,
 * bypassing the need for puppeteer-core to download its own binary.
 *
 * Puppeteer args — `--no-sandbox` and `--disable-setuid-sandbox` are required
 * for Linux servers and WSL environments where sandboxing is unsupported.
 */
const client = new Client({
  authStrategy: new LocalAuth({ dataPath: AUTH_DIR }),
  puppeteer: {
    headless: true,
    ...(chromePath ? { executablePath: chromePath } : {}),
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-accelerated-2d-canvas',
      '--no-first-run',
      '--no-zygote',
      '--disable-gpu',
      '--disable-software-rasterizer',
      '--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
      '--disable-features=IsolateOrigins,site-per-process',
    ],
  },
});

// ─── WhatsApp Lifecycle Events ────────────────────────────────────────────────

/**
 * `qr` — Fired when authentication is required.
 *
 * Renders the QR code directly in the terminal. Scan with the WhatsApp app:
 *   Settings → Linked Devices → Link a Device → point camera at QR below.
 *
 * After scanning, the session is stored in AUTH_DIR and this event will NOT
 * fire on future restarts (unless the session expires or is revoked).
 */
client.on('qr', (qr) => {
  console.log('\n========================================');
  console.log('  VALIXIS WhatsApp Bot — Scan QR Code  ');
  console.log('========================================\n');
  qrcodeTerminal.generate(qr, { small: true });
  console.log('\nScan the QR code above with WhatsApp → Linked Devices → Link a Device');
  console.log('Waiting for scan...\n');
});

/**
 * `ready` — Fired once the client is fully authenticated and connected.
 * From this point forward the `/send-task-alert` endpoint becomes operational.
 */
client.on('ready', () => {
  isClientReady = true;
  console.log('✅  VALIXIS WhatsApp Bot Client Ready!');
  console.log(`    REST endpoint active → http://localhost:${PORT}/send-task-alert\n`);
});

/**
 * `authenticated` — Session credentials were successfully loaded / replayed.
 */
client.on('authenticated', () => {
  console.log('🔐  WhatsApp session authenticated successfully.');
});

/**
 * `auth_failure` — Credentials could not be validated (session corrupted or revoked).
 * Delete the AUTH_DIR folder and restart to re-scan a fresh QR code.
 */
client.on('auth_failure', (message) => {
  isClientReady = false;
  console.error(`❌  WhatsApp authentication failure: ${message}`);
  console.error(`    → Delete "${AUTH_DIR}" and restart to re-authenticate.\n`);
});

/**
 * `disconnected` — Client lost its WhatsApp connection.
 * `reason` contains a WAState string (e.g. CONFLICT, UNPAIRED, LOGOUT).
 */
client.on('disconnected', (reason) => {
  isClientReady = false;
  console.warn(`⚠️   WhatsApp client disconnected. Reason: ${reason}`);
  console.warn('    Attempting to reinitialize…\n');

  // Attempt automatic re-initialization so the service self-heals without
  // a manual restart (e.g. after a transient network interruption).
  client.initialize().catch((err) => {
    console.error('    Reinitialization failed:', err.message);
  });
});

// ─── REST Endpoints ───────────────────────────────────────────────────────────

/**
 * GET /status
 *
 * Simple health-check used by n8n, monitoring tools, or a process manager
 * to determine whether the bot is alive and ready to dispatch messages.
 *
 * Response 200:
 *   { "service": "VALIXIS WhatsApp Bot", "ready": true|false, "uptime": <seconds> }
 */
app.get('/status', (_req, res) => {
  res.status(200).json({
    service : 'VALIXIS WhatsApp Bot',
    ready   : isClientReady,
    uptime  : Math.floor(process.uptime()),
  });
});

/**
 * POST /send-task-alert
 *
 * Dispatches a WhatsApp message to an individual developer or a group chat
 * on behalf of the VALIXIS portal automated workflow.
 *
 * Expected JSON body:
 * {
 *   "recipient": "91XXXXXXXXXX@c.us",   // Individual: countryCode + number @c.us
 *                                        // Group:      groupId            @g.us
 *   "message":   "🚨 *VALIXIS TASK ASSIGNED*\n\nDeveloper: Hasitha\nTask: ..."
 * }
 *
 * Success  → 200 { success: true,  status: "Message sent" }
 * Invalid  → 400 { success: false, error:  "..." }
 * Not ready→ 503 { success: false, error:  "WhatsApp client is not ready yet." }
 * Failure  → 500 { success: false, error:  "<underlying error message>" }
 */
app.post('/send-task-alert', async (req, res) => {
  const { recipient, message, file } = req.body;

  // ── Validation ────────────────────────────────────────────────────────────

  if (!recipient || typeof recipient !== 'string' || recipient.trim() === '') {
    return res.status(400).json({
      success : false,
      error   : '`recipient` is required. Format: "91XXXXXXXXXX@c.us" (individual) or "<groupId>@g.us" (group).',
    });
  }

  if (!message || typeof message !== 'string' || message.trim() === '') {
    return res.status(400).json({
      success : false,
      error   : '`message` is required and must be a non-empty string.',
    });
  }

  // ── Readiness Guard ───────────────────────────────────────────────────────

  if (!isClientReady) {
    return res.status(503).json({
      success : false,
      error   : 'WhatsApp client is not ready yet. Check /status and try again in a moment.',
    });
  }

  // ── Send Message ──────────────────────────────────────────────────────────

  const sanitizedRecipient = recipient.trim();
  const sanitizedMessage   = message.trim();

  console.log(`📤  Sending WhatsApp alert → ${sanitizedRecipient} (Has file: ${!!file})`);

  try {
    if (file && file.mimetype && file.base64) {
      const filename = file.filename || 'file';
      const media = new MessageMedia(file.mimetype, file.base64, filename);
      await client.sendMessage(sanitizedRecipient, media, { caption: sanitizedMessage });
    } else {
      await client.sendMessage(sanitizedRecipient, sanitizedMessage);
    }

    console.log(`    ✅ Message delivered to ${sanitizedRecipient}`);

    return res.status(200).json({
      success : true,
      status  : 'Message sent',
    });

  } catch (err) {
    console.error(`    ❌ Failed to send message to ${sanitizedRecipient}:`, err.message);

    return res.status(500).json({
      success : false,
      error   : err.message || 'Unknown error while sending WhatsApp message.',
    });
  }
});

// ─── Supabase Webhook Receiver ───────────────────────────────────────────────

/**
 * POST /supabase-webhook
 *
 * Receives a Supabase Database Webhook (INSERT/UPDATE on the `tasks` or
 * `task_assignments` table) and immediately dispatches a WhatsApp task-assignment
 * alert to the relevant developer — no n8n or third-party middleware needed.
 *
 * Supabase sends webhooks in the shape:
 * {
 *   "type": "INSERT",
 *   "table": "task_assignments",
 *   "record": { "title": "...", "assigned_to": "...", "branch_name": "...", "phone": "..." },
 *   "old_record": null,
 *   "schema": "public"
 * }
 *
 * Recipient resolution order:
 *  1. `record.phone` stripped of non-digits, suffixed with `@c.us`
 *  2. Hardcoded fallback number (WEBHOOK_RECIPIENT env var or 919603416707)
 *
 * Success  → 200 { success: true,  status: "Task alert dispatched" }
 * Not ready→ 503 { success: false, error:  "WhatsApp client is not ready yet." }
 * Failure  → 500 { success: false, error:  "<underlying error>" }
 */
app.post('/supabase-webhook', async (req, res) => {
  // ── Readiness Guard ──────────────────────────────────────────────────────
  if (!isClientReady) {
    console.warn('⚠️   /supabase-webhook hit before client ready — rejecting.');
    return res.status(503).json({
      success : false,
      error   : 'WhatsApp client is not ready yet. Try again in a moment.',
    });
  }

  try {
    // ── Extract Supabase payload ───────────────────────────────────────────
    //
    // Supabase wraps the row data in `req.body.record` for table webhooks.
    // Fall back to the root body in case the webhook format differs.
    const record = req.body?.record ?? req.body ?? {};

    const title       = record.title        || record.name         || 'Untitled Task';
    const assignedTo  = record.assigned_to  || record.employee     || record.developer || 'Team Member';
    const branchName  = record.branch_name  || record.feature_branch || record.branch  || 'Not specified';

    // ── Recipient Resolution ───────────────────────────────────────────────
    //
    // Priority:
    //  1. `record.phone` — employee phone stored in the DB row (digits only + @c.us)
    //  2. WEBHOOK_RECIPIENT env variable — set per-deployment in .env
    //  3. Hard-coded fallback (Engineering manager / default alert number)
    const FALLBACK_NUMBER = process.env.WEBHOOK_RECIPIENT || '919603416707@c.us';

    let recipientJid;

    if (record.phone) {
      // Strip everything except digits, then append @c.us
      const digits = String(record.phone).replace(/\D/g, '');
      recipientJid = `${digits}@c.us`;
    } else {
      recipientJid = FALLBACK_NUMBER;
    }

    // ── JID Verification ──────────────────────────────────────────────────
    //
    // `client.getNumberId()` resolves the WhatsApp internal ID for the number.
    // It returns null if the number is not registered on WhatsApp, which allows
    // us to fail fast with a clear error rather than silently dropping the message.
    const numberPrefix = recipientJid.replace('@c.us', '').replace('@g.us', '');
    const verifiedId   = await client.getNumberId(numberPrefix);

    if (!verifiedId && !recipientJid.endsWith('@g.us')) {
      const errMsg = `Recipient ${recipientJid} is not a registered WhatsApp number.`;
      console.error(`    ❌ ${errMsg}`);
      return res.status(422).json({ success: false, error: errMsg });
    }

    // Use the verified JID if available, otherwise trust the original value
    // (group JIDs are not resolvable via getNumberId — they are used as-is).
    const finalRecipient = verifiedId ? verifiedId._serialized : recipientJid;

    // ── Format Alert Message ──────────────────────────────────────────────
    const message = [
      '🚨 *VALIXIS TASK ASSIGNED*',
      '',
      `*Task:* ${title}`,
      `*Assigned To:* ${assignedTo}`,
      `*Branch:* ${branchName}`,
      '',
      'Please pull your branch, complete the implementation, and submit your PR URL in the VALIXIS Portal.',
    ].join('\n');

    // ── Dispatch ──────────────────────────────────────────────────────────
    console.log(`📤  Supabase webhook → dispatching task alert to ${finalRecipient}`);
    console.log(`    Task: "${title}" | Assigned: ${assignedTo} | Branch: ${branchName}`);

    await client.sendMessage(finalRecipient, message);

    console.log(`    ✅ Task alert delivered to ${finalRecipient}`);

    return res.status(200).json({
      success   : true,
      status    : 'Task alert dispatched',
      recipient : finalRecipient,
      task      : title,
    });

  } catch (err) {
    console.error('    ❌ /supabase-webhook handler error:', err.message);
    return res.status(500).json({
      success : false,
      error   : err.message || 'Unknown error while processing webhook.',
    });
  }
});

// ─── 404 Fallback ─────────────────────────────────────────────────────────────

app.use((_req, res) => {
  res.status(404).json({ error: 'Not Found. Available endpoints: POST /send-task-alert, POST /supabase-webhook, GET /status' });
});

// ─── Boot Sequence ────────────────────────────────────────────────────────────

/**
 * 1. Start the Express HTTP server.
 * 2. Initialize the whatsapp-web.js client (launches a headless Chromium instance).
 *    If a valid session exists in AUTH_DIR, authentication is silent and automatic.
 *    Otherwise a QR code is printed to the terminal.
 */
app.listen(PORT, () => {
  console.log('');
  console.log('╔═══════════════════════════════════════════════╗');
  console.log('║       VALIXIS WhatsApp Notification Bot       ║');
  console.log('╚═══════════════════════════════════════════════╝');
  console.log(`  HTTP Server  → http://localhost:${PORT}`);
  console.log(`  Auth Store   → ${AUTH_DIR}`);
  console.log('');
  console.log('  Initializing WhatsApp client…');
  console.log('  (First run: a QR code will appear below. Scan once to authenticate.)');
  console.log('');
});

// Initialize whatsapp-web.js — fires `qr` or `authenticated` then `ready`
client.initialize();
