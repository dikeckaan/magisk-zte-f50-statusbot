#!/system/bin/sh
# Status bot service - late_start

DATADIR=/data/statusbot
BOOT_FLAG="$DATADIR/boot_sent"
BOT="/data/adb/modules/statusbot/bot/bot.sh"
LOG="$DATADIR/service.log"

mkdir -p "$DATADIR"

# Boot flag lives on /dev (tmpfs - cleared each boot) so we know
# when to send the "ben ayaktayım" message exactly once per boot.
DEV_FLAG=/dev/statusbot_boot_flag
rm -f "$BOOT_FLAG"
mkdir -p "$(dirname "$DEV_FLAG")" 2>/dev/null

# Wait for token + chat_id (don't busy-loop forever - cap at 5 min)
i=0
while [ ! -s "$DATADIR/token" ] || [ ! -s "$DATADIR/chat_id" ]; do
    i=$((i + 1))
    [ "$i" -ge 60 ] && exit 1
    sleep 5
done

# Small warm-up to let network come up (cloudflared learned the lesson)
sleep 15

# Supervisor loop - restart bot if it crashes
(
    while true; do
        echo "[$(date)] starting bot.sh" >> "$LOG"
        sh "$BOT" >> "$LOG" 2>&1
        rc=$?
        echo "[$(date)] bot.sh exited rc=$rc, restarting in 10s" >> "$LOG"
        # Rotate service log if huge
        sz=$(stat -c %s "$LOG" 2>/dev/null || echo 0)
        [ "$sz" -gt 524288 ] && mv "$LOG" "$LOG.1"
        sleep 10
    done
) &
