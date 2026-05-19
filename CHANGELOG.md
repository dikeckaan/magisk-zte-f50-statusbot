# Changelog

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
