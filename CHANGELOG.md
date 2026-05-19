# Changelog

## v2.15.2 — 2026-05-19
- **SHA-256 integrity verification** for `/install_module` and (by
  extension) the `/adguard install` / `/traffic_history install`
  shortcuts. `install_module_from_url` now reads `sha256` from the
  module's `update.json`, computes `sha256sum` of the downloaded zip,
  and aborts the install on mismatch instead of running `magisk
  --install-module` on a corrupted/MITM'd file.
- Older release JSONs that don't have the `sha256` field (pre-callable-
  workflow releases) get a warning line and proceed without
  verification — graceful degradation, no hard fail on legacy releases.
- 3 new MSG keys in en.sh + tr.sh: `install_sha_ok_fmt`,
  `install_sha_missing_fmt`, `install_sha_mismatch_fmt`.
- The new reusable release workflow at
  [f50-magisk-modules/.github/workflows/release-module.yml](https://github.com/dikeckaan/f50-magisk-modules/blob/main/.github/workflows/release-module.yml)
  populates `sha256` on every new release, so future bumps gain
  integrity by default.

## v2.15.1 — 2026-05-19  ⚠ Hotfix
- **CRITICAL FIX**: v2.15.0 was broken. The Phase 3 sed/perl substitution
  that replaced ~37 `echo "$X" | awk '{print $1}'` calls with the new
  `first_word "$X"` helper ALSO matched the helper definitions themselves,
  producing:
  ```
  first_word() { first_word "$1"; }    # infinite recursion
  rest_args()  { rest_args  "$1"; }    # infinite recursion
  ```
  Any command that hit dispatch (which calls `first_word "$text"` on
  every message) entered an infinite bash recursion. Per-request CPU
  exploded, the dispatch never returned, and Telegram never got a reply.
- Fix: restored the original `echo | awk` bodies inside the helpers
  (only the *call sites* should have been substituted, not the
  *definitions*). Added bash-syntax test that calls `first_word`
  and `rest_args` with sample input to lang_validator (Phase 5).

## v2.15.0 — 2026-05-19
- **bot.sh refactor**: introduce `first_word`, `rest_args`, `nth_word`
  helpers at the top of the file. Migrated ~30 inline
  `echo "$X" | awk '{print $1}'` subshells and 7 `awk '{$1="";...}'`
  rest-of-args extractions to use them. Net: ~37 fewer awk forks per
  command dispatch; same behaviour.
- **i18n leaks fixed**: `cmd_ls` and the SMS-list loop had hardcoded
  emoji + label strings (`📁 path` and `📨 when — addr`). They now use
  new MSG keys `ls_header_fmt` and `sms_line_fmt`. 3 new keys added
  to both en.sh and tr.sh (`ls_header_fmt`, `sms_line_fmt`,
  `komut_timeout_fmt`). Lang count: 486 → 489 in both languages.
- The previously hardcoded Turkish "⏱ Timeout (...sn)" string in
  poll_tasks's timeout branch now reads from `komut_timeout_fmt`.
- Function splits for `cmd_komut`/`cmd_tailscale`/`cmd_minimal_mode`/
  `cmd_update` deferred to Phase 8 (regression risk vs. benefit
  didn't justify in-place rewrites this pass).

## v2.14.2 — 2026-05-19
- **Service migration to `bin-utils/lib/common.sh`**. `service.sh` no longer
  duplicates `find_bash`, log rotation, or token-wait logic — it sources
  the shared helper library and calls `find_bash`, `wait_for_file`,
  `log_line`, `log_rotate` directly. Net: 54 → 41 lines.
- **`customize.sh` now hard-requires bin-utils v1.3.0+** at install time
  (the file `/data/adb/modules/bin-utils/lib/common.sh` must exist).
  Old "just check for curl/jq" guard is gone.

## v2.14.1 — 2026-05-19
- **Fixed**: `poll_tasks` sourced `$metafile` without pre-declaring locals;
  a corrupt/empty meta file could leak `chat_id` / `bot_msg_id` /
  `started` from a previous iteration, sending a `/komut` reply to the
  wrong message id. Now pre-declares + zeroes the trio on every loop
  iteration and aborts gracefully on parse failure or missing fields.
- (Investigation note: the alleged `printf "${MSG[komut_done_fmt]}" "$out"`
  format-injection bug from the audit turned out NOT to be exploitable —
  printf doesn't re-interpret `%` in positional args, only in the format
  string. Left a comment for future readers.)

## v2.14.0 — 2026-05-19
- **Renamed** `/install` → `/install_module` (clearer when paired with
  `/update`). Old `/install` and `/kur` aliases still work for now.
- **Manifest-driven catalog**: The list of installable modules now comes
  from `modules.json` in the
  [f50-magisk-modules](https://github.com/dikeckaan/f50-magisk-modules)
  aggregator repo, not from a hardcoded bash array. Adding a module to
  the ecosystem = one PR to that file; the bot picks it up on its next
  catalog refresh (10-min TTL cache at `/data/statusbot/.modules.json`).
- **All optional modules now installable from Telegram**:
  - `/install_module cloudflared-tunnel` (alias: tunnel, cf)
  - `/install_module dropbear-ssh` (alias: ssh, dropbear)
  - `/install_module wireless-adb-keeper` (alias: adb, wireless-adb)
  - `/install_module tailscale-control` (alias: tailscale, ts)
  - `/install_module adguardhome` (alias: adguard, agh, adblock)
  - `/install_module traffic-stats` (alias: traffic, vnstat)
- Friendly aliases are resolved from the manifest's `aliases[]` field.
- `/adguard install` and `/traffic_history install` shortcuts now delegate
  to `cmd_install_module` for consistency.

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
