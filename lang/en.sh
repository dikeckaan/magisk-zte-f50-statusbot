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

    # ─── /file ───────────────────────────────────────────────────────
    [file_usage]="Usage: /file <path>
Example: /file /data/statusbot/bot.log
Max 50 MB (Telegram limit)"
    [file_not_found_fmt]="❌ File not found: %s"
    [file_empty_fmt]="⚠️ File is empty: %s"
    [file_too_big_fmt]="❌ Too big: %d MB (limit 50 MB).
To split: split -b 49M %s /tmp/part_"
    [file_sending_fmt]="📤 Sending (%s)…"
    [file_unknown_error]="unknown"
    [file_tg_rejected_fmt]="❌ Telegram rejected: %s"
    [file_caption_fmt]="📄 %s"

    # ─── /screenshot ─────────────────────────────────────────────────
    [ss_failed]="❌ screencap failed (device may be asleep or in a secure window)"
    [ss_taken_fmt]="📸 Captured (%d bytes), sending…"
    [ss_caption_fmt]="📸 Screenshot — %s"

    # ─── /wifi ───────────────────────────────────────────────────────
    [wifi_header]="📶 WiFi (Hotspot)"
    [wifi_no_conf]="⚠️ hostapd.conf not found"
    [wifi_ssid_fmt]="📡 SSID:    %s"
    [wifi_pass_fmt]="🔑 Password: %s"
    [wifi_sec_fmt]="🔐 Security: %s"
    [wifi_bssid_fmt]="🏷 BSSID:   %s"
    [wifi_freq_fmt]="📻 Frequency: %s MHz (%s, %s)"
    [wifi_bridge_fmt]="🌐 Bridge:  %s"
    [wifi_clients_header]="👥 Connected clients:"
    [wifi_no_clients]="  (no active client right now)"

    # ─── /upload ─────────────────────────────────────────────────────
    [upload_usage_fmt]="Usage: /upload <target-path>
Example: /upload /sdcard/Download/

The next file you send within 2 minutes will be saved at this path.
Cancel: /iptal"
    [upload_waiting_fmt]="📥 Waiting: the next file will be saved under '%s'.
Cancel: /iptal"
    [upload_getfile_failed_fmt]="❌ getFile failed: %s"
    [upload_saved_fmt]="✅ Saved: %s (%d KB)"
    [upload_download_failed]="❌ Download failed"

    # ─── /at ─────────────────────────────────────────────────────────
    [at_usage]="Usage: /at <AT command>
Example: /at AT+CSQ
For slot 1: /at slot=1 AT+CSQ
Dangerous! You can break the modem — use carefully."
    [at_no_sendat]="❌ sendat not available (UFI-TOOLS required)"
    [at_must_start_with]="❌ Command must start with 'AT'"
    [at_request_fmt]="📟 \$ %s (slot=%d)"
    [at_empty_response]="(empty response)"

    # ─── /ramclean ───────────────────────────────────────────────────
    [rc_list_header]="🔝 RAM Usage (top 15):"
    [rc_mode_soft]="🧹 Soft Clean"
    [rc_mode_aggressive]="🧨 Aggressive Clean"
    [rc_mode_nuke]="💣 NUKE Clean"
    [rc_before_fmt]="Before: RAM %d MB | Swap %d MB"
    [rc_after_fmt]="After:  RAM %d MB | Swap %d MB"
    [rc_ram_gain_fmt]="✅ RAM gain: +%d MB"
    [rc_ram_loss_fmt]="⚠️ RAM dropped: %d MB"
    [rc_ram_same]="≈ RAM unchanged"
    [rc_swap_gain_fmt]="✅ Swap gain: +%d MB"
    [rc_killed_fmt]="🔥 Force-stop: %d app(s)%s"
    [rc_killed_more_fmt]="  … and %d more"
    [rc_modes_help]="Modes:
• /ramclean — soft (known-heavy)
• /ramclean aggressive — all 3rd-party
• /ramclean nuke — aggressive + trim-memory
• /ramclean list — top 15 RAM"

    # ─── /airplane ───────────────────────────────────────────────────
    [airplane_no_sendat]="❌ sendat not available"
    [airplane_on_fmt]="✈️ Airplane mode ON
%s"
    [airplane_off_fmt]="📡 Airplane mode OFF
%s"
    [airplane_off_state]="✈️ Modem OFF (CFUN=0)"
    [airplane_active_state]="📡 Modem active (CFUN=1)"
    [airplane_on_state]="✈️ Airplane mode ON (CFUN=4)"
    [airplane_unknown_fmt]="Mode: %s"
    [airplane_usage]="Usage: /airplane on|off|status"

    # ─── /sms_send ───────────────────────────────────────────────────
    [sms_usage]="Usage: /sms_send <phone> <message>
Example: /sms_send +905551234567 hi

⚠️ Shell-based SMS sending is limited. AT+CMGS is attempted; works only if the modem supports it."
    [sms_no_sendat]="❌ sendat not available"
    [sms_sent_fmt]="✅ SMS sent (or queued):
to: %s
msg: %s"
    [sms_failed_fmt]="❌ Send failed:
%s

Note: this modem may not support AT-based SMS sending. Try the UFI web UI."

    # ─── fmt_battery ─────────────────────────────────────────────────
    [bat_unread]="🔋 Battery info unavailable"
    [bat_status_charging]="🔌 Charging"
    [bat_status_discharging]="🔋 On battery"
    [bat_status_full]="✅ Full"
    [bat_status_not_charging]="⏸ Charge paused"
    [bat_header]="🔋 Battery Status"
    [bat_charge_fmt]="Charge: %d%% %s"
    [bat_state_fmt]="State: %s"
    [bat_temp_fmt]="Temperature: %s"
    [bat_volt_fmt]="Voltage: %s"

    # ─── handle_callback ─────────────────────────────────────────────
    [cb_unauthorized]="Unauthorized"
    [cb_reboot_in_progress]="Rebooting…"
    [cb_reboot_msg]="🔁 Device rebooting… (~50 s)"
    [cb_task_done]="Task already finished"
    [cb_cancelling]="Cancelling…"
    [cb_cancel_msg_fmt]="❌ Cancelled: \$ %s

%s"
    [cb_no_output]="<no output>"
    [cb_unknown]="Unknown action"

    # ─── /imei_sorgula ──────────────────────────────────────────────
    [imeis_usage]="Usage: /imei_sorgula <15-digit imei>"
    [imeis_digits_only]="❌ IMEI must be digits only"
    [imeis_length_fmt]="❌ Must be 15 digits (you entered %d)"
    [imeis_luhn_ok]="✓ Luhn valid"
    [imeis_luhn_bad]="❌ Luhn invalid"
    [imeis_header_fmt]="📱 IMEI: %s

🔍 Structural Analysis
TAC: %s (manufacturer + model code)
SNR: %s (serial number)
Check: %s (%s)"
    [imeis_edevlet_failed_fmt]="%s

⚠️ Could not reach e-Devlet"
    [imeis_captcha_caption]="📱 IMEI lookup captcha:
Type what you see as a message (2 min, 4-7 chars).
Cancel: /iptal"
    [imeis_result_fmt]="%s

📋 e-Devlet Result
%s"
    [imeis_captcha_failed_fmt]="%s

❌ Wrong captcha or timeout.
Retry: /imei_sorgula %s"

    # ─── /imei_degis ─────────────────────────────────────────────────
    [imei_degis_no_sendat]="❌ sendat not available"
    [imei_degis_no_pending]="⚠️ No pending IMEI change. First run: /imei_degis <new_imei>"
    [imei_degis_expired]="⚠️ Timed out (>2 min). Restart."
    [imei_degis_applied_fmt]="📱 IMEI change applied.
Old: %s
New: %s
Modem response: %s

🔁 The device will reboot in 5 seconds…"
    [imei_degis_usage]="Usage: /imei_degis <new_imei>
- Must be 15 digits
- To confirm: type \"/imei_degis YES\" within 2 minutes
- On confirmation, applied + device reboots

⚠️ Uses AT+SPIMEI=0,\"…\" (Unisoc-specific).
A wrong IMEI can get you in legal trouble."
    [imei_degis_digits_only]="❌ IMEI must contain digits only"
    [imei_degis_length_fmt]="❌ IMEI must be 15 digits (you entered %d)"
    [imei_degis_bad_luhn]="❌ Invalid IMEI (Luhn checksum doesn't match).
The last digit is a check digit — use a calculator."
    [imei_degis_pending_fmt]="⚠️ IMEI Change — Awaiting Confirmation

Current: %s
New:     %s

To confirm within 2 minutes:
  /imei_degis YES

On confirmation the device will REBOOT."

    # ─── /iptal during IMEI captcha ──────────────────────────────────
    [imei_cancel_done]="✓ IMEI query cancelled"

    # ─── Telegram /-menu descriptions (setMyCommands) ────────────────
    # Used by register_commands() to populate the side-menu shown when
    # the user types `/` in Telegram. Re-registered when /lang changes.
    [desc_start]="Help and command list"
    [desc_help]="Show all commands"
    [desc_status]="Device status overview"
    [desc_uptime]="Running time"
    [desc_load]="CPU load"
    [desc_mem]="RAM usage"
    [desc_disk]="Disk usage"
    [desc_temp]="CPU temperature"
    [desc_ps]="Top 10 process (CPU)"
    [desc_ip]="Public + local IPs"
    [desc_traffic]="Traffic (RX/TX) since boot"
    [desc_ping]="Ping test - /ping <host>"
    [desc_clients]="Connected clients (ARP)"
    [desc_tunnel]="Cloudflared tunnel status"
    [desc_operator]="Cellular operator"
    [desc_signal]="Signal quality"
    [desc_cellinfo]="Operator + IMEI + ICCID + phone"
    [desc_imei]="IMEI(s) - one per slot"
    [desc_imei_sorgula]="e-Devlet IMEI lookup (captcha)"
    [desc_imei_degis]="Change IMEI - confirmed reboot"
    [desc_qos]="QoS / Band details"
    [desc_sms_list]="SIM SMS list"
    [desc_sms_count]="SMS count"
    [desc_sms_send]="Send SMS - /sms_send <num> <text>"
    [desc_wifi]="Hotspot SSID/password/clients"
    [desc_file]="Pull file - /file <path>"
    [desc_screenshot]="Screenshot"
    [desc_ramclean]="Clean RAM (VPN/system protected)"
    [desc_at]="Run AT command - /at <cmd>"
    [desc_modules]="Magisk modules"
    [desc_performance]="ZTE Performance Mode - on/off"
    [desc_zte_setpw]="Set ZTE admin password"
    [desc_komut]="Shell command (cancellable)"
    [desc_reboot]="Reboot device (confirmed)"
    [desc_version]="Bot and device version"
    [desc_iptal]="Cancel pending IMEI/upload"
    [desc_ls]="Directory listing"
    [desc_cat]="File contents (4 KB)"
    [desc_df]="Disk usage"
    [desc_du]="Subdirectory sizes"
    [desc_log]="Last N lines of bot log"
    [desc_dump_sms]="Full inbox SMS dump (file)"
    [desc_upload]="Upload file to device - /upload <target>"
    [desc_connections]="Active TCP connections"
    [desc_listening]="Listening ports"
    [desc_dhcp]="DHCP lease table"
    [desc_dns]="DNS configuration"
    [desc_traffic_history]="Traffic history (today/week/month) - /traffic_history [iface]"
    [desc_adguard]="AdGuard Home control - /adguard {status|on|off|log|url}"
    [desc_spectrum]="Visible cell towers (from cell-tools)"
    [desc_imsi_watch]="IMSI catcher anomaly events - /imsi_watch [list|alerts]"
    [desc_locate]="GPS via cell-tower triangulation (Mozilla Location Service)"
    [desc_ussd]="Run a USSD shortcode - /ussd *123# (note: not supported on this modem)"
    [desc_sms_cmd]="SMS offline backup channel - /sms_cmd {status|add|remove|list|secret|log}"
    [desc_tor]="Tor bridge - /tor {status|on|off|route|fingerprint|log}"
    [desc_cpu_freq]="CPU frequencies"
    [desc_cpu_governor]="Show or change governor"
    [desc_wakelock]="Active wakelocks"
    [desc_freeze]="Freeze a package"
    [desc_unfreeze]="Unfreeze a package"
    [desc_installed]="Installed packages [3rd|disabled|system|all]"
    [desc_who]="Active SSH/ADB sessions"
    [desc_last_boot]="Boot history"
    [desc_bot_stats]="Bot internal stats"
    [desc_restart_bot]="Restart the bot"
    [desc_quiet_hours]="Quiet hours - silence alerts"
    [desc_heartbeat]="Periodic alive ping"
    [desc_alarm]="One-shot alarm - /alarm HH:MM <msg>"
    [desc_schedule]="Recurring schedule"
    [desc_tailscale]="Toggle Tailscale exit-node (module required)"
    [desc_perf_balanced]="8 core + freq cap (recommended)"
    [desc_perf_help]="CPU/Performance guide"
    [desc_minimal_mode]="Freeze non-essential services (~640 MB)"
    [desc_speedtest]="Speed test - /speedtest [provider] [size]"
    [desc_update]="Update modules from GitHub - /update [all|<id>]"
    [desc_install_module]="Install module from catalog - /install_module [list|<id>]"
    [desc_lang]="Change bot language - /lang [code]"

    # ─── inline button captions (tg_send_with_cancel, reboot) ───────
    [btn_cancel]="❌ Cancel"
    [btn_reboot_now]="🔁 Reboot Now"

    # ─── csq_label (cellular signal quality) ─────────────────────────
    [csq_excellent]="🟢 Excellent"
    [csq_good]="🟢 Good"
    [csq_moderate]="🟡 Moderate"
    [csq_weak]="🟠 Weak"
    [csq_very_weak]="🔴 Very weak"
    [csq_unknown]="🔴 Unknown"

    # ─── fmt_traffic / interfaces ────────────────────────────────────
    [iface_default_exit]=" ⬅ default exit"
    [iface_traffic_up_fmt]="  ↑ %s sent"
    [no_sendat_short]="(sendat unavailable - UFI-TOOLS not installed)"
    [lte_details]="LTE Details:"

    # ─── /cat ────────────────────────────────────────────────────────
    [cat_usage]="Usage: /cat <file>"
    [cat_truncated_hint_fmt]="... (rest: /file %s)"
    [cat_no_file_fmt]="❌ File not found: %s"
    [cat_file_header_fmt]="📄 %s (%d bytes — first 4000)"
    [cat_short_header_fmt]="📄 %s"

    # ─── /df /du /connections /listening /dns /dhcp ──────────────────
    [df_header]="💿 Disk Usage:"
    [du_header_fmt]="📊 %s subdirectory sizes:"
    [du_no_dir_fmt]="❌ Directory not found: %s"
    [conn_header]="🔗 Established TCP connections (top 30):"
    [listen_header]="👂 Listening TCP ports:"
    [dns_header]="🌐 DNS Configuration:"
    [dns_active]="Active DNS (Android props):"
    [dhcp_header]="📋 DHCP / Connected Devices"
    [dhcp_no_server]="DHCP server: none (hotspot may be off)"
    [dhcp_server_fmt]="DHCP server: dnsmasq (PID %s, stateless)"
    [dhcp_bridge_fmt]="Bridge:       %s"
    [dhcp_clients_header]="👥 Active clients (ip neigh dev br0):"
    [dhcp_none]="  (none)"
    [dhcp_total_fmt]="Total: %d device(s)"

    # ─── /install_module — manifest-driven module installer ─────────
    [install_manifest_failed]="❌ Could not fetch the module catalog from f50-magisk-modules. Check internet."
    [install_list_header]="📦 Module catalog (from f50-magisk-modules)"
    [install_list_state_installed]="(installed)"
    [install_list_state_missing_required]="(required, NOT installed)"
    [install_list_available_fmt]="  ⬇  %s  (available — /install_module %s)"
    [install_usage]="Usage:
  /install_module <id>   — install from catalog
  /install_module list   — show this list
  Aliases (e.g. adguard, ssh, tunnel, ts, traffic) are resolved automatically.
  Manifest: https://github.com/dikeckaan/f50-magisk-modules/blob/main/modules.json"
    [install_unknown_fmt]="❌ Unknown module: %s. Try /install_module list."
    [install_no_url_fmt]="❌ %s has no update_json URL in the catalog."
    [install_already_present_fmt]="ℹ️ %s is already installed. Use /update %s to upgrade."
    [install_fetching_fmt]="🔎 Fetching latest release info for %s ..."
    [install_meta_failed_fmt]="❌ Could not fetch update.json for %s. Check internet."
    [install_parse_failed_fmt]="❌ update.json for %s is malformed (missing version or zipUrl)."
    [install_downloading_fmt]="⬇  Downloading %s %s ..."
    [install_download_failed_fmt]="❌ Download failed for %s."
    [install_sha_ok_fmt]="🔒 SHA-256 verified for %s"
    [install_sha_missing_fmt]="⚠️ %s: no sha256 in update.json (older release). Proceeding without integrity check."
    [install_sha_mismatch_fmt]="❌ %s: SHA-256 mismatch!\n  expected: %s\n  actual:   %s\nInstall aborted."
    [install_installing_fmt]="📥 Installing %s via magisk ..."
    [install_success_fmt]="✅ %s %s installed successfully."
    [install_failed_fmt]="❌ magisk install for %s failed:\n%s"
    [install_reboot_hint]="ℹ️ Reboot to activate the new module. Use /reboot when ready."

    # ─── cell-tools integration (/spectrum, /imsi_watch, /locate, /ussd) ──
    [cell_not_installed]="📡 cell-tools module is not installed. /install_module cell-tools to add it."
    [cell_db_empty]="📡 cell-tools DB is empty — daemon hasn't scanned yet (give it ~60s after boot)."
    [spectrum_header]="📡 Visible cells (most recently seen first):"
    [imsi_watch_status_fmt]="🥷 IMSI Watch\n  Known cells: %d\n  Events logged: %d"
    [imsi_watch_list_header]="🥷 Known cells:"
    [imsi_watch_alerts_header]="🥷 Recent anomaly events:"
    [imsi_watch_no_events]="(no events yet — clean)"
    [imsi_watch_usage]="Usage: /imsi_watch {status|list|alerts}"
    [locate_request_fmt]="🌍 Geolocating cell MCC=%s MNC=%s CID=%s ..."
    [locate_no_data]="🌍 No cell data available (cell-tools needs to run first)."
    [locate_failed_fmt]="❌ Location lookup failed: %s"
    [locate_result_fmt]="🌍 Approximate location:\n  Latitude:  %s\n  Longitude: %s\n  Accuracy: ±%s m\n  https://maps.google.com/?q=%s,%s"
    [ussd_unsupported]="📞 USSD is not available on this device.\n\nThe Unisoc UMS9620 modem's AT command surface allows AT+CUSD only in enable/disable/cancel modes — sending an actual USSD code returns CME ERROR 3 (Operation not allowed). No alternative path exists on this firmware:\n  • cmd phone send-ussd-request — not implemented in this Android build\n  • Dialer Activity intent — works but the F50 is headless, so the reply UI is invisible\n\nWorkarounds: dial the USSD code from a phone using this F50's SIM (if reachable), or via the operator's web/app self-service portal.\n\n(Command kept in /help so future hardware/firmware updates can re-enable it.)"
    [ussd_usage]="(unused — see ussd_unsupported)"
    [ussd_request_fmt]="(unused)"
    [ussd_response_fmt]="(unused)"
    [ussd_multistep_fmt]="(unused)"
    [ussd_failed_fmt]="(unused)"

    # ─── /sms_cmd (sms-cmd module) ───────────────────────────────────
    [smscmd_not_installed]="📱 sms-cmd module is not installed. /install_module sms-cmd to add the offline SMS backup channel."
    [smscmd_no_config]="📱 sms-cmd config missing — daemon hasn't seeded /data/sms-cmd/config.json yet."
    [smscmd_status_fmt]="📱 SMS Command Channel\n  Secret set:        %s\n  Whitelist entries: %s\n  Allowed cmds:      %s\n  Events logged:     %s"
    [smscmd_secret_set]="🔐 Secret updated."
    [smscmd_secret_usage]="Usage: /sms_cmd secret set <new-secret>"
    [smscmd_added_fmt]="✅ Added %s to whitelist."
    [smscmd_add_usage]="Usage: /sms_cmd add <phone>  (e.g. +905551234567)"
    [smscmd_removed_fmt]="🗑 Removed %s from whitelist."
    [smscmd_remove_usage]="Usage: /sms_cmd remove <phone>"
    [smscmd_whitelist_header]="📱 Whitelisted phone numbers:"
    [smscmd_events_header]="📜 Recent SMS command events:"
    [smscmd_usage]="Usage:\n  /sms_cmd                    — status\n  /sms_cmd secret set <s>     — change secret\n  /sms_cmd add <phone>        — whitelist a number\n  /sms_cmd remove <phone>     — un-whitelist\n  /sms_cmd list               — show whitelist\n  /sms_cmd log                — recent events"

    # ─── /tor (tor-relay module) ─────────────────────────────────────
    [tor_not_installed]="🧅 tor-relay module is not installed. /install_module tor-relay to add the Tor bridge."
    [tor_status_running_fmt]="🧅 Tor Bridge: 🟢 running\nPID: %s\nRAM: %d MB\nBootstrap: %s\nRoute: %s\nCircuits seen: %s"
    [tor_status_stopped]="🧅 Tor Bridge: ⚪ stopped\nStart it with /tor on"
    [tor_already_running]="🧅 Already running. /tor status for details."
    [tor_already_stopped]="🧅 Already stopped."
    [tor_started]="🧅 Started. Use /tor status to watch bootstrap."
    [tor_stopped]="🧅 Stopped. Tor outbound circuits closed."
    [tor_route_header]="🧅 Tor outbound routing:"
    [tor_route_fmt]="  Current path: %s\n  (Tailscale up → tor exits via tailnet; down → cellular)"
    [tor_fingerprint_fmt]="🧅 Bridge identity fingerprint:\n  %s\n\nShare this with anyone who needs a private bridge."
    [tor_fp_not_ready]="🧅 Fingerprint not ready yet — bridge still bootstrapping."
    [tor_log_header]="📜 Tor log (last 20 lines):"
    [tor_no_log]="📜 No tor.log yet — bridge may not have started."
    [tor_usage]="Usage:\n  /tor                — status\n  /tor on             — start daemon\n  /tor off            — stop daemon (frees ~30 MB RAM)\n  /tor route          — current outbound path\n  /tor fingerprint    — bridge identity\n  /tor log            — last 20 lines"

    # ─── /traffic_history (traffic-stats module) ─────────────────────
    [traffic_hist_not_installed]="📊 traffic-stats module is not installed. Flash it from github.com/dikeckaan/magisk-zte-f50-traffic-stats and reboot."
    [traffic_hist_header]="📊 Traffic history"
    [traffic_hist_empty]="(no daily files yet — daemon needs ~60s after first install)"
    [traffic_hist_iface_fmt]="• %s\n   Today:   %s ↓ / %s ↑\n   7 days:  %s ↓ / %s ↑\n   Month:   %s ↓ / %s ↑\n"

    # ─── /adguard (adguardhome module) ───────────────────────────────
    [agh_not_installed]="🛡 AdGuard Home module is not installed. Flash it from github.com/dikeckaan/magisk-zte-f50-adguardhome and reboot."
    [agh_status_running_fmt]="🛡 AdGuard Home: 🟢 running\nPID: %s\nRAM: %d MB\nQueries today: %s\nBlocked today: %s\n"
    [agh_status_stopped]="🛡 AdGuard Home: ⚪ stopped
Start it with /adguard on"
    [agh_already_running]="🛡 Already running. Use /adguard status for details."
    [agh_started]="🛡 Started. Web UI at http://192.168.0.1:3000"
    [agh_start_failed]="❌ Could not start. Check /adguard log for details."
    [agh_already_stopped]="🛡 Already stopped."
    [agh_stopped]="🛡 Stopped. iptables NAT redirect on br0 removed too — hotspot clients now use the device's default DNS (unfiltered)."
    [agh_log_header]="📜 AdGuard Home daemon log (last 30 lines):"
    [agh_no_log]="📜 No log file yet — daemon may not have started."
    [agh_url_fmt]="🌐 AdGuard Home Web UI: %s"
    [agh_help]="🛡 AdGuard Home
/adguard status   — running? RAM? today's counts
/adguard on       — start daemon
/adguard off      — stop daemon (free RAM)
/adguard log      — last 30 daemon log lines
/adguard url      — web UI URL"

    # ─── /cpu_freq /cpu_governor /wakelock ───────────────────────────
    [cpufreq_header]="⚡ CPU Frequencies"
    [cpufreq_line_fmt]="  CPU%d: %d MHz (gov=%s, %d-%d MHz)\n"
    [gov_status_header]="⚙️ CPU governor status:"
    [gov_online_label]="🟢 online "
    [gov_offline_label]="⚫ offline"
    [gov_line_fmt]="  cpu%d  %s  %s\n"
    [gov_available_fmt]="Available: %s"
    [gov_change_hint]="To change: /cpu_governor <name>  (resets at reboot)"
    [gov_applied_fmt]="✅ %d cluster(s) → %s"
    [gov_woken_fmt]="(temporarily onlined:%s — Android will re-offline)"
    [gov_skipped_fmt]="⚠ %d cluster(s) skipped (permission/unsupported)"
    [gov_no_change_fmt]="❌ No cluster updated (invalid governor: %s?)"
    [wakelock_header]="💡 Active Wakelocks:"
    [wakelock_unread]="  wakeup_sources unreadable"

    # ─── /freeze /unfreeze /installed ────────────────────────────────
    [freeze_usage]="Usage: /freeze <package>"
    [unfreeze_usage]="Usage: /unfreeze <package>"
    [freeze_done_fmt]="❄️ %s frozen"
    [unfreeze_done_fmt]="✅ %s re-enabled"
    [freeze_failed_fmt]="❌ Failed: %s"
    [installed_user_header]="📦 3rd-party packages (top 30):"
    [installed_disabled_header]="❄️ Disabled packages:"
    [installed_system_header]="🤖 System packages (top 50):"
    [installed_all_header_fmt]="📦 ALL packages (%d total, top 50):"
    [installed_usage]="Usage: /installed [3rd|disabled|system|all]"

    # ─── /who /last_boot ─────────────────────────────────────────────
    [who_header]="👥 Active SSH/ADB sessions:"
    [last_boot_header]="🔄 Boot History:"
    [last_boot_current_fmt]="Currently up: %s"
    [last_boot_prev]="Previous boots (from logcat):"

    # ─── /log /dump_sms ──────────────────────────────────────────────
    [log_header_fmt]="📝 Bot log last %d lines:"
    [dump_sms_none]="📭 No SMS"
    [dump_sms_count_fmt]="📨 SMS dump (%d messages) sending…"
    [dump_sms_caption_fmt]="📨 SMS Dump (%d messages)"

    # ─── /bot_stats ──────────────────────────────────────────────────
    [bot_stats_fmt]="🤖 Bot Statistics

Version:    %s
Uptime:     %dh %dm
Messages:   %d
Error lines: %d
Log size:   %d KB
PID:        %d"
    [bot_restart_msg]="🔄 Bot restarting…"
    [bot_restart_dispatch_fmt]="🔄 Bot will restart in 2 s, supervisor will respawn it."

    # ─── /operator (status line shortcut) ────────────────────────────
    [op_status_fmt]="📡 %s"

    # ─── /komut ──────────────────────────────────────────────────────
    [komut_usage_fmt]="Usage: /komut <shell command>
Example: /komut ls /data
Runs up to %d s, auto-cancelled afterwards."
    [komut_running_fmt]="🔄 Running:
$ %s

(Long output is sent on completion. ❌ Cancel to abort.)"

    # ─── /sms_list /sms_count /cellinfo ──────────────────────────────
    [sms_unread]="💬 SMS unreadable (content provider not accessible)"
    [sms_count_hint]="Use: /sms_list  (default 10, e.g. /sms_list 20)"
    [cellinfo_no_sendat]="❌ UFI-TOOLS (sendat) not available. Cellular info cannot be read."
    [cellinfo_operator_fmt]="Operator: %s"
    [cellinfo_net_fmt]="Network: %s"

    # ─── /ip /clients /modules /tunnel ───────────────────────────────
    [ip_local_header]="🏠 Local interfaces:"
    [modules_header]="🧩 Magisk Modules:"
    [tunnel_off]="❌ Cloudflared not running"
    [clients_header]="📶 ARP/Neighbor table:"
    [clients_none]="  (no active record)"

    # ─── /ping ───────────────────────────────────────────────────────
    [ping_usage]="Usage: /ping <host>"
    [ping_invalid_host]="❌ Invalid host"

    # ─── /speedtest loop ─────────────────────────────────────────────
    [loop_already_running_fmt]="⚠ Loop already running (PID %s). First: /iptal"
    [loop_empty_result_fmt]="⚠ Loop #%d: empty result (rc=%s), stopping"
    [loop_started_fmt]="🔁 Loop started
provider: %s
count: %s
First result arrives in 15-30 s.

Stop: /iptal"
    [loop_iter_fmt]="🔁 Loop #%d (%s)
%s"
    [loop_done_fmt]="✅ Speedtest loop finished (%d iter, %s)"

    # ─── misc inline (file ops, errors) ──────────────────────────────
    [common_not_exists_fmt]="❌ Doesn't exist: %s"

    # ─── poll_auto_alerts ────────────────────────────────────────────
    [alert_temp_fmt]="🌡 WARNING: CPU temperature high — %d°C
(Threshold %d°C, won't re-warn for %d s)"
    [alert_mem_fmt]="💾 WARNING: RAM very low — %d%% available
(%d MB)"
    [alert_tunnel]="🔌 WARNING: Cloudflared tunnel is down (no process)"
    [alert_sms_forward_fmt]="📨 Incoming SMS — %s
👤 %s

%s"

    # ─── /komut completion ───────────────────────────────────────────
    [komut_truncated_fmt]="
... (truncated, %d bytes total)"
    [komut_done_fmt]="✅ Done: \$ %s

%s%s"
    [komut_timeout_fmt]="⏱ Timeout (%ds): \$ %s

%s"

    # ─── small format strings for /ls and /sms_list rows ─────────────
    [ls_header_fmt]="📁 %s"
    [sms_line_fmt]="📨 %s — %s"

    # ─── Chat triggers (informal Turkish patterns matched, translated reply) ─
    [chat_greeting_fmt]="%s, here I am 👋"
    [chat_naber_fmt]="%s! Here's my status:

%s"
    [chat_time_fmt]="🕐 %s"
    [chat_imisin_fmt]="I'm fine 🙂 (temp %s, uptime %s)"
    [chat_thanks]="🤖 You're welcome 👍"
    [chat_morning_fmt]="Good morning! ☀️ %s elapsed so far"
    [chat_night]="You too 🌙 I'll stay awake"

    # ─── /quiet_hours ────────────────────────────────────────────────
    [qh_active]="🔇 currently quiet"
    [qh_inactive]="🔊 not active right now"
    [qh_status_fmt]="Quiet hours: %s:00 — %s:00 (%s)"
    [qh_not_set]="Quiet hours are not set.
Usage: /quiet_hours <from> <to>
Example: /quiet_hours 23 7  (silent from 23:00 to 07:00)"
    [qh_off]="🔊 Quiet hours disabled"
    [qh_invalid_from]="❌ Invalid 'from'"
    [qh_invalid_to]="❌ Invalid 'to'"
    [qh_range_from]="❌ from must be 0-23"
    [qh_range_to]="❌ to must be 0-23"
    [qh_set_fmt]="🔇 Quiet hours: %s:00 — %s:00 (automatic alerts are silent in this window)"

    # ─── /heartbeat ──────────────────────────────────────────────────
    [hb_status_fmt]="❤️ Heartbeat: every %d hours
To disable: /heartbeat off"
    [hb_not_set]="Heartbeat is off.
Usage: /heartbeat <interval-hours>
Example: /heartbeat 6  (an 'I'm alive' message every 6 hours)"
    [hb_disabled]="❤️ Heartbeat disabled"
    [hb_not_number]="❌ Must be an hour count (number)"
    [hb_min_one]="❌ At least 1 hour"
    [hb_set_fmt]="❤️ Heartbeat: every %d hour(s) enabled"
    [hb_ping_fmt]="❤️ Heartbeat — %s, I'm up.
Uptime: %s | Temp: %s"

    # ─── /alarm ──────────────────────────────────────────────────────
    [alarm_usage]="Usage: /alarm HH:MM <message>
Example: /alarm 14:30 Meeting time"
    [alarm_no_msg]="❌ Message missing"
    [alarm_bad_hour]="❌ Hour?"
    [alarm_bad_min]="❌ Minute?"
    [alarm_bad_time]="❌ Invalid time"
    [alarm_set_fmt]="⏰ Alarm: %s:%s (in %dh %02dm)
message: %s"
    [alarm_fired_fmt]="⏰ ALARM
%s"

    # ─── /schedule ───────────────────────────────────────────────────
    [sch_empty]="No schedules.

Usage:
/alarm HH:MM <msg>
/schedule <seconds> <cmd>     (recurring)
/schedule clear               (wipe all)"
    [sch_header]="📅 Schedules:"
    [sch_now_label]="now"
    [sch_sec_fmt]="%ds"
    [sch_min_fmt]="%dm"
    [sch_hour_fmt]="%dh %02dm"
    [sch_entry_fmt]="  %d. [%s] %s — %s\n"
    [sch_cleared]="🗑 All schedules cleared"
    [sch_cancel_usage]="Usage: /schedule cancel <idx>"
    [sch_cancelled_fmt]="✓ Deleted: %s"
    [sch_invalid_usage]="Usage: /schedule <seconds> <cmd>"
    [sch_no_cmd]="❌ Command missing"
    [sch_min_secs]="❌ At least 10 seconds"
    [sch_added_fmt]="🔁 Scheduled: every %d seconds → '%s'
First in %d seconds"
    [sch_fire_fmt]="🔁 Schedule [%s]
%s"
    [sch_unsupported_fmt]="(unsupported in schedule: %s)"

    # ─── /speedtest ──────────────────────────────────────────────────
    [st_usage]="Usage: /speedtest [PROVIDER] [SIZE] [loop [COUNT]]

PROVIDER:
  (empty)|cf   Cloudflare endpoint (single-stream, fast default)
  ookla        Ookla Speedtest CLI (multi-stream, most accurate)
  fast         fast.com (Netflix CDN)

SIZE (cf mode only):
  quick        10 MB DL
  <mb>         5-200 MB DL
  full         50 MB DL + 25 MB UL
  (empty)      50 MB DL

LOOP:
  loop         infinite loop — each result arrives as a message
  loop N       run N times
  Stop: /iptal

Examples:
  /speedtest ookla
  /speedtest cf 100 loop 5
  /speedtest fast loop
  /speedtest loop 3"
    [st_cf_starting_fmt]="🚀 Cloudflare speedtest starting (%d MB DL%s)…"
    [st_cf_starting_upload]=" + 25 MB UL"
    [st_cf_download_failed]="❌ Download failed (curl error)"
    [st_cf_upload_failed]="
⬆ Upload:    failed"
    [st_cf_upload_fmt]="
⬆ Upload:    %s Mbit/s (%s MB / %ss)"
    [st_cf_result_fmt]="📊 Cloudflare Speedtest

⬇ Download:  %s Mbit/s (%s MB / %ss)%s
🏓 Latency:   %s ms (TCP connect)
🖥 CPU:        %s
🌡 Temp:      %s

Server: speed.cloudflare.com (single-stream)
Multi-stream test: /speedtest ookla"
    [st_ookla_downloading]="📥 First run: downloading Ookla CLI (~1.5 MB, ~5 s)…"
    [st_ookla_download_failed]="❌ Couldn't download Ookla binary (network?)"
    [st_ookla_extract_failed]="❌ Ookla tar extract failed"
    [st_ookla_starting]="🚀 Ookla Speedtest starting (multi-stream, closest server)…"
    [st_ookla_failed_fmt]="❌ Ookla failed:
%s"
    [st_ookla_result_fmt]="📊 Ookla Speedtest

⬇ Download:  %s Mbit/s
⬆ Upload:    %s Mbit/s
🏓 Ping:      %s ms (jitter %s ms)
🖥 Server:    %s (%s)
🌐 ISP:       %s
🔌 Interface: %s  ext_ip=%s%s
🌡 Temp:      %s

Multi-stream — industry standard, most accurate."
    [st_fast_starting]="🚀 fast.com (Netflix CDN) speedtest starting…"
    [st_fast_api_failed_fmt]="❌ fast.com API failed:
%s"
    [st_fast_download_failed]="❌ fast.com download failed"
    [st_fast_result_fmt]="📊 fast.com Speedtest

⬇ Download:  %s Mbit/s
   (%s MB / %ss, %d stream)
🖥 Server:    %s
🌡 Temp:      %s

Netflix CDN endpoint — Netflix-biased but reflects real speed."

    # ─── /minimal_mode ───────────────────────────────────────────────
    [mm_status_fmt]="📦 Minimal Mode

RAM available:   %d MB
Disabled packages: %d
Running com.* processes: %d

Commands:
  /minimal_mode on       — Force-stop EVERYTHING except the allowlist
                            (cellular/SMS/root/VPN/bot are untouched)
                            Reboot reverts. No brick risk.
                            ⚠ /performance is temporarily unusable
  /minimal_mode persist  — on + persist-disable SystemUI/Launcher/zte.web
                            ~640 MB freed. Survives reboot.
                            Revert: /minimal_mode off
  /minimal_mode off      — Re-enable disabled packages (reboot recommended)
  /minimal_mode list     — Show what's kept on (the allowlist)
  /minimal_mode preview  — What 'on' would kill (without running it)"
    [mm_allowlist]="🛡 Allowlist (these stay, all required):

Android core:
  android, system_server, zygote, kernel threads
Cellular/SMS:
  com.android.phone, com.android.subsys, com.android.smspush,
  com.android.se, com.android.providers.telephony,
  com.android.cellbroadcast*, com.android.networkstack*,
  com.android.NetworkStatsServer
  com.spreadtrum.*, com.sprd.*  (radio/IMS)
Storage/permissions:
  com.android.providers.media*, com.android.providers.settings,
  com.android.providers.contacts, com.android.permissioncontroller,
  com.android.shell, com.android.captiveportallogin,
  com.android.location.fused
Magisk:
  com.topjohnwu.magisk*
Thermal:
  com.zte.thermalbridge, com.zte.telephony.api
VPN:
  com.v2ray.*, com.wireguard.*, com.openvpn.*, com.protonvpn.*
[The bot itself is a root process, not a package — never affected]"
    [mm_preview_fmt]="👁 Preview: if 'on' ran
  Kept by allowlist:    %d packages
  force-stop targets:   %d packages
(most may not be running — no-op for those)"
    [mm_transient_done_fmt]="💨 Transient kill
%d packages force-stopped (%d kept by allowlist)
RAM: %d MB → %d MB (gain %d MB)

⚠ These will be temporarily unavailable: /performance (com.zte.web is killed)
✓ Reboot restores clean state — no brick risk
For a stickier mode: /minimal_mode persist"
    [mm_persist_done_fmt]="🧊 Persist mode active
Force-stop: %d packages
Disable-user: %d packages (SystemUI/Launcher/zte.web)
RAM: %d MB → %d MB (gain %d MB)

⚠ /performance is unavailable (com.zte.web disabled)
⚠ Web UI (192.168.0.1:8080) won't respond
✓ Stays off across reboots
✓ Revert: /minimal_mode off (reboot recommended after)"
    [mm_off_done_fmt]="✅ Minimal Mode disabled
%d tracked packages re-enabled (only the ones we disabled).
Force-stopped ones are restarted by Android on demand.
For a fully clean state: reboot the device."
    [mm_disabled_none]="📋 No tracked-disabled package"
    [mm_disabled_header]="📋 Packages disabled by the bot:"
    [mm_disabled_state_disabled]="❄ disabled"
    [mm_disabled_state_mismatch]="? mismatch (already enabled)"
    [mm_disabled_footer]="One-by-one revert: /minimal_mode enable <pkg>
Revert all:        /minimal_mode off"
    [mm_enable_usage]="Usage: /minimal_mode enable <pkg>
Tracked list: /minimal_mode disabled"
    [mm_enable_not_tracked_fmt]="❌ '%s' is not in the tracked list.
To force-enable anyway: pm enable %s  (shell)"
    [mm_enable_success_fmt]="✅ %s re-enabled (removed from tracked list)"
    [mm_enable_failed_fmt]="❌ Failed: %s"
    [mm_disable_usage]="Usage: /minimal_mode disable <pkg>"
    [mm_disable_essential_fmt]="❌ '%s' is in the essentials list (cellular/SMS/root/VPN).
Disabling it can break the system. If you really want to:
  pm disable-user --user 0 %s  (shell — at your own risk)"
    [mm_disable_success_fmt]="❄ %s disabled + tracked
Revert: /minimal_mode enable %s"
    [mm_disable_failed_fmt]="❌ Failed: %s"
    [mm_usage]="Usage: /minimal_mode <subcommand>

Batch:
  on / kill      — Force-stop everything outside the allowlist (transient)
  persist        — on + disable SystemUI/Launcher/zte.web (tracked)
  off / restore  — Re-enable the ones we disabled

Inspection:
  status         — General state
  preview        — How many 'on' would kill (without running it)
  list / keep    — The allowlist
  disabled       — Tracked list (packages the bot disabled)

Per package:
  disable <pkg>  — Disable one package + add to tracked list
  enable <pkg>   — Re-enable one package from the tracked list"

    # ─── /perf_balanced ──────────────────────────────────────────────
    [pb_header]="⚖️ Perf Balanced — current caps:"
    [pb_policy_fmt]="  %s: cap=%d MHz  (hw_max=%d MHz)\n"
    [pb_hint_on]="Performance hint: ON 🟢 → big cluster wakeable"
    [pb_hint_off]="Performance hint: OFF ⚪ → big cluster offline
   For /perf_balanced to have effect: /performance on + reboot"
    [pb_hint_unread]="Performance hint: ? (unreadable)"
    [pb_usage]="To apply: /perf_balanced [mhz]   (default 1800)
To reset:  /perf_balanced reset"
    [pb_reset_fmt]="✅ %d policy cap(s) reset (opened to hw max).
Performance hint was not changed."
    [pb_invalid_mhz_fmt]="❌ Invalid mhz: %s
Usage: /perf_balanced [mhz|reset]"
    [pb_too_low]="❌ Minimum 500 MHz"
    [pb_too_high]="❌ Maximum 3000 MHz"
    [pb_no_clusters]="❌ Could not apply to any cluster"
    [pb_warn_hint_off]="

⚠ Performance hint OFF — big cluster has been offline since boot.
  For full benefit: /performance on → reboot → run this command again."
    [pb_applied_fmt]="⚖️ Perf Balanced applied (%d cluster(s)):%s
%s

Cap resets on reboot (sysfs is RAM-only — zero risk)."

    # ─── /update ──────────────────────────────────────────────────────
    [update_header]="🔍 Module update check"
    [update_remote_unread_fmt]="  %s: %s  ⚠ remote unreachable"
    [update_parse_fail_fmt]="  %s: %s  ⚠ JSON parse error"
    [update_outdated_fmt]="  📦 %s: %s → %s (vCode %d→%d) ⬆"
    [update_uptodate_fmt]="  ✓ %s: %s (up to date)"
    [update_none_defined]="No module has updateJson defined."
    [update_all_current]="All modules are up to date."
    [update_count_outdated_fmt]="%d module(s) can be updated.
Update all: /update all
One by one: /update <module-id>"
    [update_all_start]="📥 Checking and installing all updates…"
    [update_no_zipurl_fmt]="  %s: zipUrl missing, skipped"
    [update_downloading_fmt]="  ⬇ Downloading %s %s…"
    [update_installed_fmt]="  ✅ %s → %s"
    [update_install_failed_fmt]="  ❌ %s install failed"
    [update_download_failed_fmt]="  ❌ %s download failed"
    [update_summary_fmt]="📊 Summary: %d checked, %d updated, %d failed"
    [update_reboot_hint]="
If binaries changed, reboot for full effect.
If statusbot itself was updated, it restarts within 10 s (supervisor)."
    [update_module_not_found_fmt]="❌ Module not found: %s
For the list: /update"
    [update_no_updatejson_fmt]="❌ %s has no updateJson defined"
    [update_remote_unread_long_fmt]="❌ Remote unreachable: %s"
    [update_already_current_fmt]="✓ %s already up to date (%s)"
    [update_download_failed]="❌ Download failed"
    [update_self_installed_fmt]="✅ statusbot %s installed, bot will restart in 5 s…"
    [update_other_installed_fmt]="✅ %s %s installed
If a binary changed, reboot is recommended."
    [update_install_failed_long_fmt]="❌ Install failed:
%s"

    # ─── /tailscale ───────────────────────────────────────────────────
    [ts_binary_missing]="❌ tailscale binaries not found.
Searched paths:
  /system/bin/{tailscale,tailscaled}
  /data/adb/modules/tailscale-control/system/bin/
  /data/adb/modules_update/tailscale-control/system/bin/
Install the tailscale-control module."
    [ts_status_on_fmt]="Tailscale: 🟢 ON
PID: %s  (RSS: %d MB)
IP:  %s
%s

Other commands: /tailscale {on|off|auth|ip|peers|logout|log}"
    [ts_ip_pending]="(awaiting login)"
    [ts_status_off_fmt]="Tailscale: 🔴 OFF
%s"
    [ts_hint_on]="To turn on: /tailscale on"
    [ts_hint_auth_first]="First: /tailscale auth <key>   then: /tailscale on"
    [ts_already_running]="Already running. /tailscale status"
    [ts_daemon_failed_fmt]="❌ tailscaled didn't start. Last log:
%s"
    [ts_active_fmt]="✅ Tailscale active
IP: %s
Exit-node: advertised (approve from admin panel)
Routing: adaptive (follows the current default route)"
    [ts_login_required_fmt]="🔑 Login required:
%s

Open this in a browser; once approved, the device will auto-connect."
    [ts_up_response_fmt]="⚠️ Up response:
%s"
    [ts_already_off]="Already off (orphan iptables cleaned up)"
    [ts_stopped]="🔴 Tailscale stopped
iptables rules removed
(VPN was not touched)"
    [ts_auth_usage]="Usage: /tailscale auth <tsauth-key>
Tailscale admin > Settings > Keys > Generate
Recommended: reusable + ephemeral"
    [ts_auth_saved_fmt]="🔑 Auth key saved (%d bytes).
Now: /tailscale on"
    [ts_logout_done]="👋 Logout
State + authkey wiped"
    [ts_off_short]="Tailscale is off"
    [ts_log_none]="No log yet"
    [ts_log_header]="📝 tailscaled last 20 lines:"
    [ts_usage]="Usage: /tailscale [on|off|status|auth|ip|peers|logout|log]"

    # ─── /performance ─────────────────────────────────────────────────
    [perf_status_on]="⚡ Performance Mode: ON 🟢
To turn off: /performance off"
    [perf_status_off]="⚡ Performance Mode: OFF ⚪
To turn on: /performance on"
    [perf_status_unread_fmt]="⚠️ Could not read state: %s"
    [perf_no_password]="❌ ZTE password not set. First run: /zte_setpw <password>"
    [perf_login_failed]="❌ ZTE login failed. Wrong password? Update via /zte_setpw."
    [perf_login_failed_short]="❌ ZTE login failed."
    [perf_set_failed_fmt]="❌ Set failed: %s"
    [perf_enabled_reboot]="⚡ Performance Mode ENABLED 🟢
Reboot the device for the change to take effect."
    [perf_disabled_reboot]="⚡ Performance Mode DISABLED ⚪
Reboot the device for the change to take effect."
    [perf_usage]="Usage: /performance [on|off|status]"

    # ─── /zte_setpw ──────────────────────────────────────────────────
    [zte_pw_set_fmt]="ZTE password is set (length: %d bytes).
To change: /zte_setpw <new_password>"
    [zte_pw_usage]="Usage: /zte_setpw <password>
(ZTE web admin password — used by /performance and similar)"
    [zte_pw_saved_fmt]="✓ ZTE password saved (%d bytes).
Test: /performance"

    # ─── /iptal ──────────────────────────────────────────────────────
    [iptal_imei]="  ✓ IMEI query"
    [iptal_upload]="  ✓ Pending upload"
    [iptal_speedtest]="  ✓ Speedtest loop"
    [iptal_none]="Nothing pending to cancel"
    [iptal_done_fmt]="🛑 Cancelled:%s"

    # ─── /reboot ─────────────────────────────────────────────────────
    [reboot_starting]="🔁 Reboot starting…"
    [reboot_expired]="⚠️ Timed out. Issue /reboot again first."
    [reboot_confirm]="⚠️ Confirm: type \"/reboot YES\" within 60 s."

    # ─── /version ────────────────────────────────────────────────────
    [version_fmt]="🤖 Bot %s
📱 %s
🏷  %s
🤖 Android %s (SDK %s)
🐧 %s"

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
