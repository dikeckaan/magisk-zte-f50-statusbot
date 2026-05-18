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

# Locate bash — bot needs it for associative arrays (i18n) and indirect
# expansion. bin-utils v1.2.0+ ships bash at /system/bin/bash. Before that
# bash is staged at /data/adb/modules_update/bin-utils/system/bin/bash.
BASH_BIN=""
for p in /system/bin/bash \
         /data/adb/modules/bin-utils/system/bin/bash \
         /data/adb/modules_update/bin-utils/system/bin/bash; do
    [ -x "$p" ] && BASH_BIN="$p" && break
done
if [ -z "$BASH_BIN" ]; then
    echo "[$(date)] FATAL: bash not found. Install/update bin-utils to v1.2.0+." >> "$LOG"
    exit 1
fi

# Supervisor loop - restart bot if it crashes
(
    while true; do
        echo "[$(date)] starting bot.sh (interp: $BASH_BIN)" >> "$LOG"
        "$BASH_BIN" "$BOT" >> "$LOG" 2>&1
        rc=$?
        echo "[$(date)] bot.sh exited rc=$rc, restarting in 10s" >> "$LOG"
        # Rotate service log if huge
        sz=$(stat -c %s "$LOG" 2>/dev/null || echo 0)
        [ "$sz" -gt 524288 ] && mv "$LOG" "$LOG.1"
        sleep 10
    done
) &
