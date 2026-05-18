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
)
