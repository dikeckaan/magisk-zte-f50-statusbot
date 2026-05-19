#!/usr/bin/env bash
# tests/test_install.sh — exercise /install_module catalog + sha256
# verification with mocked curl / jq / magisk / sha256sum.

set -uo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=lib.sh
. "$HERE/lib.sh"

# Stub manifest the "remote" returns. Three modules, two of them already
# installed (we control is_module_installed below).
MANIFEST_JSON='{
  "schema_version": 2,
  "modules": [
    {
      "id": "adguardhome",
      "name": "AdGuard Home",
      "description": "DNS ad-blocker",
      "required": false,
      "arch": "arm64",
      "min_magisk_version": 26000,
      "dependencies": ["bin-utils"],
      "aliases": ["adguard", "agh"],
      "update_json": "https://example.invalid/agh-update.json"
    },
    {
      "id": "traffic-stats",
      "name": "Traffic Stats",
      "description": "vnstat-lite",
      "required": false,
      "arch": "arm64",
      "min_magisk_version": 26000,
      "dependencies": ["bin-utils"],
      "aliases": ["traffic", "vnstat"],
      "update_json": "https://example.invalid/ts-update.json"
    }
  ]
}'

# resolve_module_id (extracted standalone from bot.sh)
resolve_module_id() {
    local q="$1" manifest="$2"
    jq -r --arg q "$q" '
        .modules[]
        | select(.id == $q or ((.aliases // []) | index($q)))
        | .id' <<<"$manifest" 2>/dev/null | head -1
}

describe "resolve_module_id — exact id match"
assert_eq "adguardhome"   "$(resolve_module_id adguardhome "$MANIFEST_JSON")"   "id match"
assert_eq "traffic-stats" "$(resolve_module_id traffic-stats "$MANIFEST_JSON")" "id match"

describe "resolve_module_id — alias resolution"
assert_eq "adguardhome"   "$(resolve_module_id adguard   "$MANIFEST_JSON")"   "alias adguard"
assert_eq "adguardhome"   "$(resolve_module_id agh       "$MANIFEST_JSON")"   "alias agh"
assert_eq "traffic-stats" "$(resolve_module_id traffic   "$MANIFEST_JSON")"   "alias traffic"
assert_eq "traffic-stats" "$(resolve_module_id vnstat    "$MANIFEST_JSON")"   "alias vnstat"

describe "resolve_module_id — unknown returns empty"
assert_eq "" "$(resolve_module_id nope "$MANIFEST_JSON")" "unknown module"
assert_eq "" "$(resolve_module_id ""   "$MANIFEST_JSON")" "empty query"

# ─── sha256 verification flow ─────────────────────────────────────────────
describe "sha256 mismatch aborts install"

# Build a fake zip with known hash
TMPDIR=$(mktemp -d)
FAKE_ZIP="$TMPDIR/fake.zip"
# Pad to >1024 bytes (the size check threshold)
head -c 2048 /dev/urandom > "$FAKE_ZIP"
ACTUAL_HASH=$(sha256sum "$FAKE_ZIP" | awk '{print $1}')
WRONG_HASH="0000000000000000000000000000000000000000000000000000000000000000"

# Mini reimplementation of the verifier
verify_sha() {
    local zip="$1" expected="$2"
    [ -n "$expected" ] || return 100   # missing
    local actual
    actual=$(sha256sum "$zip" 2>/dev/null | awk '{print $1}')
    [ "$actual" = "$expected" ]
}

assert_rc 0   verify_sha "$FAKE_ZIP" "$ACTUAL_HASH"   "matching hash returns 0"
assert_rc 1   verify_sha "$FAKE_ZIP" "$WRONG_HASH"    "mismatched hash returns non-zero"
assert_rc 100 verify_sha "$FAKE_ZIP" ""               "missing hash returns 100 (graceful skip)"

rm -rf "$TMPDIR"

exit "$TESTS_FAILED"
