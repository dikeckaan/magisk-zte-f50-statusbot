# Changelog

## v2.13.1 — 2026-05-19
- **Inline Reboot button** after a module install or update succeeds.
  `/update`, `/update <id>`, `/install <id>`, `/adguard install`, and
  `/traffic_history install` now end their reply with a tappable
  "🔁 Reboot Now" button when something was actually flashed and a
  reboot is required for activation. Tapping it triggers the existing
  `reboot_now` callback.
- **Fixed**: `tg_send_with_reboot` was sending the literal string
  `${MSG[btn_reboot_now]}` as the button label because the JSON was
  single-quoted (no expansion). The button now renders the localised
  "Reboot Now" label from the lang file.
- New convention: any command can append `<<REBOOT_BUTTON>>` on its own
  line to its output, and the dispatcher will strip that line and attach
  the inline reboot button. This complements the older
  `REBOOT_PROMPT|<text>` prefix used by `/performance`.

## v2.13.0 — 2026-05-19
- **`/install [list|<id>]`** — bot-side optional-module installer. Reads
  each module's `updateJson` from a built-in catalog, downloads the zip,
  and calls `magisk --install-module`. No more manual ADB flashing for
  optional modules.
- Current catalog: `adguardhome`, `traffic-stats`. Friendly aliases
  recognised: `/install adguard` → `adguardhome`, `/install traffic`
  → `traffic-stats`.
- `/install list` prints what's installed and what's still available.
- `/adguard install` and `/traffic_history install` are shortcuts for
  the same flow.
- 14 new lang keys (en + tr); other languages fall back to English.

## v2.12.0 — 2026-05-19
- **`/traffic_history [iface]`** — reads the
  [traffic-stats](https://github.com/dikeckaan/magisk-zte-f50-traffic-stats)
  vnstat-lite DB at `/data/traffic-stats/` and reports per-interface
  Today / 7-day / Month RX+TX totals. Optional iface arg filters to a
  single interface (e.g. `/traffic_history sipa_eth0` for just cellular).
- **`/adguard {status|on|off|log|url}`** — controls the
  [adguardhome](https://github.com/dikeckaan/magisk-zte-f50-adguardhome)
  daemon. `status` reports PID, RAM, today's query / blocked counts.
  `on`/`off` start and stop the daemon (frees ~50–80 MB when off).
  `log` tails the supervisor log. `url` prints the web UI URL using the
  live `br0` gateway IP.
- Both new commands appear in the Telegram side-menu and are translated
  in `en.sh` + `tr.sh` (16 new keys each). Other languages fall back to
  English as usual.
- No new external deps — both integrations just read filesystem state
  and call iptables / pkill / nohup.

## v2.11.0
- **10 new community-seeded translations**: Spanish, German, French,
  Portuguese, Russian, Mandarin (Simplified), Japanese, Korean, Arabic,
  Hindi (`es`, `de`, `fr`, `pt`, `ru`, `zh`, `ja`, `ko`, `ar`, `hi`).
- Each new language covers ~74 high-frequency keys (help text, /status,
  /performance, /lang, alerts, common errors, chat replies). Missing keys
  fall back to English — bot stays fully functional in every language.
- Total: **12 languages** now selectable via `/lang <code>`.
- README + `lang/README.md` updated with the full language matrix.
- The Telegram side-menu (`setMyCommands`) is still EN/TR-only for now;
  English fallback applies in other languages for menu descriptions.

## v2.10.2
- **Telegram /-menu fully translated**: setMyCommands descriptions now switch
  with /lang en|tr (re-registered each language change).
- 67 new `[desc_*]` keys in en.sh and tr.sh.
- `register_commands()` builds JSON dynamically from `$MSG[desc_<cmd>]` using
  an ordered `CMDS_ORDER` list and a `json_escape` helper.

## v2.10.1
- **i18n migration complete**: ~95% of user-facing strings now load from `lang/<code>.sh`
- 381 translation keys per language (EN + TR fully populated)
- Migrated: `/help`, `/perf_help`, `/status` + all `fmt_*` helpers, `/performance`, `/zte_setpw`, `/iptal`, `/reboot`, `/version`, `/lang`, `/tailscale`, `/update`, `/perf_balanced`, `/minimal_mode`, `/speedtest` (cf/ookla/fast), `/quiet_hours`, `/heartbeat`, `/alarm`, `/schedule`, `/file`, `/upload`, `/screenshot`, `/wifi`, `/at`, `/ramclean`, `/airplane`, `/sms_send`, `/sms_count`, `/sms_list`, `/cellinfo`, `/ip`, `/clients`, `/modules`, `/tunnel`, `/ping`, `/ls`, `/cat`, `/df`, `/du`, `/cpu_freq`, `/cpu_governor`, `/wakelock`, `/freeze`, `/unfreeze`, `/installed`, `/who`, `/last_boot`, `/log`, `/dump_sms`, `/bot_stats`, `/restart_bot`, `/imei`, `/imei_sorgula`, `/imei_degis`, `/komut`, chat triggers, boot greeting, all alerts and pollers
- Remaining 56 TR-character lines are bash case patterns matching Turkish user input (e.g. `selam|merhaba`) and the `register_commands` setMyCommands JSON (Telegram menu — separate consideration)

## v2.10.0
- **NEW: Multi-language UI** — bot messages in English (default) + Turkish; community translations via `lang/<code>.sh`
- New `/lang [code]` command to switch UI language at runtime (bot auto-restarts)
- Bot script now runs under bash (provided by bin-utils v1.2.0+) for associative arrays + `printf -v`
- Service supervisor (`service.sh`) detects bash from any of `/system/bin`, `/data/adb/modules/bin-utils`, or `/data/adb/modules_update/bin-utils` — works pre/post-reboot
- Fall-through: missing keys in a translation file fall back to English (silent recovery, never broken UI)

## v2.9.0
- `/update [all|<id>]` — pull module updates from GitHub releases via `updateJson`
- `/speedtest` adds Ookla CLI + fast.com providers, loop mode
- `/perf_balanced [mhz]` — 8-core + freq cap (balanced thermal vs throughput)
- `/minimal_mode` — allowlist-based service freezing (transient + persistent)
- `/tailscale` integration with `tailscale-control` module
- Initial public release on GitHub

## v2.8.0
- 28 new commands: filesystem, network, power, app management, scheduling

## v2.7.0
- /ramclean nuke mode + protected list improvements

## earlier
- Internal Turkish-only releases
