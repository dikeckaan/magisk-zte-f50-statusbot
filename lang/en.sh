# statusbot English strings — DEFAULT FALLBACK
#
# Sourced FIRST. User-selected lang (lang/<code>.sh) sourced after may
# override individual keys. Any key missing from another language falls
# back to the value here.
#
# Convention: MSG[snake_case_key]="text"
#   • Static text (no substitution): use directly via `echo "${MSG[key]}"`
#   • Templates with %s placeholders: use via `printf "${MSG[key]}\n" "$arg"`
#     or the `tf key arg1 arg2 …` helper in bot.sh
#   • Multi-line: real newlines inside double quotes are fine
#
# DO NOT include shell command substitution ($(...) or `...`) here — those
# would evaluate at source time, not at use time. Use %s placeholders and
# let the caller pass the dynamic value via printf.

declare -gA MSG=(
    # ─── /lang command ────────────────────────────────────────────────
    [lang_current_fmt]="Current language: %s"
    [lang_available_header]="Available languages:"
    [lang_set_fmt]="Language set to %s. Bot will restart in 3 s."
    [lang_invalid_fmt]="Unknown language code: %s. See /lang for the list."
    [lang_usage]="Usage: /lang [code]
Without an argument, shows current + available languages.
With a code, switches and restarts the bot."

    # ─── greetings ────────────────────────────────────────────────────
    [greet_morning]="Good morning"
    [greet_noon]="Good afternoon"
    [greet_evening]="Good evening"
    [greet_night]="Good night"
    [boot_greeting_fmt]="%s, I'm up 🤖
%s — uptime: %s
Type /help for commands."

    # ─── /help (full text, two %d placeholders: temp threshold, mem%) ─────
    [help_full_fmt]="ZTE F50 Bot — Commands

📊 Status
/status — full overview
/uptime — running time
/load — CPU load (detailed)
/mem — RAM
/disk — Disk
/temp — Temperature (CPU)
/ps — Top 10 processes (CPU)

📡 Cellular
/signal — signal quality (RSSI, RSRP, RSRQ)
/cellinfo — operator + IMEI + ICCID + phone number
/imei — IMEI(s)
/imei_sorgula [imei] — IMEI structural analysis + e-Devlet lookup
/imei_degis <imei> — change IMEI (confirmed, reboots)
/operator — operator only
/qos — QoS / band details (AT+CGEQOSRDP)
/sms_list [N] — last N SMS messages (default 10)
/sms_count — inbox total
/sms_send <num> <text> — send SMS via AT (best-effort)
/at <cmd> — run a raw AT command

🌐 Network
/ip — public + local IPs
/traffic — RX/TX since boot
/ping <host>
/speedtest [cf|ookla|fast] [size] — speed test (default cf)
/clients — connected clients (ARP)
/wifi — hotspot SSID + password + clients
/tunnel — Cloudflared status

🔧 System
/modules — Magisk modules
/version
/reboot — restart (two-step confirmation)
/komut <cmd> — shell command (cancel button)
/file <path> — pull a file from device
/upload <target> — push a file to device (next attachment)
/screenshot — full-screen PNG
/ramclean [pkg…] — memory cleanup (system/VPN protected)
/performance [on|off] — ZTE Performance Mode (needs reboot)
/perf_balanced [mhz] — 8-core + freq cap (recommended, default 1800)
/perf_help — mode comparison + guide
/minimal_mode [on|persist|off] — freeze non-essentials (~240/640 MB)
/zte_setpw <password> — set ZTE admin password
/lang [code] — switch UI language

🗂 Filesystem
/ls <path> — directory listing
/cat <file> — file contents (4 KB limit)
/df — disk usage
/du <dir> — subdirectory sizes
/log [N] — last N lines of bot.log
/dump_sms — full inbox SMS dump (as file)

🌐 Network (extras)
/connections — established TCP sockets
/listening — listening ports
/dhcp — DHCP lease table
/dns — DNS configuration

⚡ Power / Kernel
/cpu_freq — per-CPU current/min/max
/cpu_governor [name] — show or change governor
/wakelock — active wakelocks

📦 Apps
/installed [3rd|disabled|system|all]
/freeze <pkg> — freeze a package
/unfreeze <pkg> — re-enable a package

⏰ Scheduling
/alarm HH:MM <msg> — one-shot
/schedule <sec> <cmd> — recurring
/schedule list / clear / cancel <idx>
/heartbeat <hours> — periodic check-in
/quiet_hours <from> <to> — silence alarms in window

🔒 Security / audit
/who — active SSH/ADB sessions
/last_boot — boot history
/bot_stats — bot internal stats
/restart_bot — restart the bot
/update [all|<id>] — pull module updates from GitHub

🌍 Tailscale (optional module)
/tailscale auth <key> — store auth key
/tailscale on / off — start/stop
/tailscale status — state + RAM
/tailscale ip / peers / log / logout

🔔 Automatic (background):
• Incoming SMS forwarded to you
• Alerts when temp > %d°C, RAM < %d%%, tunnel down
• Heartbeat (if configured) and schedules fire
• Quiet hours suppress automatic alerts

💬 Chat triggers
selam, merhaba, sa — greeting
naber — status + greeting
saat — device time
iyi misin — status check"

    # ─── fmt_uptime (3 forms) ────────────────────────────────────────
    [uptime_days_fmt]="%d d %02d h %02d m"
    [uptime_hours_fmt]="%d h %02d m"
    [uptime_short_fmt]="%d m %02d s"

    # ─── fmt_disk ────────────────────────────────────────────────────
    [disk_fmt]="%s / %s (%s used)"

    # ─── fmt_load ────────────────────────────────────────────────────
    [load_status_calm]="🟢 calm (%d%%)"
    [load_status_active]="🟡 active (%d%%)"
    [load_status_full]="🟠 full (%d%%)"
    [load_status_busy]="🔴 busy (%d%%)"
    [load_full_fmt]="📊 CPU Load (%d cores)

Now (1 min avg):   %s
Last 5 min:        %s
Last 15 min:       %s

Status: %s

Load guide:
  %d.0 = all CPUs fully used
  < %d.0 = headroom available
  > %d.0 = queue, slowdowns possible"

    # ─── /status ─────────────────────────────────────────────────────
    [status_model_fmt]="📱 %s\n"
    [status_uptime_fmt]="⏱  Uptime: %s\n"
    [status_ram_fmt]="💾 RAM: %s\n"
    [status_disk_fmt]="💿 Disk: %s\n"
    [status_temp_fmt]="🌡  Temperature: %s\n"
    [status_perf_on]="⚡ Performance: ON 🟢\n"
    [status_perf_off]="⚡ Performance: OFF ⚪\n"
    [status_operator_fmt]="📡 Operator: %s\n"
    [status_signal_fmt]="📶 Signal: RSSI %s (%s)\n"
    [status_public_ip_fmt]="🌐 Public IP: %s"

    # ─── /perf_help (full text) ───────────────────────────────────────
    [perf_help_full]="⚡ CPU / Performance guide

The SoC is octa-core (Unisoc UMS9620): 4× A55 (little) + 3× A76 (mid) + 1× A76 (big).
For battery life, ZTE keeps only the little cluster (cpu0-3) online at boot —
big/mid cluster (cpu4-7) is locked offline by an \"only_use_little_core\" hint.

4 MODES COMPARED

A) Default (do nothing)
   Active: cpu0-3 (4 cores), schedutil
   Throughput: ~35 Mbit/s   Temperature: 55-65°C
   ✗ Network bottleneck — single-thread fast-path saturates the CPU

B) /performance on  (+ reboot)
   Active: cpu0-7 (8 cores), schedutil up to 2.7 GHz
   Throughput: ~550 Mbit/s  Temperature: 85-90°C 🔥
   ✓ Top speed  ✗ Overheats, battery drains fast

C) /cpu_governor powersave  (all cores at min freq)
   Slow; not usable for single-threaded work
   ✗ Generally not recommended

D) /perf_balanced 1800  (RECOMMENDED)
   Active: cpu0-7 (8 cores), policy4/7 capped @ 1.8 GHz
   Throughput estimate: ~400 Mbit/s   Temperature: 70-75°C
   ✓ Throughput 10×↑   ✓ Safe temperature   ✓ Reasonable battery

RECOMMENDED FLOW

  1) /zte_setpw <password>          (one-time setup)
  2) /performance on                (clears only_use_little_core hint)
  3) Reboot the device              (hint is persisted in config flash)
  4) /perf_balanced 1800            (apply 1.8 GHz cap)

  Verify:
    /temp         — temperature
    /cpu_freq     — active frequencies
    /cpu_governor — which clusters are online + governor

  To revert:
    /perf_balanced reset            (drop the caps → full freq)
    /performance off                (back to only_use_little_core, reboot)

NOTES
  • /perf_balanced cap resets on reboot (sysfs lives in RAM).
    Re-apply each boot if you want it sticky.
  • /performance setting is persisted in ZTE config flash.
  • Trip point is 100°C — staying below 80°C is still wiser.
  • WireGuard (kernel-mode) is unaffected by the cap; userspace OpenVPN
    should still be fast at 1.8 GHz.

DIFFERENT MHZ VALUES

  1500 MHz cap → cooler, ~300 Mbit
  1800 MHz cap → balanced (recommended), ~400 Mbit
  2000 MHz cap → faster, ~450 Mbit, ~80°C
  2200 MHz cap → near-full, ~500 Mbit, 80-85°C
  reset        → hw max (2.3 / 2.7 GHz), ~550 Mbit, 85-90°C"
)
