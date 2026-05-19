#!/system/bin/sh
# statusbot service — late_start.

DATADIR=/data/statusbot
BOOT_FLAG="$DATADIR/boot_sent"
BOT=/data/adb/modules/statusbot/bot/bot.sh
LOG="$DATADIR/service.log"

mkdir -p "$DATADIR"

# Boot flag lives on /dev (tmpfs - cleared each boot) so we know when
# to send the "ben ayaktayım" message exactly once per boot.
DEV_FLAG=/dev/statusbot_boot_flag
rm -f "$BOOT_FLAG"
mkdir -p "$(dirname "$DEV_FLAG")" 2>/dev/null

# bin-utils v1.3.0+ provides bash + common.sh (hard requirement).
. /data/adb/modules/bin-utils/lib/common.sh

# Wait for token + chat_id (cap waits so we don't busy-loop forever).
wait_for_file "$DATADIR/token"   300 5 || { log_line "FATAL: no token after 5 min"; exit 1; }
wait_for_file "$DATADIR/chat_id" 60  5 || { log_line "FATAL: no chat_id after 1 min"; exit 1; }

# Small warm-up to let network come up (cloudflared learned the lesson).
sleep 15

BASH_BIN=$(find_bash) || {
    log_line "FATAL: bash not found via find_bash, install bin-utils v1.3.0+"
    exit 1
}

# Supervisor loop — restart bot if it crashes.
(
    while true; do
        log_rotate 524288
        log_line "starting bot.sh (interp: $BASH_BIN)"
        "$BASH_BIN" "$BOT" >> "$LOG" 2>&1
        log_line "bot.sh exited rc=$?, restarting in 10s"
        sleep 10
    done
) &
