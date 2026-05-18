# statusbot — Translations

statusbot's UI is translatable. The bot's user-facing messages live in
`lang/<code>.sh` files in this directory. The default language is **English**
(`en.sh`).

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
/lang en         # switch to English
/lang tr         # switch to Turkish
…
```

After `/lang <code>` the bot writes the choice to `/data/statusbot/lang`
and restarts within ~3 s. Reboot survives the choice.

## Adding a new language

1. Copy `lang/en.sh` to `lang/<your-code>.sh` (use a [BCP 47](https://www.rfc-editor.org/rfc/rfc5646) primary tag — `de`, `fr`, `es`, `ru`, `ar`, `zh`, `ja`, …).
2. Translate every value on the right of `=`.
3. **Do not change** the keys (left side of `=`) or the number of `%s`
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
