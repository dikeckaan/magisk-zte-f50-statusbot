# statusbot — Telegram Status Bot for Android (Magisk)

A small Telegram bot that runs on a rooted Android device (designed for ZTE F50 / similar MiFi/UFI portable WiFi devices, but works on any Magisk-capable arm64 Android). It greets you on boot, lets you query the device, and run commands — all from chat.

Pure shell + curl + jq. ~50 KB module. No persistent network listeners; long-polls Telegram over HTTPS.

## Features

### 📊 Status & system
- `/status` — one-screen summary (uptime, RAM, disk, temp, perf mode, operator, signal, public IP)
- `/uptime`, `/load`, `/mem`, `/disk`, `/temp`, `/ps`
- `/modules` — list Magisk modules (with enabled/disabled state)
- `/version` — bot + device info

### 🌐 Network
- `/ip` — public IP + every local interface labeled (📱 Cellular / 📡 WiFi Hotspot / 🔒 VPN) with the default-route interface marked
- `/traffic` — cumulative RX/TX since boot per interface
- `/ping <host>`
- `/clients` — ARP / neighbor table
- `/tunnel` — Cloudflared tunnel status (only alerts/reports when the `cloudflared-tunnel` module is installed)
- `/region [CC|list|off]` — WiFi regulatory region / country code via the `hotspot-region` module (default TR; runtime `cmd wifi force-country-code`, no file edits)
- `/ssh [<public-key>|list|clear]` — manage `dropbear-ssh` authorized keys. Paste a public key to authorize it (effective immediately). On `/install_module dropbear-ssh` with no key provided, a client keypair is auto-generated and the private key is sent to you.

### 📡 Cellular (uses `sendat` from bin-utils — UFI-TOOLS not required)
- `/signal` — RSSI / RSRP / RSRQ with labeled quality (🟢/🟡/🟠/🔴)
- `/cellinfo` — operator + network type + phone number + IMEI + ICCID
- `/imei` — IMEI(s) per slot
- `/qos` — band info (`AT+CGEQOSRDP`)
- `/sms_list [N]` — read SMS via Android content provider
- `/sms_count`
- `/operator`
- `/at <command>` — run any AT command directly

### 🔐 IMEI tools
- `/imei_sorgula [imei]` — IMEI structural analysis (Luhn + TAC/SNR) and an e-Devlet (Türkiye gov) lookup. e-Devlet has a captcha, so the bot fetches it, sends the image to you, you type the 5 characters back, and the bot completes the query.
- `/imei_degis <new_imei>` — change device IMEI via `AT+SPIMEI` (Unisoc-specific). Two-step confirmation, auto-reboots.

### ⚡ ZTE-specific (works on F50 and similar ZTE routers)
- `/performance [on|off|status]` — toggle ZTE's Performance Mode via the device's internal goform API (LD/AD authenticated flow). On change, posts an inline **🔁 Restart** button so you can apply it immediately.
- `/zte_setpw <password>` — store the ZTE admin web-UI password once

### 🛠 System
- `/reboot` — two-step confirmation
- `/komut <shell-command>` — run any shell command, get the output back. Comes with an inline **❌ İptal** button while it's running so you can kill long-running tasks. Auto-times-out at 120 s.
- `/file <path>` — pull a file from the device into Telegram
- `/upload <target>` — push a file from Telegram to the device. After running, the **next** document or photo you send within 2 min is saved at the target path/dir.
- `/screenshot` — full-screen PNG
- `/ramclean [soft|aggressive|nuke|list|<pkg>...]` — memory pressure cleanup with three modes; system/VPN/bot itself protected.

### 🗂 Filesystem
- `/ls <path>` — directory listing (up to 50 entries)
- `/cat <file>` — file contents (head 4 KB; use `/file` for larger)
- `/df` — disk usage on mounted partitions
- `/du <dir>` — top-level subdirectory sizes
- `/log [N]` — last N lines of `bot.log` (default 20, max 200)
- `/dump_sms` — full inbox SMS dump as a file

### 🌐 Network (advanced)
- `/connections` — established TCP sockets (top 30)
- `/listening` — listening TCP ports + owner PID
- `/dhcp` — dnsmasq lease table (clients of the hotspot)
- `/dns` — current DNS configuration (resolv.conf + Android props)

### ⚡ Power / kernel
- `/cpu_freq` — per-CPU current/min/max frequency + governor
- `/cpu_governor [name]` — show or change scaling governor on all cores
- `/wakelock` — currently-held wakelocks (kernel `wakeup_sources`)

### 📦 App management
- `/installed [3rd|disabled|system|all]` — packages by category
- `/freeze <package>` — `pm disable-user --user 0`
- `/unfreeze <package>` — `pm enable`

### ⏰ Scheduling
- `/alarm HH:MM <message>` — one-shot reminder at the next occurrence of HH:MM
- `/schedule <seconds> <command>` — recurring task. Command can be a bot command (`/status`, `/temp`, …) or any shell command (output truncated to 1.5 KB).
- `/schedule list|clear|cancel <idx>`
- `/heartbeat <hours>` — periodic "I'm alive" check-in (uptime + temp)
- `/quiet_hours <from> <to>` — alarms/heartbeats stay silent in the window (`/quiet_hours 23 7` = silent 23:00 → 07:00). `off` to disable.

State is persisted to `/data/statusbot/{schedules.txt,heartbeat.conf,quiet_hours.conf}` so reboots don't lose anything. Each scheduler poll is one timestamp comparison per loop — negligible RAM/CPU.

### 🔒 Security / audit
- `/who` — active SSH (port 22222) and ADB (5555/55555) sessions
- `/last_boot` — uptime + recent boot completion timestamps from logcat
- `/bot_stats` — bot uptime, message count, error lines, log size
- `/restart_bot` — supervisor restarts within ~10 s

### 💬 Chat-style triggers
"selam", "merhaba", "sa", "naber", "saat", "iyi misin", "teşekkür", "günaydın", "iyi geceler" — all match informally and reply naturally (in your chosen UI language).

### 🌍 Multi-language UI (12 languages)

statusbot's user-facing text is translatable. The bot replies in your
selected language across all commands, help text, alerts, and the Telegram
side-menu (`setMyCommands`).

| Code | Language | Coverage |
|---|---|---|
| `en` | **English** *(default + fallback)* | ✅ full (449 keys) |
| `tr` | **Türkçe** | ✅ full (449 keys) |
| `es` | Español | seeded (96 keys, rest → English) |
| `de` | Deutsch | seeded (74 keys) |
| `fr` | Français | seeded (74 keys) |
| `pt` | Português | seeded (74 keys) |
| `ru` | Русский | seeded (74 keys) |
| `zh` | 简体中文 | seeded (74 keys) |
| `ja` | 日本語 | seeded (74 keys) |
| `ko` | 한국어 | seeded (74 keys) |
| `ar` | العربية | seeded (74 keys) |
| `hi` | हिन्दी | seeded (74 keys) |

Switch from the bot: `/lang en`, `/lang tr`, `/lang es`, etc. The choice
persists across reboots. Missing keys in a partial translation gracefully
fall back to English — the bot never breaks on incomplete coverage.

To add a language or extend coverage, drop a `lang/<code>.sh` file and open
a PR — see [`lang/README.md`](lang/README.md) for the format.

## Requirements

- Magisk 20.4+
- Android arm64
- **[bin-utils](../bin-utils/) module installed first** — provides `curl`, `jq`, and the CA bundle
- A Telegram bot token (from [@BotFather](https://t.me/BotFather))
- Your Telegram chat ID

Optional:
- [UFI-TOOLS](https://github.com/kanoqwq/UFI-TOOLS) — if installed, the bot falls back to its `sendat` when not found in `/system/bin`. With bin-utils ≥ v1.1.0 this is no longer required; UFI can be frozen/uninstalled freely.

## Setup

### 1) Create a Telegram bot

In Telegram, message [@BotFather](https://t.me/BotFather):
```
/newbot
```
Pick a name. BotFather gives you a **bot token** like `123456789:ABC-DEF...`.

### 2) Find your chat ID

Send any message (e.g. "hi") to your new bot. Then open in a browser:
```
https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates
```
Find `"chat":{"id":<NUMBER>` — that number is your **chat ID**.

### 3) Place credentials on the device

Push these files to the device (any of these locations is picked up by the installer):
```sh
# Pick any of these paths
echo "123456789:ABC-DEF..." > /sdcard/statusbot_token.txt
echo "11223344" > /sdcard/statusbot_chat_id.txt
```
Or via `adb push` from your computer.

### 4) Flash the modules

In Magisk Manager:
1. Flash `bin-utils.zip` first.
2. Flash `statusbot.zip`.
3. Reboot.

During flash, statusbot reads the token/chat_id files from `/sdcard` and writes them to `/data/statusbot/`. The source files are deleted after read.

### 5) That's it

After reboot you should get a greeting:
```
Günaydın, ben ayaktayım 🤖
F50 — uptime: 0 dk 38 sn
Komutlar için /help
```

Send `/help` to see everything.

## How it works

- A `late_start` Magisk service runs `service.sh`, which supervises `bot.sh` (restarts on crash, rotates logs).
- `bot.sh` long-polls the Telegram `getUpdates` endpoint (25 s timeout). Idle CPU ≈ 0 %, RAM ≈ 5 MB.
- Only messages from the authorized chat ID are processed; everything else is silently ignored.
- Inline buttons are handled via `callback_query` updates (also long-polled).

## File layout (after install)

```
/data/adb/modules/statusbot/
├── module.prop
├── service.sh                    # late_start: supervisor + bot launcher
├── customize.sh                  # captures token + chat_id during flash
├── uninstall.sh                  # stops the bot, leaves /data/statusbot
├── README.md                     # this file
└── bot/
    └── bot.sh                    # main bot script

/data/statusbot/
├── token                         # Telegram bot token (chmod 600)
├── chat_id                       # authorized chat (chmod 600)
├── zte_password                  # optional: ZTE admin password for /performance
├── offset                        # Telegram getUpdates offset (persisted)
├── bot.log                       # rotated at ~1 MB
├── service.log                   # supervisor log
└── tasks/                        # active /komut state
```

## Bot safety

- All commands gated by chat-ID check.
- `/reboot` requires explicit `/reboot YES` within 60 s.
- `/imei_degis` requires `/imei_degis YES` within 2 min, and validates Luhn before accepting.
- `/komut` is the only "open" surface — it lets the owner run any shell, but it's owner-only. Auto-kills at 120 s.

## Bootloop safety

`late_start service` mode runs **after** Android boot completes, so if the script has a bug, Android still boots normally. Only the bot won't start. There is no `post-fs-data.sh` or `init.rc` modification, no system file replacement.

## Customization tips

Edit `bot/bot.sh` and either:
- Push back to `/data/adb/modules/statusbot/bot/bot.sh` and `pkill -f bot/bot.sh` (the supervisor restarts it in ~10 s with the new code), or
- Repackage as a new Magisk zip and reflash.

Adding a new command is just adding one `case` arm in `dispatch()`.

## Uninstall

Remove from Magisk Manager and reboot. `/data/statusbot/` (token, chat_id, logs) is preserved by default — manually remove with `rm -rf /data/statusbot` if needed.

## Troubleshooting

```sh
# Live bot log
adb shell su -c 'tail -f /data/statusbot/bot.log'

# Supervisor log (shows crashes / restarts)
adb shell su -c 'tail -f /data/statusbot/service.log'

# Restart the bot manually
adb shell su -c 'pkill -f /data/adb/modules/statusbot/bot/bot.sh'
# Supervisor auto-restarts it in ~10 s

# Bot offline? Check service.sh is alive
adb shell su -c 'ps -A | grep statusbot'
```

If the bot doesn't reply at all:
1. `cat /data/statusbot/token /data/statusbot/chat_id` — both should be non-empty.
2. `curl --cacert /system/etc/cacert.pem https://api.telegram.org/bot<token>/getMe` — should return `{"ok":true,...}` from the device.
3. Check the bot's log for `Bad API response`.

## License

Provided as-is. The shell script is short and easy to read; modify freely.
