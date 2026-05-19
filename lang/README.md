# statusbot — Translations

statusbot's UI is translatable. The bot's user-facing messages live in
`lang/<code>.sh` files in this directory. The default language is **English**
(`en.sh`).

## Available languages (v2.11.0)

| Code | Language | Keys translated | Maintainer |
|---|---|---|---|
| `en` | **English** *(default + fallback)* | 449 / 449 ✅ full | upstream |
| `tr` | **Türkçe** | 449 / 449 ✅ full | upstream |
| `es` | Español | 96 / 449 (high-frequency) | seeded |
| `de` | Deutsch | 74 / 449 (high-frequency) | seeded |
| `fr` | Français | 74 / 449 (high-frequency) | seeded |
| `pt` | Português | 74 / 449 (high-frequency) | seeded |
| `ru` | Русский | 74 / 449 (high-frequency) | seeded |
| `zh` | 简体中文 (Mandarin) | 74 / 449 (high-frequency) | seeded |
| `ja` | 日本語 | 74 / 449 (high-frequency) | seeded |
| `ko` | 한국어 | 74 / 449 (high-frequency) | seeded |
| `ar` | العربية | 74 / 449 (high-frequency) | seeded |
| `hi` | हिन्दी | 74 / 449 (high-frequency) | seeded |

"Seeded" = community-maintained starter translations covering the most
visible strings (help text, /status, /performance, /lang, alerts, common
errors, chat triggers). The remaining keys gracefully fall back to English
when an entry is missing — the bot is fully functional in every language,
just with English filling the gaps where translation isn't done yet.

**Want to extend a language?** Copy keys from `en.sh` into your `lang/<code>.sh`
and translate the values. PRs welcome at
[magisk-zte-f50-statusbot](https://github.com/dikeckaan/magisk-zte-f50-statusbot).

## How loading works

`bot.sh` sources translations at startup:

1. `lang/en.sh` is sourced first — provides the complete fallback set.
2. If the user has selected a different language (via `/lang <code>` in chat),
   the contents of `/data/statusbot/lang` (e.g. `tr`) determine which other
   file to source — that file's keys **override** English.
3. Any key missing from a non-English file gracefully falls back to the
   English value, so partial translations never break the bot.

## Switching languages from the bot

```
/lang            # show current language + the available ones
/lang en         # English
/lang tr         # Türkçe
/lang es         # Español
/lang de         # Deutsch
/lang fr         # Français
/lang pt         # Português
/lang ru         # Русский
/lang zh         # 简体中文
/lang ja         # 日本語
/lang ko         # 한국어
/lang ar         # العربية
/lang hi         # हिन्दी
```

After `/lang <code>` the bot writes the choice to `/data/statusbot/lang`
and restarts within ~3 s. Survives reboot. The Telegram side-menu
(`setMyCommands`) is re-registered each language change.

## Adding a new language

1. Copy `lang/en.sh` to `lang/<your-code>.sh` (use a [BCP 47](https://www.rfc-editor.org/rfc/rfc5646) primary tag — `de`, `fr`, `es`, `ru`, `ar`, `zh`, `ja`, `it`, …).
2. Translate every value on the right of `=`.
3. **Do not change** the keys (left side of `=`) or the number of `%s`/`%d`
   placeholders in `_fmt` templates — they must match the call sites in
   `bot.sh`.
4. Multi-line strings: just put real newlines inside the double-quoted value:
   ```bash
   [help_header]="Line one
   Line two
   Line three"
   ```
5. Do **not** embed `$(...)` command substitution in the value — it would
   evaluate at source time, not at use time. Use `%s` placeholders and pass
   the dynamic value via `printf` / the `tf` helper at the call site.
6. Test: copy the new file to `/data/adb/modules/statusbot/lang/`, then
   `/lang <your-code>` from the chat. Run `/help` and a few representative
   commands to spot-check.
7. Open a PR to [magisk-zte-f50-statusbot](https://github.com/dikeckaan/magisk-zte-f50-statusbot).

## File format quick-reference

```bash
declare -gA MSG=(
    [key]="static value"
    [other_key]="template with %s and %s placeholders"
    [multiline]="line 1
line 2"
)
```

`declare -gA` requires bash 4+ (we ship bash 5.2 via `bin-utils`).

## Partial translations are welcome

You don't need to translate all 449 keys to add a language. Even translating
just `/help`, `/status`, greetings, and the most common errors massively
improves UX for speakers of that language. Missing keys fall back to English.
