#!/usr/bin/env bash
# tests/run.sh — run every tests/test_*.sh and aggregate results.

set -uo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
cd "$HERE"

total_ran=0
total_failed=0
file_failed=0

# Use modern bash. On Mac the default is bash 3.2 which lacks associative
# arrays; on Android our static bash from bin-utils is 5.2.
BASH_BIN="${BASH:-bash}"

echo "==========================================="
echo "  statusbot — test suite"
echo "  bash: $($BASH_BIN --version | head -1)"
echo "==========================================="

for t in "$HERE"/test_*.sh; do
    [ -e "$t" ] || continue
    name=$(basename "$t" .sh)
    echo
    echo "═════ $name ═════"
    output=$("$BASH_BIN" "$t" 2>&1)
    rc=$?
    echo "$output"
    ran=$(echo "$output" | grep -cE '^\s*[✓✗] ')
    failed=$(echo "$output" | grep -cE '^\s*✗ ')
    total_ran=$((total_ran + ran))
    total_failed=$((total_failed + failed))
    [ "$rc" -ne 0 ] && file_failed=$((file_failed + 1))
done

echo
echo "==========================================="
printf "  Tests run:    %d\n" "$total_ran"
printf "  Passed:       %d\n" "$((total_ran - total_failed))"
printf "  Failed:       %d\n" "$total_failed"
printf "  Files failed: %d\n" "$file_failed"
echo "==========================================="

[ "$total_failed" -eq 0 ] && [ "$file_failed" -eq 0 ]
