# statusbot Deutsch — community translation seeded by upstream
# Sourced AFTER en.sh; keys here override English. Missing keys fall back.

declare -gA MSG=(
    [lang_current_fmt]="Aktuelle Sprache: %s"
    [lang_available_header]="Verfügbare Sprachen:"
    [lang_set_fmt]="Sprache geändert zu %s. Der Bot startet in 3 s neu."
    [lang_invalid_fmt]="Unbekannter Sprachcode: %s. Siehe /lang für die Liste."
    [lang_usage]="Verwendung: /lang [code]
Ohne Argument: aktuelle + verfügbare Sprachen.
Mit Code: wechselt und startet den Bot neu."

    [greet_morning]="Guten Morgen"
    [greet_noon]="Guten Tag"
    [greet_evening]="Guten Abend"
    [greet_night]="Gute Nacht"
    [boot_greeting_fmt]="%s, ich bin online 🤖
%s — Uptime: %s
Tippe /help für Befehle."

    [help_full_fmt]="ZTE F50 Bot — Befehle

📊 Status
/status — Vollständige Übersicht
/uptime — Laufzeit
/load — CPU-Last (detailliert)
/mem — RAM
/disk — Festplatte
/temp — Temperatur (CPU)
/ps — Top 10 Prozesse (CPU)

📡 Mobilfunk
/signal — Signalqualität (RSSI, RSRP, RSRQ)
/cellinfo — Netzbetreiber + IMEI + ICCID + Nummer
/imei — IMEI(s)
/imei_sorgula [imei] — IMEI Analyse + e-Devlet Lookup
/imei_degis <imei> — IMEI ändern (bestätigt, Neustart)
/operator — nur Netzbetreiber
/qos — QoS / Band-Details
/sms_list [N] — letzte N SMS (Standard 10)
/sms_count — Posteingang gesamt
/sms_send <num> <text> — SMS via AT senden
/at <cmd> — AT-Befehl ausführen

🌐 Netzwerk
/ip — Öffentliche + lokale IPs
/traffic — RX/TX seit Boot
/ping <host>
/speedtest [cf|ookla|fast] [size] — Geschwindigkeitstest
/clients — verbundene Clients (ARP)
/wifi — Hotspot SSID + Passwort + Clients
/tunnel — Cloudflared-Status

🔧 System
/modules — Magisk-Module
/version
/reboot — Neustart (Bestätigung)
/komut <cmd> — Shell-Befehl (abbrechbar)
/file <pfad> — Datei vom Gerät holen
/upload <ziel> — Datei zum Gerät pushen
/screenshot — Vollbild PNG
/ramclean [pkg…] — Speicherbereinigung
/performance [on|off] — ZTE Performance-Modus (Neustart nötig)
/perf_balanced [mhz] — 8-Kern + Freq-Cap (empfohlen, 1800)
/perf_help — Modus-Vergleich
/minimal_mode [on|persist|off] — Dienste einfrieren (~640 MB)
/zte_setpw <pwd> — ZTE Admin-Passwort setzen
/lang [code] — Bot-Sprache wechseln

🗂 Dateisystem
/ls <pfad>
/cat <datei> — Inhalt (4 KB)
/df — Plattennutzung
/du <dir> — Unterverzeichnisgrößen
/log [N] — Letzte N Zeilen Bot-Log
/dump_sms — Voller Posteingang-Dump

🌐 Netzwerk (Extras)
/connections — aktive TCP-Verbindungen
/listening — lauschende Ports
/dhcp — DHCP-Lease-Tabelle
/dns — DNS-Konfiguration

⚡ Energie / Kernel
/cpu_freq — CPU-Frequenzen
/cpu_governor [name] — Governor anzeigen/ändern
/wakelock — aktive Wakelocks

📦 Apps
/installed [3rd|disabled|system|all]
/freeze <pkg> — Paket einfrieren
/unfreeze <pkg> — Paket aktivieren

⏰ Zeitplanung
/alarm HH:MM <msg> — einmalig
/schedule <sec> <cmd> — wiederkehrend
/schedule list / clear / cancel <idx>
/heartbeat <stunden> — periodisches Lebenszeichen
/quiet_hours <von> <bis> — Stille Stunden

🔒 Sicherheit
/who — aktive SSH/ADB-Sitzungen
/last_boot — Boot-Historie
/bot_stats — Bot-interne Stats
/restart_bot — Bot neu starten
/update [all|<id>] — Module von GitHub aktualisieren

🌍 Tailscale (optionales Modul)
/tailscale auth <key> — Auth-Key speichern
/tailscale on / off — starten/stoppen
/tailscale status — Status + RAM
/tailscale ip / peers / log / logout

🔔 Automatisch (Hintergrund):
• Eingehende SMS werden weitergeleitet
• Warnungen bei Temp > %d°C, RAM < %d%%, Tunnel down
• Heartbeat (falls konfiguriert) und Schedules
• Quiet Hours unterdrücken Alarme

💬 Chat-Auslöser
selam, merhaba, sa — Begrüßung
naber — Status + Begrüßung
saat — Geräte-Uhrzeit
iyi misin — Statusabfrage"

    [uptime_days_fmt]="%d T %02d h %02d m"
    [uptime_hours_fmt]="%d h %02d m"
    [uptime_short_fmt]="%d m %02d s"
    [disk_fmt]="%s / %s (%s belegt)"

    [load_status_calm]="🟢 ruhig (%d%%)"
    [load_status_active]="🟡 aktiv (%d%%)"
    [load_status_full]="🟠 voll (%d%%)"
    [load_status_busy]="🔴 beschäftigt (%d%%)"
    [load_full_fmt]="📊 CPU-Last (%d Kerne)

Jetzt (1 min):     %s
Letzte 5 min:      %s
Letzte 15 min:     %s

Status: %s

Hinweis:
  %d.0 = alle CPUs voll ausgelastet
  < %d.0 = Kapazität verfügbar
  > %d.0 = Warteschlange, mögliche Verzögerungen"

    [status_model_fmt]="📱 %s\n"
    [status_uptime_fmt]="⏱  Uptime: %s\n"
    [status_ram_fmt]="💾 RAM: %s\n"
    [status_disk_fmt]="💿 Disk: %s\n"
    [status_temp_fmt]="🌡  Temperatur: %s\n"
    [status_perf_on]="⚡ Performance: ON 🟢\n"
    [status_perf_off]="⚡ Performance: OFF ⚪\n"
    [status_operator_fmt]="📡 Netzbetreiber: %s\n"
    [status_signal_fmt]="📶 Signal: RSSI %s (%s)\n"
    [status_public_ip_fmt]="🌐 Öffentliche IP: %s"

    [perf_status_on]="⚡ Performance-Modus: AN 🟢
Zum Ausschalten: /performance off"
    [perf_status_off]="⚡ Performance-Modus: AUS ⚪
Zum Einschalten: /performance on"
    [perf_no_password]="❌ ZTE-Passwort nicht gesetzt. Zuerst: /zte_setpw <pwd>"
    [perf_login_failed]="❌ ZTE Login fehlgeschlagen. Falsches Passwort? Aktualisiere mit /zte_setpw."
    [perf_login_failed_short]="❌ ZTE Login fehlgeschlagen."
    [perf_set_failed_fmt]="❌ Set fehlgeschlagen: %s"
    [perf_enabled_reboot]="⚡ Performance-Modus AKTIVIERT 🟢
Starte das Gerät neu, damit die Änderung wirksam wird."
    [perf_disabled_reboot]="⚡ Performance-Modus DEAKTIVIERT ⚪
Starte das Gerät neu, damit die Änderung wirksam wird."
    [perf_usage]="Verwendung: /performance [on|off|status]"

    [zte_pw_set_fmt]="ZTE-Passwort gesetzt (Länge: %d Bytes).
Zum Ändern: /zte_setpw <neues_pwd>"
    [zte_pw_usage]="Verwendung: /zte_setpw <pwd>
(ZTE Web-Admin-Passwort — für /performance etc.)"
    [zte_pw_saved_fmt]="✓ ZTE-Passwort gespeichert (%d Bytes).
Test: /performance"
    [iptal_imei]="  ✓ IMEI-Abfrage"
    [iptal_upload]="  ✓ Ausstehender Upload"
    [iptal_speedtest]="  ✓ Speedtest-Schleife"
    [iptal_none]="Nichts ausstehend zum Abbrechen"
    [iptal_done_fmt]="🛑 Abgebrochen:%s"
    [reboot_starting]="🔁 Neustart wird ausgeführt…"
    [reboot_expired]="⚠️ Zeit abgelaufen. Führe /reboot erneut aus."
    [reboot_confirm]="⚠️ Bestätige: tippe \"/reboot YES\" innerhalb von 60 s."
    [version_fmt]="🤖 Bot %s
📱 %s
🏷  %s
🤖 Android %s (SDK %s)
🐧 %s"

    [common_not_exists_fmt]="❌ Existiert nicht: %s"
    [btn_cancel]="❌ Abbrechen"
    [btn_reboot_now]="🔁 Jetzt Neustarten"

    [csq_excellent]="🟢 Ausgezeichnet"
    [csq_good]="🟢 Gut"
    [csq_moderate]="🟡 Mäßig"
    [csq_weak]="🟠 Schwach"
    [csq_very_weak]="🔴 Sehr schwach"
    [csq_unknown]="🔴 Unbekannt"

    [alert_temp_fmt]="🌡 WARNUNG: CPU-Temperatur hoch — %d°C
(Schwelle %d°C, keine erneute Warnung für %d s)"
    [alert_mem_fmt]="💾 WARNUNG: RAM sehr niedrig — %d%% verfügbar
(%d MB)"
    [alert_tunnel]="🔌 WARNUNG: Cloudflared-Tunnel läuft nicht (kein Prozess)"
    [alert_sms_forward_fmt]="📨 Eingehende SMS — %s
👤 %s

%s"

    [chat_greeting_fmt]="%s, hier bin ich 👋"
    [chat_naber_fmt]="%s! Mein Status:

%s"
    [chat_time_fmt]="🕐 %s"
    [chat_imisin_fmt]="Mir geht's gut 🙂 (temp %s, uptime %s)"
    [chat_thanks]="🤖 Gern geschehen 👍"
    [chat_morning_fmt]="Guten Morgen! ☀️ %s seit dem Start"
    [chat_night]="Dir auch 🌙 ich bleibe wach"

    [update_header]="🔍 Modul-Update-Prüfung"
    [update_all_current]="Alle Module sind aktuell."
    [update_none_defined]="Kein Modul hat updateJson definiert."
)
