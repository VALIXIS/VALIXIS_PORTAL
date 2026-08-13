# VALIXIS WhatsApp Notification Microservice

A self-hosted, lightweight Node.js microservice that bridges the VALIXIS internal portal with WhatsApp. It uses **whatsapp-web.js** with a persistent **LocalAuth** session so you scan a QR code **once** and the bot stays authenticated across restarts.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Runtime | Node.js ≥ 18 |
| HTTP Framework | Express.js |
| WhatsApp Engine | whatsapp-web.js |
| Session Strategy | LocalAuth (`.wwebjs_auth/`) |
| QR Renderer | qrcode-terminal |

---

## Project Structure

```
whatsapp-service/
├── server.js         ← Express server + whatsapp-web.js client
├── package.json      ← Dependencies
├── .env.example      ← Environment variable template
├── .gitignore        ← Excludes secrets & session data
└── README.md         ← This file
```

---

## Prerequisites

- **Node.js v18+** — [Download](https://nodejs.org)
- **npm v9+** — bundled with Node.js
- A **WhatsApp account** on a phone with internet access (for the one-time QR scan)
- **Chromium system dependencies** on Linux (skip on Windows/macOS):
  ```bash
  # Ubuntu / Debian
  sudo apt-get install -y \
    gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 \
    libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 \
    libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 \
    libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 \
    libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 \
    libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation \
    libappindicator1 libnss3 lsb-release xdg-utils wget
  ```

---

## Setup & First Run

### 1 — Clone / navigate to the service directory

```bash
cd whatsapp-service
```

### 2 — Install dependencies

```bash
npm install
```

> `whatsapp-web.js` will download a compatible Chromium binary automatically via Puppeteer. This may take a few minutes on first install.

### 3 — Configure environment

```bash
cp .env.example .env
# Open .env and adjust PORT if needed (default: 3001)
```

### 4 — Start the service

```bash
npm start
```

### 5 — Scan the QR code

On **first run** a QR code is printed to the terminal:

```
========================================
  VALIXIS WhatsApp Bot — Scan QR Code
========================================

█████████████████████████████
█ ▄▄▄▄▄ █▀▀▀ █▄█  █ ▄▄▄▄▄ █
...

Scan the QR code above with WhatsApp → Linked Devices → Link a Device
```

After scanning, the bot prints:

```
✅  VALIXIS WhatsApp Bot Client Ready!
    REST endpoint active → http://localhost:3001/send-task-alert
```

The session is now stored in `.wwebjs_auth/`. **Subsequent restarts will NOT require re-scanning** unless the session expires or the device is removed in WhatsApp → Linked Devices.

---

## API Reference

### `GET /status` — Health check

Returns bot readiness and server uptime.

**Response 200**
```json
{
  "service": "VALIXIS WhatsApp Bot",
  "ready": true,
  "uptime": 142
}
```

---

### `POST /send-task-alert` — Send WhatsApp notification

**Request Headers**
```
Content-Type: application/json
```

**Request Body**
```json
{
  "recipient": "91XXXXXXXXXX@c.us",
  "message": "🚨 *VALIXIS TASK ASSIGNED*\n\nDeveloper: Hasitha\nTask: Fix step tracking\nBranch: fix/hasitha/fitora-bug-07"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `recipient` | `string` | ✅ | WhatsApp ID. Individual: `91XXXXXXXXXX@c.us` (country code + number). Group: `<groupId>@g.us` |
| `message` | `string` | ✅ | Message body. Supports WhatsApp markdown (`*bold*`, `_italic_`, `~strikethrough~`). Use `\n` for newlines. |

**Response 200 — Success**
```json
{
  "success": true,
  "status": "Message sent"
}
```

**Response 400 — Validation Error**
```json
{
  "success": false,
  "error": "`recipient` is required. Format: \"91XXXXXXXXXX@c.us\" (individual) or \"<groupId>@g.us\" (group)."
}
```

**Response 503 — Bot Not Ready**
```json
{
  "success": false,
  "error": "WhatsApp client is not ready yet. Check /status and try again in a moment."
}
```

**Response 500 — Send Failure**
```json
{
  "success": false,
  "error": "Could not send message to recipient: invalid wid"
}
```

---

## Finding Your WhatsApp ID

| Scenario | ID Format | Example |
|---|---|---|
| Send to an individual | `countryCode` + `number` + `@c.us` | `919876543210@c.us` |
| Send to a group | Group internal ID + `@g.us` | `120363XXXXXXXXXX@g.us` |

To get a **group ID**, add the bot number to the group, then inspect the group object via the WhatsApp Web console, or log it from the `client.on('message', ...)` event using `msg.from`.

---

## n8n Integration

Use the **HTTP Request** node in n8n to call this service.

### Node Configuration

| Setting | Value |
|---|---|
| Method | `POST` |
| URL | `http://localhost:3001/send-task-alert` (or your server IP) |
| Authentication | None |
| Content Type | `application/json` |

### Body — Task Assignment Alert

```json
{
  "recipient": "91XXXXXXXXXX@c.us",
  "message": "🚨 *VALIXIS TASK ASSIGNED*\n\n👨‍💻 *Developer:* Hasitha\n📋 *Task:* Fix step tracking in Fitora\n🔀 *Branch:* fix/hasitha/fitora-bug-07\n📅 *Deadline:* 15 Aug 2026\n\n_Login to the VALIXIS Portal to view details._"
}
```

### Body — PR Submission Received (Manager alert)

```json
{
  "recipient": "91XXXXXXXXXX@c.us",
  "message": "📥 *NEW PR SUBMISSION*\n\n👨‍💻 *Employee:* Hasitha\n📋 *Task:* Fix step tracking\n🔗 *PR URL:* https://github.com/VALIXIS/Fitora/pull/8\n\n_Review it in the VALIXIS Manager Portal._"
}
```

### Body — Group Broadcast

```json
{
  "recipient": "120363XXXXXXXXXX@g.us",
  "message": "📢 *VALIXIS ENGINEERING UPDATE*\n\n✅ Sprint 4 has kicked off!\n\nAll tasks have been assigned. Check your VALIXIS Portal for details."
}
```

---

## Running as a Background Service (Optional)

### Using PM2 (recommended for production)

```bash
npm install -g pm2
pm2 start server.js --name valixis-whatsapp-bot
pm2 save
pm2 startup   # Auto-start on system boot
```

**Useful PM2 commands:**
```bash
pm2 status                          # View all processes
pm2 logs valixis-whatsapp-bot       # Stream logs
pm2 restart valixis-whatsapp-bot    # Restart the bot
pm2 stop valixis-whatsapp-bot       # Stop the bot
```

---

## Troubleshooting

| Issue | Fix |
|---|---|
| QR code appears on every restart | `.wwebjs_auth/` is missing or corrupted. Delete it and re-scan. |
| `Error: ENOENT` on Puppeteer launch | Run `npm install` again; Chromium binary may be incomplete. |
| `auth_failure` in logs | Session revoked via phone → Linked Devices. Delete `.wwebjs_auth/` and re-scan. |
| Bot ready but messages fail | Verify the `recipient` ID format. Individual: must include country code + `@c.us`. |
| Port 3001 already in use | Change `PORT` in `.env` to a free port (e.g. `3002`). |
| Linux: Puppeteer crashes | Install the Chromium system dependencies listed in [Prerequisites](#prerequisites). |
