#!/system/bin/sh

DATADIR=/data/statusbot
TOKEN_FILE="$DATADIR/token"
CHAT_FILE="$DATADIR/chat_id"
TOKEN_SEARCH="/sdcard/statusbot_token.txt /sdcard/Download/statusbot_token.txt /data/local/tmp/statusbot_token.txt"
CHAT_SEARCH="/sdcard/statusbot_chat_id.txt /sdcard/Download/statusbot_chat_id.txt /data/local/tmp/statusbot_chat_id.txt"

ui_print ""
ui_print "=================================="
ui_print "  Telegram Status Bot v1.0.0"
ui_print "  Boot greeting + selam responder"
ui_print "=================================="
ui_print ""

# Sanity: bin-utils must be installed (provides curl + jq)
if [ ! -d /data/adb/modules/bin-utils ] && [ ! -f /system/bin/curl -o ! -f /system/bin/jq ]; then
    ui_print "[!] HATA: bin-utils modülü kurulu degil."
    ui_print "    Once bin-utils.zip flashla, sonra bu modulu."
    abort "[!] Dependency missing: bin-utils (curl + jq)"
fi

mkdir -p "$DATADIR"

# Find token file
FOUND_TOKEN=""
for f in $TOKEN_SEARCH; do
    [ -s "$f" ] && FOUND_TOKEN="$f" && break
done

# Find chat_id file
FOUND_CHAT=""
for f in $CHAT_SEARCH; do
    [ -s "$f" ] && FOUND_CHAT="$f" && break
done

# Token handling
if [ -n "$FOUND_TOKEN" ]; then
    ui_print "[*] Token bulundu: $FOUND_TOKEN"
    tr -d '\r\n ' < "$FOUND_TOKEN" > "$TOKEN_FILE"
    rm -f "$FOUND_TOKEN"
elif [ ! -s "$TOKEN_FILE" ]; then
    ui_print "[!] HATA: Telegram bot token bulunamadi."
    ui_print ""
    ui_print "Kurulumdan once token'i koy:"
    for f in $TOKEN_SEARCH; do
        ui_print "  - $f"
    done
    ui_print ""
    ui_print "BotFather'dan al: @BotFather -> /newbot"
    abort "[!] Token gerekli."
else
    ui_print "[*] Mevcut token korunuyor."
fi

# Chat ID handling
if [ -n "$FOUND_CHAT" ]; then
    ui_print "[*] Chat ID bulundu: $FOUND_CHAT"
    tr -d '\r\n ' < "$FOUND_CHAT" > "$CHAT_FILE"
    rm -f "$FOUND_CHAT"
elif [ ! -s "$CHAT_FILE" ]; then
    ui_print "[!] HATA: Chat ID bulunamadi."
    ui_print ""
    ui_print "Kurulumdan once chat_id'i koy:"
    for f in $CHAT_SEARCH; do
        ui_print "  - $f"
    done
    ui_print ""
    ui_print "Chat ID al: Bot'una mesaj at, sonra"
    ui_print "https://api.telegram.org/bot<TOKEN>/getUpdates"
    ui_print "URL'sinde .message.chat.id alanini gor."
    abort "[!] Chat ID gerekli."
else
    ui_print "[*] Mevcut chat_id korunuyor."
fi

chmod 600 "$TOKEN_FILE" "$CHAT_FILE"

# Set perms
set_perm "$MODPATH/bot/bot.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm_recursive "$MODPATH/bot" 0 0 0755 0755

ui_print ""
ui_print "[OK] Kurulum tamamlandi."
ui_print ""
ui_print "Token:   $TOKEN_FILE"
ui_print "Chat ID: $CHAT_FILE"
ui_print ""
ui_print "Reboot sonrasi 'ben ayaktayim' mesaji gelir."
ui_print "Bota 'selam' yazinca cevap verir (sadece sahibe)."
ui_print ""
