#!/usr/bin/env bash
# Validate lang/*.sh files for completeness and correctness.
#
# Checks:
#   1. Every partial language file's keys must also exist in en.sh
#      (a partial-only key would never be displayed — dead entry).
#   2. For every key shared with en.sh, the printf %s count must match.
#   3. No duplicate keys within a single file.
#
# Also smoke-tests bot.sh's argv helpers (first_word, rest_args,
# nth_word) to guard against regressions like the v2.15.0 self-recursion
# infinite-loop bug.
#
# Exit 0 = clean, 1 = problems.

set -eu

LANG_DIR=${1:-$(dirname "$0")}
EN="$LANG_DIR/en.sh"
[ -r "$EN" ] || { echo "ERROR: $EN not readable"; exit 1; }

# Source one lang file inside a subshell, then emit "key<TAB>%s_count"
# for every MSG entry. Sub-shell isolation so caller's vars stay clean.
dump_keys() {
    local f="$1"
    "${BASH:-bash}" <<EOF
declare -gA MSG
. "$f"
for k in "\${!MSG[@]}"; do
    v="\${MSG[\$k]}"
    # Count printf format specs: strip literal %% first, then count
    # %<letter> conversions (covers s, d, i, u, x, X, f, e, g, c, b).
    count=\$(printf '%s' "\$v" | sed 's/%%/X/g' | grep -oE '%[a-zA-Z]' | wc -l)
    printf '%s\t%s\n' "\$k" "\$count"
done
EOF
}

detect_duplicates() {
    grep -oE '^\s*\[[A-Za-z0-9_]+\]=' "$1" \
        | tr -d ' []=' \
        | sort | uniq -d
}

echo "=== Validating lang files ==="
echo

EN_DUMP=$(dump_keys "$EN")
EN_COUNT=$(printf '%s\n' "$EN_DUMP" | wc -l | tr -d ' ')
echo "Reference: en.sh — $EN_COUNT keys"
EN_DUPES=$(detect_duplicates "$EN" || true)
if [ -n "$EN_DUPES" ]; then
    echo "  ❌ Duplicate keys in en.sh:"
    echo "$EN_DUPES" | sed 's/^/    /'
    EXIT=1
fi

EN_KEYFILE=$(mktemp)
printf '%s\n' "$EN_DUMP" | sort > "$EN_KEYFILE"

EXIT=0
for f in "$LANG_DIR"/*.sh; do
    [ "$f" = "$EN" ] && continue
    [ "$f" = "$LANG_DIR/validate.sh" ] && continue
    code=$(basename "$f" .sh)
    DUMP=$(dump_keys "$f")
    n=$(printf '%s\n' "$DUMP" | wc -l | tr -d ' ')
    echo "Language: $code — $n keys"

    dupes=$(detect_duplicates "$f" || true)
    if [ -n "$dupes" ]; then
        echo "  ❌ Duplicate keys:"
        echo "$dupes" | sed 's/^/    /'
        EXIT=1
    fi

    dead=$(comm -23 <(printf '%s\n' "$DUMP" | cut -f1 | sort) \
                    <(cut -f1 "$EN_KEYFILE"))
    if [ -n "$dead" ]; then
        echo "  ⚠️  Dead keys (not in en.sh, never displayed):"
        echo "$dead" | sed 's/^/    /'
    fi

    mismatches=$(
        join -t "$(printf '\t')" \
            <(printf '%s\n' "$DUMP" | sort) \
            "$EN_KEYFILE" 2>/dev/null \
            | awk -F'\t' '$2 != $3 {printf "    %s: lang=%s, en=%s\n", $1, $2, $3}'
    )
    if [ -n "$mismatches" ]; then
        echo "  ❌ Placeholder %s count mismatches:"
        echo "$mismatches"
        EXIT=1
    fi
done
rm -f "$EN_KEYFILE"
echo

# ─── helper smoke-test (the v2.15.0 anti-recursion guard) ────────────────
echo "=== Helper smoke test (anti-recursion guard) ==="
BOT="$LANG_DIR/../bot/bot.sh"
if [ -r "$BOT" ]; then
    # Static check: the helper definitions must NOT call themselves.
    if grep -nE '^(first_word|rest_args|nth_word)\(\) \{[[:space:]]+(first_word|rest_args|nth_word)\b' "$BOT" >/dev/null; then
        echo "❌ Helper definition appears to self-call — infinite recursion risk!"
        grep -nE '^(first_word|rest_args|nth_word)\(\)' "$BOT" | sed 's/^/  /'
        EXIT=1
    fi
    # Runtime check: actually call them with known inputs.
    if bash -c '
        first_word() { echo "$1" | awk "{print \$1}"; }
        rest_args()  { echo "$1" | awk "{\$1=\"\"; sub(/^ /,\"\"); print}"; }
        nth_word()   { echo "$2" | awk -v n="$1" "{print \$n}"; }
        [ "$(first_word "hello world")" = "hello" ] || exit 1
        [ "$(rest_args  "hello world foo")" = "world foo" ] || exit 1
        [ "$(nth_word 2 "hello world foo")" = "world" ] || exit 1
    '; then
        echo "  ✓ first_word / rest_args / nth_word return correct values"
    else
        echo "  ❌ Helper smoke test FAILED"
        EXIT=1
    fi
else
    echo "  (skipped: bot.sh not found at $BOT)"
fi
echo

if [ "$EXIT" -eq 0 ]; then
    echo "✅ All checks passed."
else
    echo "❌ Some checks failed (see above)."
fi
exit $EXIT
