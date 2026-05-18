#!/system/bin/sh
pkill -f /data/adb/modules/statusbot/bot/bot.sh 2>/dev/null
pkill -f statusbot/service.sh 2>/dev/null
# Keep /data/statusbot (token + chat_id + offset + logs) for reinstall.
# Manual cleanup: rm -rf /data/statusbot
