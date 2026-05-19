# shellcheck shell=bash
# tests/lib.sh — assertion + mock helpers for the statusbot test harness.
#
# Source from individual tests/test_*.sh files. Each test prints PASS/FAIL
# lines and increments TESTS_RAN / TESTS_FAILED. tests/run.sh aggregates.

: "${TESTS_RAN:=0}"
: "${TESTS_FAILED:=0}"
: "${CURRENT_TEST_NAME:=}"

# assert_eq <expected> <actual> [description]
assert_eq() {
    local expected="$1" actual="$2" desc="${3:-assertion}"
    TESTS_RAN=$((TESTS_RAN + 1))
    if [ "$expected" = "$actual" ]; then
        printf '  ✓ %s\n' "$desc"
    else
        printf '  ✗ %s\n    expected: %s\n    actual:   %s\n' "$desc" "$expected" "$actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# assert_match <regex> <actual> [description]
assert_match() {
    local re="$1" actual="$2" desc="${3:-pattern match}"
    TESTS_RAN=$((TESTS_RAN + 1))
    if echo "$actual" | grep -qE "$re"; then
        printf '  ✓ %s\n' "$desc"
    else
        printf '  ✗ %s\n    regex:    %s\n    actual:   %s\n' "$desc" "$re" "$actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# assert_rc <expected_rc> <command...>
# Runs the command, captures rc, asserts.
assert_rc() {
    local expected="$1"; shift
    local desc="rc=$expected: $*"
    TESTS_RAN=$((TESTS_RAN + 1))
    "$@" >/dev/null 2>&1
    local actual=$?
    if [ "$expected" -eq "$actual" ]; then
        printf '  ✓ %s\n' "$desc"
    else
        printf '  ✗ %s (got rc=%s)\n' "$desc" "$actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# describe <name>  — print a heading line + remember test name
describe() {
    CURRENT_TEST_NAME="$1"
    printf '\n▶ %s\n' "$1"
}

# mock_command <name> <body>
# Defines a function that shadows the command on $PATH for the rest of
# the shell. Use to stub curl, jq, magisk, etc.
mock_command() {
    eval "$1() { $2; }"
    export -f "$1" 2>/dev/null || true
}

# unmock_command <name>
unmock_command() {
    unset -f "$1" 2>/dev/null || true
}
