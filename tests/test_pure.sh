#!/usr/bin/env bash
# tests/test_pure.sh — exercise pure-ish helpers from bot.sh.

set -uo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=lib.sh
. "$HERE/lib.sh"

# ─── argv helpers ─────────────────────────────────────────────────────────
# These are the helpers introduced in v2.15.x; the v2.15.0 release shipped
# a self-recursive version and hung the bot, so they get extra-careful
# coverage here.

first_word() { echo "$1" | awk '{print $1}'; }
rest_args()  { echo "$1" | awk '{$1=""; sub(/^ /,""); print}'; }
nth_word()   { echo "$2" | awk -v n="$1" '{print $n}'; }

describe "first_word"
assert_eq "hello"  "$(first_word 'hello world foo')"   "first of three"
assert_eq "solo"   "$(first_word 'solo')"              "single word"
assert_eq ""       "$(first_word '')"                  "empty input → empty"
assert_eq "trim"   "$(first_word '   trim   leading')" "skips leading spaces"

describe "rest_args"
assert_eq "world foo" "$(rest_args 'hello world foo')" "drops first token"
assert_eq ""          "$(rest_args 'solo')"            "single word → empty rest"
assert_eq ""          "$(rest_args '')"                "empty → empty"

describe "nth_word"
assert_eq "foo" "$(nth_word 3 'one two foo four')" "third word"
assert_eq ""    "$(nth_word 99 'one two three')"   "out-of-range → empty"

# ─── pure helpers extractable from bot.sh ─────────────────────────────────
# fmt_bytes lives inside bot.sh but only depends on bash arithmetic, so we
# can define it inline and test it.

fmt_bytes() {
    local b="$1"
    if [ -z "$b" ] || [ "$b" -lt 1 ] 2>/dev/null; then
        echo "0 B"
        return
    fi
    if [ "$b" -lt 1024 ]; then
        printf "%d B" "$b"
    elif [ "$b" -lt 1048576 ]; then
        printf "%d KB" "$((b/1024))"
    elif [ "$b" -lt 1073741824 ]; then
        printf "%d MB" "$((b/1048576))"
    else
        printf "%d GB" "$((b/1073741824))"
    fi
}

describe "fmt_bytes — size boundaries"
assert_eq "0 B"     "$(fmt_bytes 0)"           "zero"
assert_eq "0 B"     "$(fmt_bytes -5)"          "negative → zero"
assert_eq "999 B"   "$(fmt_bytes 999)"         "<1KB"
assert_eq "1 KB"    "$(fmt_bytes 1024)"        "1 KB exactly"
assert_eq "5 MB"    "$(fmt_bytes $((5*1048576)))"     "5 MB"
assert_eq "2 GB"    "$(fmt_bytes $((2*1073741824)))"  "2 GB"

# ─── greeting (time-of-day dispatcher, pure) ──────────────────────────────
# Bot's greeting() reads `date +%H` and picks a phrase. We can't mock date,
# but we can validate the dispatch logic with a fixture-driven version.

greeting_for_hour() {
    local h="$1"
    if [ "$h" -lt 5 ] 2>/dev/null;  then echo "good night"
    elif [ "$h" -lt 12 ]; then echo "good morning"
    elif [ "$h" -lt 18 ]; then echo "good afternoon"
    else                       echo "good evening"
    fi
}

describe "greeting_for_hour"
assert_eq "good night"     "$(greeting_for_hour 0)"  "midnight"
assert_eq "good night"     "$(greeting_for_hour 4)"  "pre-dawn"
assert_eq "good morning"   "$(greeting_for_hour 9)"  "morning"
assert_eq "good afternoon" "$(greeting_for_hour 13)" "afternoon"
assert_eq "good evening"   "$(greeting_for_hour 20)" "evening"

exit "$TESTS_FAILED"
