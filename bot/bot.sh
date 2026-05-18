#!/system/bin/bash
# Telegram status bot — multi-language UI (lang/<code>.sh files in module dir)

BOT_VERSION="v2.10.0"
MODDIR=/data/adb/modules/statusbot
DATADIR=/data/statusbot
TASK_DIR="$DATADIR/tasks"
TOKEN_FILE="$DATADIR/token"
CHAT_FILE="$DATADIR/chat_id"
OFFSET_FILE="$DATADIR/offset"
BOOT_FLAG="$DATADIR/boot_sent"
PENDING_REBOOT="$DATADIR/pending_reboot"
LOGFILE="$DATADIR/bot.log"
LANG_FILE_PREF="$DATADIR/lang"

CURL=/system/bin/curl
JQ=/system/bin/jq
CA=/system/etc/cacert.pem
TG_API="https://api.telegram.org/bot"

# ─── i18n loader ──────────────────────────────────────────────────────────
# en.sh is sourced first (provides full fallback set). User's selected lang
# (if any) is sourced after — its keys override en's, missing keys fall back.
declare -gA MSG
if [ -r "$MODDIR/lang/en.sh" ]; then
    . "$MODDIR/lang/en.sh"
fi
USER_LANG="en"
if [ -r "$LANG_FILE_PREF" ]; then
    USER_LANG=$(cat "$LANG_FILE_PREF" 2>/dev/null | tr -d ' \r\n')
fi
if [ -n "$USER_LANG" ] && [ "$USER_LANG" != "en" ] && [ -r "$MODDIR/lang/${USER_LANG}.sh" ]; then
    . "$MODDIR/lang/${USER_LANG}.sh"
fi

# Translate helper: t <key> → MSG[key] or, if missing, the key itself
t() { echo "${MSG[$1]:-$1}"; }
# Translate-format: tf <key> <args...> → printf MSG[key] with args
tf() { local k=$1; shift; printf "${MSG[$k]:-$k}\n" "$@"; }

# sendat binary for AT commands - prefer bin-utils, fall back to UFI-TOOLS
SENDAT=""
for p in /system/bin/sendat /data/data/com.minikano.f50_sms/files/sendat; do
    [ -x "$p" ] && SENDAT="$p" && break
done

KOMUT_TIMEOUT=120   # seconds before auto-kill of /komut task
KOMUT_MAX_OUTPUT=3500   # bytes of output to show

mkdir -p "$TASK_DIR"
# Record our PID so /lang and /restart_bot can self-restart without
# nuking the supervisor via overly-broad pkill -f patterns.
echo $$ > "$DATADIR/bot.pid"

# ─── helpers ──────────────────────────────────────────────────────────────
log() {
    if [ -f "$LOGFILE" ]; then
        sz=$(stat -c %s "$LOGFILE" 2>/dev/null || echo 0)
        [ "$sz" -gt 1048576 ] && mv "$LOGFILE" "$LOGFILE.1"
    fi
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOGFILE"
}

greeting() {
    h=$(date +%H)
    if   [ "$h" -ge 5 ]  && [ "$h" -lt 11 ]; then t greet_morning
    elif [ "$h" -ge 11 ] && [ "$h" -lt 17 ]; then t greet_noon
    elif [ "$h" -ge 17 ] && [ "$h" -lt 21 ]; then t greet_evening
    else                                          t greet_night
    fi
}

# ─── Telegram API wrappers ────────────────────────────────────────────────
tg_send() {
    # $1 chat_id, $2 text, $3 (opt) reply_to_message_id → prints raw JSON response
    local extra=""
    [ -n "$3" ] && extra="-d reply_to_message_id=$3"
    "$CURL" -sS --cacert "$CA" --max-time 15 \
        "${TG_API}${TOKEN}/sendMessage" \
        -d "chat_id=$1" \
        --data-urlencode "text=$2" \
        $extra 2>/dev/null
}

tg_send_with_cancel() {
    # $1 chat_id, $2 text, $3 task_id (for callback_data)
    local kb="{\"inline_keyboard\":[[{\"text\":\"❌ İptal\",\"callback_data\":\"cancel:$3\"}]]}"
    "$CURL" -sS --cacert "$CA" --max-time 15 \
        "${TG_API}${TOKEN}/sendMessage" \
        -d "chat_id=$1" \
        --data-urlencode "text=$2" \
        --data-urlencode "reply_markup=$kb" \
        2>/dev/null
}

tg_send_with_reboot() {
    # $1 chat_id, $2 text
    local kb='{"inline_keyboard":[[{"text":"🔁 Şimdi Yeniden Başlat","callback_data":"reboot_now"}]]}'
    "$CURL" -sS --cacert "$CA" --max-time 15 \
        "${TG_API}${TOKEN}/sendMessage" \
        -d "chat_id=$1" \
        --data-urlencode "text=$2" \
        --data-urlencode "reply_markup=$kb" \
        >/dev/null 2>&1
}

tg_edit() {
    # $1 chat_id, $2 message_id, $3 new_text  (clears reply_markup)
    "$CURL" -sS --cacert "$CA" --max-time 15 \
        "${TG_API}${TOKEN}/editMessageText" \
        -d "chat_id=$1" \
        -d "message_id=$2" \
        --data-urlencode "text=$3" \
        >/dev/null 2>&1
}

tg_answer_callback() {
    # $1 callback_query_id, $2 (opt) text
    "$CURL" -sS --cacert "$CA" --max-time 10 \
        "${TG_API}${TOKEN}/answerCallbackQuery" \
        -d "callback_query_id=$1" \
        --data-urlencode "text=${2:-}" \
        >/dev/null 2>&1
}

tg_send_photo() {
    # $1 chat_id, $2 file_path, $3 caption
    "$CURL" -sS --cacert "$CA" --max-time 30 \
        "${TG_API}${TOKEN}/sendPhoto" \
        -F "chat_id=$1" \
        -F "photo=@$2" \
        -F "caption=$3" \
        >/dev/null 2>&1
}

tg_send_document() {
    # $1 chat_id, $2 file_path, $3 (opt) caption
    "$CURL" -sS --cacert "$CA" --max-time 120 \
        "${TG_API}${TOKEN}/sendDocument" \
        -F "chat_id=$1" \
        -F "document=@$2" \
        -F "caption=${3:-}" \
        2>/dev/null
}

# ─── device info helpers ──────────────────────────────────────────────────
fmt_uptime() {
    local s=$(cut -d. -f1 /proc/uptime)
    local d=$((s/86400))
    local h=$(( (s%86400)/3600 ))
    local m=$(( (s%3600)/60 ))
    local sec=$((s%60))
    if [ "$d" -gt 0 ]; then
        printf "${MSG[uptime_days_fmt]}" "$d" "$h" "$m"
    elif [ "$h" -gt 0 ]; then
        printf "${MSG[uptime_hours_fmt]}" "$h" "$m"
    else
        printf "${MSG[uptime_short_fmt]}" "$m" "$sec"
    fi
}

fmt_mem() {
    awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2}
        END {
            used=t-a
            printf "%.0f / %.0f MB (%%%d)", used/1024, t/1024, used*100/t
        }' /proc/meminfo
}

fmt_disk() {
    df -h /data 2>/dev/null | awk -v fmt="${MSG[disk_fmt]}" 'NR==2 {printf fmt, $3, $2, $5}'
}

fmt_load() {
    # 1m 5m 15m + number of cores + interpretation
    set -- $(cat /proc/loadavg)
    local l1="$1" l5="$2" l15="$3"
    local cores=$(nproc 2>/dev/null || echo 1)
    # Status from 1m / cores ratio
    local pct
    pct=$(awk -v l="$l1" -v c="$cores" 'BEGIN {printf "%d", l*100/c}')
    local status
    if   [ "$pct" -lt 50 ];  then status=$(printf "${MSG[load_status_calm]}"   "$pct")
    elif [ "$pct" -lt 80 ];  then status=$(printf "${MSG[load_status_active]}" "$pct")
    elif [ "$pct" -lt 120 ]; then status=$(printf "${MSG[load_status_full]}"   "$pct")
    else                          status=$(printf "${MSG[load_status_busy]}"   "$pct")
    fi
    printf "${MSG[load_full_fmt]}\n" "$cores" "$l1" "$l5" "$l15" "$status" "$cores" "$cores" "$cores"
}

fmt_temp() {
    for z in /sys/class/thermal/thermal_zone*/; do
        t=$(cat "$z/type" 2>/dev/null)
        case "$t" in
            apcpu0-thmzone)
                v=$(cat "$z/temp" 2>/dev/null)
                [ -n "$v" ] && printf "%d.%d°C (CPU)" "$((v/1000))" "$(((v%1000)/100))" && return
                ;;
        esac
    done
    echo "n/a"
}

fmt_public_ip() {
    "$CURL" -sS --cacert "$CA" --max-time 8 https://ifconfig.me 2>/dev/null || echo "n/a"
}

iface_role() {
    # Returns label for an interface name
    case "$1" in
        sipa_eth*|rmnet*|ccmni*|usb_rndis*) echo "📱 Cellular" ;;
        br0|br1)                             echo "📡 WiFi Hotspot" ;;
        wlan0|wlan1|wifi*)                   echo "📶 WiFi Station" ;;
        tun*|tap*)                           echo "🔒 VPN" ;;
        eth*)                                echo "🔌 Ethernet" ;;
        usb*|rndis*)                         echo "🔌 USB" ;;
        *)                                   echo "❓ $1" ;;
    esac
}

fmt_local_ips() {
    local def_iface=$(ip route show default 2>/dev/null | awk 'NR==1 {print $5}')
    ip -4 -o addr 2>/dev/null | awk '$2!="lo" {print $2, $4}' | while read iface ip; do
        local role=$(iface_role "$iface")
        local marker=""
        [ "$iface" = "$def_iface" ] && marker=" ⬅ varsayılan çıkış"
        printf "%s  %s  (%s)%s\n" "$role" "$ip" "$iface" "$marker"
    done
}

fmt_operator() {
    op=$(getprop gsm.operator.alpha | cut -d, -f1)
    [ -z "$op" ] && op="?"
    roam=$(getprop gsm.operator.isroaming | cut -d, -f1)
    [ "$roam" = "true" ] && op="$op (roaming)"
    echo "$op"
}

# ─── UFI sendat helpers ───────────────────────────────────────────────────
at_cmd() {
    # $1 = AT command, $2 = slot (default 0). Outputs cleaned response.
    [ -x "$SENDAT" ] || { echo "(sendat yok - UFI-TOOLS yüklü değil)"; return 1; }
    local slot="${2:-0}"
    "$SENDAT" -c "$1" -n "$slot" 2>/dev/null | tr -d '\r' | sed 's/OK$//' | head -c 400
}

csq_to_dbm() {
    # CSQ 0-31 → dBm. 99 = unknown
    local csq="$1"
    [ -z "$csq" ] || [ "$csq" = "99" ] && { echo "?"; return; }
    # dBm = -113 + 2*csq
    echo "$((csq * 2 - 113)) dBm"
}

csq_label() {
    local csq="$1"
    if   [ "$csq" -ge 20 ]; then echo "🟢 Mükemmel"
    elif [ "$csq" -ge 15 ]; then echo "🟢 İyi"
    elif [ "$csq" -ge 10 ]; then echo "🟡 Orta"
    elif [ "$csq" -ge 2 ];  then echo "🟠 Zayıf"
    else                         echo "🔴 Çok zayıf"
    fi
}

fmt_signal() {
    [ -x "$SENDAT" ] || { echo "📶 Sinyal: sendat (UFI-TOOLS) gerekli"; return; }
    local csq_raw=$(at_cmd "AT+CSQ")
    # Parse "+CSQ: 33,12"
    local rssi=$(echo "$csq_raw" | sed -n 's/.*+CSQ: *\([0-9]*\),.*/\1/p')
    local ber=$(echo "$csq_raw"  | sed -n 's/.*+CSQ: *[0-9]*, *\([0-9]*\).*/\1/p')
    echo "📶 Sinyal Kalitesi"
    if [ -n "$rssi" ]; then
        echo "RSSI: $rssi ($(csq_to_dbm "$rssi"))  $(csq_label "$rssi")"
    else
        echo "RSSI: ?"
    fi
    [ -n "$ber" ] && echo "BER: $ber"

    # AT+CESQ for LTE detail
    local cesq=$(at_cmd "AT+CESQ")
    # +CESQ: rxlev,ber,rscp,ecno,rsrq,rsrp,rssnr,...
    local rsrq=$(echo "$cesq" | sed -n 's/.*+CESQ: *[0-9]*, *[0-9]*, *[0-9]*, *[0-9]*, *\([0-9]*\), *[0-9]*.*/\1/p')
    local rsrp=$(echo "$cesq" | sed -n 's/.*+CESQ: *[0-9]*, *[0-9]*, *[0-9]*, *[0-9]*, *[0-9]*, *\([0-9]*\).*/\1/p')
    if [ -n "$rsrp" ] && [ "$rsrp" != "255" ]; then
        # RSRP dBm = rsrp - 141 + 1 ... actually: -141 to -44 maps to 0-97. RSRP_dBm = rsrp - 141
        echo ""
        echo "LTE Detayları:"
        echo "  RSRP: $((rsrp - 141)) dBm"
        if [ -n "$rsrq" ] && [ "$rsrq" != "255" ]; then
            # RSRQ dB = (rsrq - 40) / 2 ... actually: rsrq is 0-34 mapping -19.5 to -3.0 dB
            local rsrq_db=$(awk -v r="$rsrq" 'BEGIN { printf "%.1f", -19.5 + r * 0.5 }')
            echo "  RSRQ: $rsrq_db dB"
        fi
    fi
}

fmt_battery() {
    local cap=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null)
    local status=$(cat /sys/class/power_supply/battery/status 2>/dev/null)
    local temp=$(cat /sys/class/power_supply/battery/temp 2>/dev/null)
    local volt=$(cat /sys/class/power_supply/battery/voltage_now 2>/dev/null)

    [ -z "$cap" ] && { echo "${MSG[bat_unread]}"; return; }

    local filled=$((cap / 10))
    local pbar=""
    local i=0
    while [ "$i" -lt 10 ]; do
        if [ "$i" -lt "$filled" ]; then pbar="${pbar}▰"; else pbar="${pbar}▱"; fi
        i=$((i+1))
    done

    local status_label=""
    case "$status" in
        Charging)      status_label="${MSG[bat_status_charging]}" ;;
        Discharging)   status_label="${MSG[bat_status_discharging]}" ;;
        Full)          status_label="${MSG[bat_status_full]}" ;;
        Not\ charging) status_label="${MSG[bat_status_not_charging]}" ;;
        *)             status_label="$status" ;;
    esac

    echo "${MSG[bat_header]}"
    printf "${MSG[bat_charge_fmt]}\n" "$cap" "$pbar"
    printf "${MSG[bat_state_fmt]}\n" "$status_label"
    [ -n "$temp" ] && printf "${MSG[bat_temp_fmt]}\n" "$(awk -v t="$temp" 'BEGIN{printf "%.1f°C", t/10}')"
    [ -n "$volt" ] && printf "${MSG[bat_volt_fmt]}\n" "$(awk -v v="$volt" 'BEGIN{printf "%.2fV", v/1000000}')"
}

fmt_bytes() {
    # $1 = bytes → human-readable
    awk -v b="$1" 'BEGIN {
        units="B KB MB GB TB"
        split(units, u, " ")
        i=1
        while (b >= 1024 && i < 5) { b/=1024; i++ }
        printf "%.1f %s", b, u[i]
    }'
}

fmt_traffic() {
    echo "📊 Trafik (boot'tan beri)"
    awk '/^[ \t]*(sipa_eth0|br0|tun0|wlan0):/ {
        gsub(":", "", $1)
        iface=$1
        rx=$2; tx=$10
        printf "%s|%s|%s\n", iface, rx, tx
    }' /proc/net/dev | while IFS='|' read -r iface rx tx; do
        local role=$(iface_role "$iface")
        echo ""
        echo "$role ($iface)"
        echo "  ↓ $(fmt_bytes "$rx") indirilen"
        echo "  ↑ $(fmt_bytes "$tx") yüklenen"
    done
}

# ─── commands ─────────────────────────────────────────────────────────────
cmd_help() {
    # 2 placeholders: temp alert threshold, mem-available threshold (%)
    printf "${MSG[help_full_fmt]}\n" "$ALERT_TEMP_C" "$ALERT_MEM_PCT"
}

cmd_status() {
    printf "${MSG[status_model_fmt]}" "$(getprop ro.product.model) ($(getprop ro.build.display.id))"
    printf "${MSG[status_uptime_fmt]}" "$(fmt_uptime)"
    printf "${MSG[status_ram_fmt]}"    "$(fmt_mem)"
    printf "${MSG[status_disk_fmt]}"   "$(fmt_disk)"
    printf "${MSG[status_temp_fmt]}"   "$(fmt_temp)"
    # Performance mode
    local perf_mode
    perf_mode=$(zte_get "performance_mode" | "$JQ" -r '.performance_mode // empty' 2>/dev/null)
    case "$perf_mode" in
        1) printf "${MSG[status_perf_on]}" ;;
        0) printf "${MSG[status_perf_off]}" ;;
    esac
    printf "${MSG[status_operator_fmt]}" "$(fmt_operator)"
    # CSQ if sendat available
    if [ -x "$SENDAT" ]; then
        csq=$(at_cmd "AT+CSQ" | sed -n 's/.*+CSQ: *\([0-9]*\),.*/\1/p')
        [ -n "$csq" ] && printf "${MSG[status_signal_fmt]}" "$csq" "$(csq_to_dbm "$csq")"
    fi
    printf "${MSG[status_public_ip_fmt]}" "$(fmt_public_ip)"
}

cmd_at() {
    # Generic AT runner. Args: optional "slot=N", then full AT command.
    local args="$*"
    if [ -z "$args" ]; then
        echo "${MSG[at_usage]}"
        return
    fi
    [ ! -x "$SENDAT" ] && { echo "${MSG[at_no_sendat]}"; return; }

    local slot=0
    case "$args" in
        slot=*)
            slot=$(echo "$args" | awk '{print $1}' | cut -d= -f2)
            args=$(echo "$args" | awk '{$1=""; sub(/^ /,""); print}')
            ;;
    esac

    case "$args" in
        AT*|at*) ;;
        *) echo "${MSG[at_must_start_with]}"; return ;;
    esac

    local resp=$(at_cmd "$args" "$slot")
    tf at_request_fmt "$args" "$slot"
    echo
    [ -z "$resp" ] && echo "${MSG[at_empty_response]}" || echo "$resp"
}

edevlet_session_get_token_captcha() {
    # $1 = cookie jar path, $2 = captcha output path, $3 = UA
    # Echoes the form token, or empty on failure
    rm -f "$1"
    local html
    html=$("$CURL" -sL --cacert "$CA" -c "$1" -A "$3" --max-time 15 \
        "https://www.turkiye.gov.tr/imei-sorgulama" 2>/dev/null)
    local token
    token=$(echo "$html" | grep -oE 'name="token" value="[^"]+"' | head -1 | sed 's/.*value="\([^"]*\)".*/\1/')
    [ -z "$token" ] && return 1
    "$CURL" -sL --cacert "$CA" -b "$1" -c "$1" -A "$3" --max-time 10 -o "$2" \
        "https://www.turkiye.gov.tr/captcha?uniquePage=877" 2>/dev/null
    [ ! -s "$2" ] && return 1
    echo "$token"
}

edevlet_submit_and_process() {
    # $1 = jar, $2 = token, $3 = imei, $4 = captcha, $5 = UA
    # On success: echoes result text (parsed). On failure: empty + return 1.
    local resp
    resp=$("$CURL" -sL --cacert "$CA" -b "$1" -c "$1" -A "$5" --max-time 25 \
        -X POST "https://www.turkiye.gov.tr/imei-sorgulama?submit" \
        -H "Referer: https://www.turkiye.gov.tr/imei-sorgulama" \
        --data-urlencode "token=$2" \
        --data-urlencode "txtImei=$3" \
        --data-urlencode "captcha_name=$4" 2>/dev/null)

    # If captcha wrong → response back to step 1
    local step
    step=$(echo "$resp" | grep -oE 'Şu anda <strong>[0-9]</strong>' | head -1 | grep -oE '[0-9]')
    if [ "$step" = "1" ]; then
        return 1
    fi

    # If asyncRequired, poll
    if echo "$resp" | grep -q "asyncRequired"; then
        local data_token redirect_b64
        data_token=$(echo "$resp" | grep -oE 'data-token="[^"]+"' | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
        redirect_b64=$(echo "$resp" | grep -oE "redirectURL = '[^']*'" | head -1 | sed "s/.*'\([^']*\)'.*/\1/")
        local final_url="" a=0
        while [ "$a" -lt 12 ]; do
            a=$((a + 1))
            sleep 2
            local pr
            pr=$("$CURL" -sS --cacert "$CA" -b "$1" -c "$1" -A "$5" --max-time 15 \
                -X POST "https://www.turkiye.gov.tr/imei-sorgulama?asama=1&submit" \
                -H "Referer: https://www.turkiye.gov.tr/imei-sorgulama" \
                -H "X-Requested-With: XMLHttpRequest" \
                --data-urlencode "ajax=1" \
                --data-urlencode "token=$data_token" \
                --data-urlencode "asyncQueue=" \
                --data-urlencode "redirectURL=$redirect_b64" 2>/dev/null)
            local rs
            rs=$(echo "$pr" | "$JQ" -r '.requestStatus // empty' 2>/dev/null)
            if [ "$rs" = "FINISHED" ]; then
                final_url=$(echo "$pr" | "$JQ" -r '.redirectURL // empty' 2>/dev/null)
                break
            fi
        done
        [ -z "$final_url" ] && return 1
        resp=$("$CURL" -sL --cacert "$CA" -b "$1" -A "$5" --max-time 15 \
            "https://www.turkiye.gov.tr$final_url" 2>/dev/null)
    fi

    # Extract result text from resultContainer
    local result_text
    result_text=$(echo "$resp" | tr '\n' ' ' | tr -s ' ' | \
        sed -n 's/.*<div class="resultContainer"[^>]*>\(.*\)<\/section>.*/\1/p' | \
        sed 's/<[^>]*>/|/g' | tr -s '|')
    if [ -z "$result_text" ]; then
        return 1
    fi

    # Pretty format
    local pretty
    pretty=$(echo "$result_text" | awk -F'|' '
    {
        for (i = 1; i <= NF; i++) {
            v = $i
            gsub(/^[ \t]+|[ \t]+$/, "", v)
            if (v == "" || v == ":") continue
            if (match(v, /^(IMEI|Durum|Kaynak|Sorgu Tarihi|Marka\/Model)[ :]*$/)) {
                lbl = v
                sub(/ *:? *$/, "", lbl)
                for (j = i+1; j <= NF; j++) {
                    nv = $j
                    gsub(/^[ \t]+|[ \t]+$/, "", nv)
                    if (nv != "") {
                        printf "• %s: %s\n", lbl, nv
                        i = j
                        break
                    }
                }
            }
        }
    }')
    [ -z "$pretty" ] && pretty=$(echo "$result_text" | sed 's/|/ /g' | tr -s ' ')
    echo "$pretty"
    return 0
}

cmd_imei_sorgula() {
    local chat_id="$1"
    local imei="$2"

    # If no argument, use device's own IMEI (slot 0)
    if [ -z "$imei" ]; then
        if [ -x "$SENDAT" ]; then
            imei=$(at_cmd "AT+CGSN" 0 | sed 's/[^0-9]//g')
        fi
        [ -z "$imei" ] && { tg_send "$chat_id" "Kullanım: /imei_sorgula <15 haneli imei>"; return; }
    fi

    # Validate
    case "$imei" in
        *[!0-9]*) tg_send "$chat_id" "❌ IMEI sadece rakam olmalı"; return ;;
    esac
    [ ${#imei} -ne 15 ] && { tg_send "$chat_id" "❌ 15 hane olmalı (girdiğin ${#imei} hane)"; return; }

    local luhn_ok="❌ Luhn geçersiz"
    luhn_check "$imei" && luhn_ok="✓ Luhn geçerli"

    local tac=$(echo "$imei" | cut -c1-8)
    local snr=$(echo "$imei" | cut -c9-14)
    local cd=$(echo "$imei" | cut -c15)

    local header="📱 IMEI: $imei

🔍 Yapısal Analiz
TAC: $tac (üretici+model kodu)
SNR: $snr (seri no)
Check: $cd ($luhn_ok)"

    local UA="Mozilla/5.0 (X11; Linux aarch64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"
    local jar="$DATADIR/.edevlet_cookies"
    local captcha_file="$DATADIR/.captcha.png"

    # Get fresh session + captcha, send to user
    local tok
    tok=$(edevlet_session_get_token_captcha "$jar" "$captcha_file" "$UA")
    if [ -z "$tok" ]; then
        tg_send "$chat_id" "$header

⚠️ e-Devlet'e erişilemedi"
        return
    fi

    # Save state for handle_captcha_response
    {
        echo "imei=$imei"
        echo "token=$tok"
        echo "created=$(date +%s)"
        echo "ua=$UA"
        echo "header_b64=$(echo "$header" | base64 | tr -d '\n')"
    } > "$DATADIR/pending_imei_sorgu"

    tg_send_photo "$chat_id" "$captcha_file" "📱 IMEI Sorgu için captcha:
Görseldekini bir mesaj olarak yaz (2dk, 4-7 karakter).
İptal: /iptal"
}

handle_captcha_response() {
    local chat_id="$1"
    local msg_id="$2"
    local captcha="$3"
    local state="$DATADIR/pending_imei_sorgu"
    local jar="$DATADIR/.edevlet_cookies"

    local imei token UA header_b64 header
    imei=$(awk -F= '/^imei=/{print $2}' "$state")
    token=$(awk -F= '/^token=/{print $2}' "$state")
    UA=$(awk -F= '/^ua=/{$1=""; sub(/^=/,""); print}' "$state")
    header_b64=$(awk -F= '/^header_b64=/{print $2}' "$state")
    header=$(echo "$header_b64" | base64 -d 2>/dev/null)

    rm -f "$state"

    local result
    result=$(edevlet_submit_and_process "$jar" "$token" "$imei" "$captcha" "$UA")
    if [ $? -eq 0 ] && [ -n "$result" ]; then
        rm -f "$jar" "$DATADIR/.captcha.png"
        tg_send "$chat_id" "$header

📋 e-Devlet Sonucu
$result"
        return
    fi

    rm -f "$jar" "$DATADIR/.captcha.png"
    tg_send "$chat_id" "$header

❌ Captcha yanlış veya zaman aşımı.
Tekrar: /imei_sorgula $imei" "$msg_id"
}

cmd_ramclean() {
    # Modes:
    #   /ramclean              → soft: drop cache + am kill-all + known heavy
    #   /ramclean aggressive   → soft + force-stop ALL 3rd party non-protected
    #   /ramclean nuke         → aggressive + send-trim-memory to everything
    #   /ramclean list         → show top 10 by RSS
    #   /ramclean <pkg> [...]  → soft + force-stop these extras
    local arg1="$1"
    local extras=""

    case "$arg1" in
        list|top)
            echo "${MSG[rc_list_header]}"
            ps -A -o rss,name --sort=-rss 2>/dev/null | head -16 | awk 'NR==1 {next} {printf "  %s MB  %s\n", int($1/1024), $2}'
            return
            ;;
        aggressive|-a|agresif)
            local mode="aggressive"
            extras=$(echo "$1" | awk '{$1=""; sub(/^ /,""); print}')
            ;;
        nuke|-n|max)
            local mode="nuke"
            ;;
        *)
            local mode="soft"
            extras="$arg1 $(echo "$1" | awk '{$1=""; sub(/^ /,""); print}')"
            ;;
    esac

    # Snapshot
    local before_avail before_swap
    before_avail=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo)
    before_swap=$(awk '/^SwapFree:/{print $2}' /proc/meminfo)

    # Protected (always preserved)
    local protected='^(com\.v2ray|com\.wireguard|com\.openvpn|com\.protonvpn|com\.android\.systemui|com\.android\.launcher|com\.android\.phone|com\.android\.providers|com\.android\.bluetooth|com\.android\.inputmethod|com\.android\.shell|com\.android\.dialer|com\.android\.contacts|com\.google\.android\.gms|com\.topjohnwu\.magisk|com\.zte\.|com\.minikano\.|com\.spreadtrum|com\.sprd|com\.unisoc|android$|system_server|init|magiskd|cloudflared|dropbear|bot\.sh|statusbot)'

    # Default heavy apps that get killed in soft mode
    local heavy_apps="
        org.zwanoo.android.speedtest
        com.google.android.youtube
        com.netflix.mediaclient
        com.spotify.music
        org.mozilla.firefox
        com.android.chrome
        com.android.settings
        com.google.android.apps.youtube.music
        com.facebook.katana
        com.instagram.android
        com.whatsapp
        com.discord
        com.reddit.frontpage
    "

    # 1) Sync and drop kernel caches
    sync
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
    # Memory compaction (defragment - asks kernel to consolidate free pages)
    echo 1 > /proc/sys/vm/compact_memory 2>/dev/null

    # 2) Ask Android to kill cached/empty background procs
    am kill-all >/dev/null 2>&1

    # 3) Build kill list based on mode
    local kill_targets=""
    case "$mode" in
        soft)
            kill_targets="$heavy_apps $extras"
            ;;
        aggressive|nuke)
            # All user-installed (-3) plus heavy_apps
            local third_party
            third_party=$(pm list packages -3 2>/dev/null | sed 's/^package://')
            kill_targets="$heavy_apps $third_party $extras"
            ;;
    esac

    # 4) Force-stop targets (skip protected, dedupe)
    local killed_count=0
    local killed_sample=""
    local seen=""
    for pkg in $kill_targets; do
        [ -z "$pkg" ] && continue
        # Dedupe
        case " $seen " in *" $pkg "*) continue ;; esac
        seen="$seen $pkg"
        # Skip protected (except settings - we want it killable)
        if [ "$pkg" != "com.android.settings" ] && echo "$pkg" | grep -qE "$protected"; then
            continue
        fi
        # Skip if not running
        pgrep -f "$pkg" >/dev/null 2>&1 || continue
        am force-stop "$pkg" 2>/dev/null
        killed_count=$((killed_count + 1))
        # Sample first few for the report
        if [ "$killed_count" -le 8 ]; then
            killed_sample="$killed_sample
  • $pkg"
        fi
    done

    # 5) Nuke mode: send-trim-memory to remaining heavy app processes (bounded)
    if [ "$mode" = "nuke" ]; then
        # Pick top 30 app processes by RSS whose name starts with com. or org.
        # (process name is the package, not the command line - ps -A gives it as NAME)
        local trimmed=0
        local pid
        for pid in $(ps -A -o pid,rss,name --sort=-rss 2>/dev/null | awk 'NR>1 && $2>5000 && $3~/^(com|org)\./ {print $1}' | head -30); do
            am send-trim-memory "$pid" COMPLETE 2>/dev/null
            trimmed=$((trimmed + 1))
        done
        # One more cache drop after trim
        sync
        echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
        log "nuke: trim-memory sent to $trimmed processes"
    fi

    sleep 2
    local after_avail after_swap
    after_avail=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo)
    after_swap=$(awk '/^SwapFree:/{print $2}' /proc/meminfo)
    local freed_ram=$((after_avail - before_avail))
    local freed_swap=$((after_swap - before_swap))

    local mode_label
    case "$mode" in
        soft) mode_label="${MSG[rc_mode_soft]}" ;;
        aggressive) mode_label="${MSG[rc_mode_aggressive]}" ;;
        nuke) mode_label="${MSG[rc_mode_nuke]}" ;;
    esac

    printf "%s\n" "$mode_label"
    echo ""
    printf "${MSG[rc_before_fmt]}\n" "$((before_avail/1024))" "$((before_swap/1024))"
    printf "${MSG[rc_after_fmt]}\n"  "$((after_avail/1024))"  "$((after_swap/1024))"
    echo ""
    if [ "$freed_ram" -gt 0 ]; then
        printf "${MSG[rc_ram_gain_fmt]}\n" "$((freed_ram/1024))"
    elif [ "$freed_ram" -lt -1024 ]; then
        printf "${MSG[rc_ram_loss_fmt]}\n" "$((freed_ram/1024))"
    else
        echo "${MSG[rc_ram_same]}"
    fi
    [ "$freed_swap" -gt 0 ] && printf "${MSG[rc_swap_gain_fmt]}\n" "$((freed_swap/1024))"

    if [ "$killed_count" -gt 0 ]; then
        echo ""
        printf "${MSG[rc_killed_fmt]}\n" "$killed_count" "$killed_sample"
        [ "$killed_count" -gt 8 ] && printf "${MSG[rc_killed_more_fmt]}\n" "$((killed_count - 8))"
    fi
    echo ""
    echo "${MSG[rc_modes_help]}"
}

# ─── filesystem / inspection ──────────────────────────────────────────────
cmd_ls() {
    local p="${1:-/}"
    [ ! -e "$p" ] && { tf common_not_exists_fmt "$p"; return; }
    echo "📁 $p"
    ls -lah "$p" 2>&1 | head -50
}

cmd_cat() {
    local p="$1"
    [ -z "$p" ] && { echo "Kullanım: /cat <dosya>"; return; }
    [ ! -f "$p" ] && { echo "❌ Dosya yok: $p"; return; }
    local size
    size=$(stat -c %s "$p" 2>/dev/null || echo 0)
    if [ "$size" -gt 4000 ]; then
        echo "📄 $p ($size byte — ilk 4000)
$(head -c 4000 "$p")
... (kalan: /file $p ile çek)"
    else
        echo "📄 $p
$(cat "$p")"
    fi
}

cmd_df() {
    echo "💿 Disk Kullanımı:"
    df -h 2>/dev/null | awk 'NR==1 || /\/data|\/system|\/cache|\/dev$|\/tmp/ {print}'
}

cmd_du() {
    local p="${1:-/data}"
    [ ! -d "$p" ] && { echo "❌ Dizin yok: $p"; return; }
    echo "📊 $p alt dizin boyutları:"
    du -sh "$p"/* 2>/dev/null | sort -hr | head -15
}

# ─── network inspection ───────────────────────────────────────────────────
cmd_connections() {
    echo "🔗 Established TCP bağlantıları (top 30):"
    netstat -tn 2>/dev/null | awk '$NF=="ESTABLISHED" {print $4 "  ↔  " $5}' | sort -u | head -30
}

cmd_listening() {
    echo "👂 Dinleyen TCP portları:"
    netstat -tlnp 2>/dev/null | awk '/LISTEN/ {printf "  %-22s  %s\n", $4, $7}' | sort -u | head -30
}

cmd_dns() {
    echo "🌐 DNS Yapılandırması:"
    for f in /etc/resolv.conf /system/etc/resolv.conf; do
        [ -r "$f" ] && echo "$f:" && cat "$f" 2>/dev/null
    done
    echo
    echo "Active DNS (Android props):"
    getprop | grep -iE "^\[net.dns" | head -5
}

cmd_dhcp() {
    echo "📋 DHCP / Bağlı Cihazlar"
    echo
    # Identify DHCP server (Android tethering uses dnsmasq with no lease file — stateless)
    local dnsmasq_pid
    dnsmasq_pid=$(pgrep -f "dnsmasq.*dhcp" 2>/dev/null | head -1)
    if [ -n "$dnsmasq_pid" ]; then
        echo "DHCP sunucusu: dnsmasq (PID $dnsmasq_pid, stateless)"
    else
        echo "DHCP sunucusu: yok (hotspot kapalı olabilir)"
    fi
    # Bridge gateway IP
    local gw
    gw=$(ip -4 addr show br0 2>/dev/null | awk '/inet /{print $2; exit}')
    [ -n "$gw" ] && echo "Bridge:       $gw"
    echo
    echo "👥 Aktif istemciler (ip neigh dev br0):"
    # Single-pass: ip neigh → IP MAC STATE
    local cnt=0
    local line
    ip neigh show dev br0 2>/dev/null | awk '$1!~/^fe80/ && NF>=4 {
        ip=$1; mac=""; state=$NF
        for (i=1; i<=NF; i++) if ($i=="lladdr") { mac=$(i+1); break }
        if (mac != "") printf "  %-15s  %-17s  %s\n", ip, mac, state
    }' | head -20
    cnt=$(ip neigh show dev br0 2>/dev/null | awk '$1!~/^fe80/ && /lladdr/' | wc -l)
    [ "$cnt" -eq 0 ] && echo "  (yok)"
    echo
    echo "Toplam: $cnt cihaz"
}

# ─── power / kernel ───────────────────────────────────────────────────────
cmd_cpu_freq() {
    echo "⚡ CPU Frekansları"
    local i=0
    for d in /sys/devices/system/cpu/cpu[0-9]*/cpufreq; do
        [ -d "$d" ] || continue
        local cur min max gov
        cur=$(cat "$d/scaling_cur_freq" 2>/dev/null)
        min=$(cat "$d/scaling_min_freq" 2>/dev/null)
        max=$(cat "$d/scaling_max_freq" 2>/dev/null)
        gov=$(cat "$d/scaling_governor" 2>/dev/null)
        [ -z "$cur" ] && continue
        printf "  CPU%d: %d MHz (gov=%s, %d-%d MHz)\n" "$i" "$((cur/1000))" "$gov" "$((min/1000))" "$((max/1000))"
        i=$((i+1))
    done
}

cmd_cpu_governor() {
    local arg="$1"
    if [ -z "$arg" ] || [ "$arg" = "status" ]; then
        echo "⚙️ CPU governor durumu:"
        local i
        for i in 0 1 2 3 4 5 6 7; do
            local d=/sys/devices/system/cpu/cpu$i
            [ -d "$d" ] || continue
            local online state gov
            online=$(cat "$d/online" 2>/dev/null)
            [ -z "$online" ] && online=1   # cpu0 has no 'online' file (always on)
            if [ "$online" = "1" ]; then
                state="🟢 online "
                gov=$(cat "$d/cpufreq/scaling_governor" 2>/dev/null)
            else
                state="⚫ offline"
                # Use policy file to get inherited governor (last value)
                local pol
                for pol in /sys/devices/system/cpu/cpufreq/policy*; do
                    grep -qw "$i" "$pol/related_cpus" 2>/dev/null \
                        && gov=$(cat "$pol/scaling_governor" 2>/dev/null) \
                        && break
                done
            fi
            printf "  cpu%d  %s  %s\n" "$i" "$state" "$gov"
        done
        echo
        echo "Mevcut: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null)"
        echo "Değiştirmek: /cpu_governor <ad>  (reboot'ta sıfırlanır)"
        return
    fi
    # Apply at policy level. For offline policies, briefly online one CPU to
    # accept the write, then restore. big.LITTLE clusters drop offline often.
    local applied=0 skipped=0 woken=""
    for p in /sys/devices/system/cpu/cpufreq/policy*; do
        [ -d "$p" ] || continue
        local affected before
        affected=$(cat "$p/affected_cpus" 2>/dev/null)
        before=$(cat "$p/scaling_governor" 2>/dev/null)
        if [ -z "$affected" ]; then
            # No online CPU in this cluster — bring first related CPU up temporarily
            local first
            first=$(awk '{print $1}' "$p/related_cpus" 2>/dev/null)
            [ -z "$first" ] && { skipped=$((skipped+1)); continue; }
            echo 1 > "/sys/devices/system/cpu/cpu$first/online" 2>/dev/null
            sleep 1
            woken="$woken cpu$first"
        fi
        if echo "$arg" > "$p/scaling_governor" 2>/dev/null; then
            local now
            now=$(cat "$p/scaling_governor")
            if [ "$now" = "$arg" ]; then
                applied=$((applied+1))
            else
                skipped=$((skipped+1))
            fi
        else
            skipped=$((skipped+1))
        fi
    done
    if [ "$applied" -gt 0 ]; then
        local msg="✅ $applied cluster → $arg"
        [ -n "$woken" ] && msg="$msg
(geçici online edildi:$woken — Android tekrar offline'a alacak)"
        [ "$skipped" -gt 0 ] && msg="$msg
⚠ $skipped cluster atlandı (yetki/desteklenmeyen)"
        echo "$msg"
    else
        echo "❌ Hiçbir cluster güncellenmedi (geçersiz governor: $arg?)"
    fi
}

cmd_wakelock() {
    echo "💡 Aktif Wakelock'lar:"
    local src=/sys/kernel/debug/wakeup_sources
    [ ! -r "$src" ] && src=/sys/kernel/wakeup_sources
    [ ! -r "$src" ] && { echo "  wakeup_sources okunamadı"; return; }
    # Show entries with active_count or non-zero active_since
    awk 'NR==1 {next} $0~/^name/ {next}
    {
        # name + counts at fixed positions: name active_count event_count wakeup_count active_since...
        # Filter: prefer entries currently active (active_since > 0)
        if ($6 > 0 || $2 > 0) {
            printf "  %-30s active_count=%s active_since=%s ms\n", $1, $2, $6
        }
    }' "$src" 2>/dev/null | head -20
}

# ─── app management ───────────────────────────────────────────────────────
cmd_freeze() {
    local pkg="$1"
    [ -z "$pkg" ] && { echo "Kullanım: /freeze <paket>"; return; }
    local out
    out=$(pm disable-user --user 0 "$pkg" 2>&1)
    case "$out" in
        *new\ state:\ disabled*) echo "❄️ $pkg donduruldu" ;;
        *) echo "❌ Başarısız: $out" ;;
    esac
}

cmd_unfreeze() {
    local pkg="$1"
    [ -z "$pkg" ] && { echo "Kullanım: /unfreeze <paket>"; return; }
    local out
    out=$(pm enable "$pkg" 2>&1)
    case "$out" in
        *new\ state:\ enabled*) echo "✅ $pkg yeniden aktif" ;;
        *) echo "❌ Başarısız: $out" ;;
    esac
}

cmd_installed() {
    local arg="$1"
    case "$arg" in
        ""|3rd|user) echo "📦 3rd-party paketler (top 30):"; pm list packages -3 2>/dev/null | sed 's/^package://' | head -30 ;;
        disabled|frozen) echo "❄️ Devre dışı paketler:"; pm list packages -d 2>/dev/null | sed 's/^package://' ;;
        system) echo "🤖 Sistem paketleri (top 50):"; pm list packages -s 2>/dev/null | sed 's/^package://' | head -50 ;;
        all) echo "📦 TÜM paketler ($(pm list packages 2>/dev/null | wc -l) toplam, top 50):"; pm list packages 2>/dev/null | sed 's/^package://' | head -50 ;;
        *) echo "Kullanım: /installed [3rd|disabled|system|all]" ;;
    esac
}

# ─── security / audit ─────────────────────────────────────────────────────
cmd_who() {
    echo "👥 Aktif SSH/ADB Oturumları:"
    echo
    echo "SSH:"
    netstat -tn 2>/dev/null | awk '$4~/:22222$/ && $NF=="ESTABLISHED" {print "  " $5}'
    echo
    echo "ADB (5555/55555):"
    netstat -tn 2>/dev/null | awk '($4~/:5555$/ || $4~/:55555$/) && $NF=="ESTABLISHED" {print "  " $5}'
}

cmd_last_boot() {
    echo "🔄 Boot Geçmişi:"
    echo "Şu anki: up $(awk '{printf "%dh %02dm", $1/3600, ($1%3600)/60}' /proc/uptime)"
    echo
    echo "Önceki boot'lar (logcat'ten):"
    logcat -d -b system 2>/dev/null | grep -iE "boot_completed|sys.boot_completed" | tail -3
}

cmd_log() {
    local n="${1:-20}"
    case "$n" in *[!0-9]*) n=20 ;; esac
    [ "$n" -gt 200 ] && n=200
    echo "📝 Bot log son $n satır:"
    echo "─────────"
    tail -n "$n" "$LOGFILE" 2>/dev/null
}

cmd_dump_sms() {
    local out="/data/local/tmp/.sms_dump.txt"
    content query --uri content://sms/inbox \
        --projection _id:address:body:date \
        --sort 'date DESC' 2>/dev/null > "$out"
    local cnt=$(wc -l < "$out")
    if [ "$cnt" -eq 0 ]; then
        echo "📭 SMS yok"
        rm -f "$out"
        return
    fi
    tg_send "$1" "📨 SMS dump ($cnt mesaj) gönderiliyor..." >/dev/null
    tg_send_document "$1" "$out" "📨 SMS Dump ($cnt mesaj)" >/dev/null
    rm -f "$out"
}

# ─── bot self-management ──────────────────────────────────────────────────
cmd_bot_stats() {
    local up_s
    up_s=$(awk -v s="$(date +%s)" -v b="$BOT_START_EPOCH" 'BEGIN{print s-b}')
    local up_h=$((up_s/3600))
    local up_m=$(((up_s%3600)/60))
    local msg_count err_count
    msg_count=$(grep -c "^\[.*\] msg from " "$LOGFILE" 2>/dev/null || echo 0)
    err_count=$(grep -ciE "error|fail|bad api" "$LOGFILE" 2>/dev/null || echo 0)
    local log_size
    log_size=$(stat -c %s "$LOGFILE" 2>/dev/null || echo 0)
    cat <<EOF
🤖 Bot İstatistikleri

Version:    $BOT_VERSION
Uptime:     ${up_h}sa ${up_m}dk
Mesaj:      $msg_count
Hata sat.:  $err_count
Log size:   $((log_size/1024)) KB
PID:        $$
EOF
}

cmd_restart_bot() {
    echo "🔄 Bot yeniden başlatılıyor..."
    log "Bot restart requested via command"
    # Spawn detached killer so we can return reply first
    ( sleep 2; kill $(cat "$DATADIR/bot.pid" 2>/dev/null) ) &
}

# ─── quiet hours / heartbeat ──────────────────────────────────────────────
QUIET_FILE="$DATADIR/quiet_hours.conf"
HEARTBEAT_CONF="$DATADIR/heartbeat.conf"
LAST_HEARTBEAT="$DATADIR/.last_heartbeat"
BOT_START_EPOCH=$(date +%s)

is_quiet_hours() {
    # Returns 0 if currently in quiet window
    [ -f "$QUIET_FILE" ] || return 1
    local from to now
    from=$(awk -F= '/^from=/{print $2}' "$QUIET_FILE")
    to=$(awk -F= '/^to=/{print $2}' "$QUIET_FILE")
    [ -z "$from" ] || [ -z "$to" ] && return 1
    now=$(date +%H)
    # Decimal compare via 10# prefix to avoid octal mishaps on leading-zero hours
    now=$((10#$now)); from=$((10#$from)); to=$((10#$to))
    if [ "$from" -lt "$to" ]; then
        [ "$now" -ge "$from" ] && [ "$now" -lt "$to" ]
    else
        # Wraps midnight
        [ "$now" -ge "$from" ] || [ "$now" -lt "$to" ]
    fi
}

cmd_quiet_hours() {
    local args="$1"
    if [ -z "$args" ] || [ "$args" = "status" ]; then
        if [ -f "$QUIET_FILE" ]; then
            local from to state
            from=$(awk -F= '/^from=/{print $2}' "$QUIET_FILE")
            to=$(awk -F= '/^to=/{print $2}' "$QUIET_FILE")
            state="${MSG[qh_inactive]}"
            is_quiet_hours && state="${MSG[qh_active]}"
            tf qh_status_fmt "$from" "$to" "$state"
        else
            echo "${MSG[qh_not_set]}"
        fi
        return
    fi
    if [ "$args" = "off" ] || [ "$args" = "kapat" ]; then
        rm -f "$QUIET_FILE"
        echo "${MSG[qh_off]}"
        return
    fi
    local from to
    from=$(echo "$args" | awk '{print $1}')
    to=$(echo "$args" | awk '{print $2}')
    case "$from" in ''|*[!0-9]*) echo "${MSG[qh_invalid_from]}"; return ;; esac
    case "$to" in ''|*[!0-9]*) echo "${MSG[qh_invalid_to]}"; return ;; esac
    [ "$from" -lt 0 ] || [ "$from" -gt 23 ] && { echo "${MSG[qh_range_from]}"; return; }
    [ "$to" -lt 0 ] || [ "$to" -gt 23 ] && { echo "${MSG[qh_range_to]}"; return; }
    { echo "from=$from"; echo "to=$to"; } > "$QUIET_FILE"
    tf qh_set_fmt "$from" "$to"
}

cmd_heartbeat() {
    local args="$1"
    if [ -z "$args" ] || [ "$args" = "status" ]; then
        if [ -f "$HEARTBEAT_CONF" ]; then
            local intv
            intv=$(awk -F= '/^interval=/{print $2}' "$HEARTBEAT_CONF")
            tf hb_status_fmt "$((intv/3600))"
        else
            echo "${MSG[hb_not_set]}"
        fi
        return
    fi
    if [ "$args" = "off" ] || [ "$args" = "kapat" ]; then
        rm -f "$HEARTBEAT_CONF" "$LAST_HEARTBEAT"
        echo "${MSG[hb_disabled]}"
        return
    fi
    case "$args" in *[!0-9]*) echo "${MSG[hb_not_number]}"; return ;; esac
    [ "$args" -lt 1 ] && { echo "${MSG[hb_min_one]}"; return; }
    local secs=$((args * 3600))
    echo "interval=$secs" > "$HEARTBEAT_CONF"
    date +%s > "$LAST_HEARTBEAT"
    tf hb_set_fmt "$args"
}

poll_heartbeat() {
    [ ! -f "$HEARTBEAT_CONF" ] && return
    [ -z "$OWNER" ] && return
    local intv last now
    intv=$(awk -F= '/^interval=/{print $2}' "$HEARTBEAT_CONF")
    [ -z "$intv" ] && return
    last=$(cat "$LAST_HEARTBEAT" 2>/dev/null || echo 0)
    now=$(date +%s)
    if [ $((now - last)) -ge "$intv" ]; then
        is_quiet_hours && return
        tg_send "$OWNER" "$(printf "${MSG[hb_ping_fmt]}" "$(greeting)" "$(fmt_uptime)" "$(fmt_temp)")" >/dev/null
        echo "$now" > "$LAST_HEARTBEAT"
        log "heartbeat sent"
    fi
}

# ─── scheduler / alarm ────────────────────────────────────────────────────
SCHEDULES_FILE="$DATADIR/schedules.txt"

cmd_alarm() {
    # /alarm HH:MM <message>   one-shot at next occurrence of HH:MM
    local args="$1"
    [ -z "$args" ] && { echo "${MSG[alarm_usage]}"; return; }
    local time_part
    time_part=$(echo "$args" | awk '{print $1}')
    local msg
    msg=$(echo "$args" | awk '{$1=""; sub(/^ /,""); print}')
    [ -z "$msg" ] && { echo "${MSG[alarm_no_msg]}"; return; }
    local h m
    h=$(echo "$time_part" | cut -d: -f1)
    m=$(echo "$time_part" | cut -d: -f2)
    case "$h" in ''|*[!0-9]*) echo "${MSG[alarm_bad_hour]}"; return ;; esac
    case "$m" in ''|*[!0-9]*) echo "${MSG[alarm_bad_min]}"; return ;; esac
    h=$((10#$h)); m=$((10#$m))
    [ "$h" -gt 23 ] || [ "$m" -gt 59 ] && { echo "${MSG[alarm_bad_time]}"; return; }

    local now=$(date +%s)
    local cur_h cur_m cur_s
    cur_h=$(date +%H); cur_m=$(date +%M); cur_s=$(date +%S)
    cur_h=$((10#$cur_h)); cur_m=$((10#$cur_m)); cur_s=$((10#$cur_s))
    local secs_today=$((cur_h * 3600 + cur_m * 60 + cur_s))
    local midnight=$((now - secs_today))
    local today_target=$((midnight + h * 3600 + m * 60))
    if [ "$today_target" -le "$now" ]; then
        today_target=$((today_target + 86400))
    fi

    mkdir -p "$(dirname "$SCHEDULES_FILE")"
    echo "$today_target|alarm|$msg" >> "$SCHEDULES_FILE"
    local diff=$((today_target - now))
    tf alarm_set_fmt "$(printf "%02d" "$h")" "$(printf "%02d" "$m")" "$((diff/3600))" "$((diff%3600/60))" "$msg"
}

cmd_schedule() {
    # /schedule <interval-secs> <command>  → recurring relative schedule
    # /schedule list                        → show pending
    # /schedule clear                       → wipe all
    # /schedule cancel <idx>                → remove one by index
    local arg1
    arg1=$(echo "$1" | awk '{print $1}')
    case "$arg1" in
        ""|status|list)
            if [ ! -s "$SCHEDULES_FILE" ]; then
                echo "${MSG[sch_empty]}"
                return
            fi
            echo "${MSG[sch_header]}"
            local i=0 now=$(date +%s)
            while IFS='|' read -r when type rest; do
                i=$((i+1))
                local in_sec=$((when - now))
                local in_label
                if [ "$in_sec" -lt 0 ]; then in_label="${MSG[sch_now_label]}"
                elif [ "$in_sec" -lt 60 ]; then in_label=$(printf "${MSG[sch_sec_fmt]}" "$in_sec")
                elif [ "$in_sec" -lt 3600 ]; then in_label=$(printf "${MSG[sch_min_fmt]}" "$((in_sec/60))")
                else in_label=$(printf "${MSG[sch_hour_fmt]}" "$((in_sec/3600))" "$(((in_sec%3600)/60))")
                fi
                printf "${MSG[sch_entry_fmt]}" "$i" "$type" "$rest" "$in_label"
            done < "$SCHEDULES_FILE"
            return ;;
        clear)
            rm -f "$SCHEDULES_FILE"; echo "${MSG[sch_cleared]}"; return ;;
        cancel)
            local idx
            idx=$(echo "$1" | awk '{print $2}')
            [ -z "$idx" ] && { echo "${MSG[sch_cancel_usage]}"; return; }
            local tmp="${SCHEDULES_FILE}.tmp"
            awk -v drop="$idx" 'NR != drop' "$SCHEDULES_FILE" > "$tmp" && mv "$tmp" "$SCHEDULES_FILE"
            tf sch_cancelled_fmt "$idx"; return ;;
    esac

    # Recurring schedule: <secs> <command>
    local secs cmd
    secs=$(echo "$1" | awk '{print $1}')
    cmd=$(echo "$1" | awk '{$1=""; sub(/^ /,""); print}')
    case "$secs" in *[!0-9]*) echo "${MSG[sch_invalid_usage]}"; return ;; esac
    [ -z "$cmd" ] && { echo "${MSG[sch_no_cmd]}"; return; }
    [ "$secs" -lt 10 ] && { echo "${MSG[sch_min_secs]}"; return; }

    local now=$(date +%s)
    local next=$((now + secs))
    mkdir -p "$(dirname "$SCHEDULES_FILE")"
    echo "$next|recur:$secs|$cmd" >> "$SCHEDULES_FILE"
    tf sch_added_fmt "$secs" "$cmd" "$secs"
}

poll_schedules() {
    [ ! -s "$SCHEDULES_FILE" ] && return
    local now=$(date +%s)
    local tmp="${SCHEDULES_FILE}.tmp"
    : > "$tmp"
    while IFS='|' read -r when type rest; do
        [ -z "$when" ] && continue
        if [ "$when" -le "$now" ]; then
            # Due — fire
            case "$type" in
                alarm)
                    is_quiet_hours || tg_send "$OWNER" "$(printf "${MSG[alarm_fired_fmt]}" "$rest")" >/dev/null
                    log "alarm fired: $rest"
                    ;;
                recur:*)
                    local interval="${type#recur:}"
                    case "$rest" in
                        /*)
                            local out
                            out=$(dispatch_for_schedule "$rest")
                            [ -n "$out" ] && tg_send "$OWNER" "$(printf "${MSG[sch_fire_fmt]}" "$rest" "$out")" >/dev/null
                            ;;
                        *)
                            local out
                            out=$(sh -c "$rest" 2>&1 | head -c 1500)
                            tg_send "$OWNER" "$(printf "${MSG[sch_fire_fmt]}" "$rest" "$out")" >/dev/null
                            ;;
                    esac
                    local next=$((now + interval))
                    echo "$next|$type|$rest" >> "$tmp"
                    log "schedule fired: $rest, next in ${interval}s"
                    ;;
            esac
        else
            # Not due yet — keep
            echo "$when|$type|$rest" >> "$tmp"
        fi
    done < "$SCHEDULES_FILE"
    mv "$tmp" "$SCHEDULES_FILE"
}

# Lightweight dispatch for scheduled commands (no msg_id, output → string)
dispatch_for_schedule() {
    local text="$1"
    local cmd args
    cmd=$(echo "$text" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
    args=$(echo "$text" | awk '{$1=""; sub(/^ /,""); print}')
    case "$cmd" in
        /status) cmd_status ;;
        /uptime) echo "⏱ $(fmt_uptime)" ;;
        /signal) fmt_signal ;;
        /temp)   echo "🌡 $(fmt_temp)" ;;
        /mem)    echo "💾 $(fmt_mem)" ;;
        /disk)   echo "💿 $(fmt_disk)" ;;
        /traffic) fmt_traffic ;;
        /load)   fmt_load ;;
        /ip)     cmd_ip ;;
        *) tf sch_unsupported_fmt "$cmd" ;;
    esac
}

# ─── /upload handler (intercepts next document/photo from owner) ──────────
UPLOAD_STATE="$DATADIR/pending_upload"

cmd_upload() {
    local chat_id="$1"
    local target_path="$2"
    if [ -z "$target_path" ]; then
        tg_send "$chat_id" "${MSG[upload_usage_fmt]}"
        return
    fi
    {
        echo "path=$target_path"
        echo "created=$(date +%s)"
    } > "$UPLOAD_STATE"
    tg_send "$chat_id" "$(printf "${MSG[upload_waiting_fmt]}" "$target_path")"
}

handle_upload_response() {
    # $1 chat_id, $2 file_id (or longest photo size's file_id), $3 (opt) original_filename
    local chat_id="$1"
    local file_id="$2"
    local orig_name="$3"
    [ ! -f "$UPLOAD_STATE" ] && return 1
    local target created now
    target=$(awk -F= '/^path=/{print $2}' "$UPLOAD_STATE")
    created=$(awk -F= '/^created=/{print $2}' "$UPLOAD_STATE")
    now=$(date +%s)
    [ $((now - created)) -gt 120 ] && { rm -f "$UPLOAD_STATE"; return 1; }

    # Get file_path from Telegram
    local resp file_path
    resp=$("$CURL" -sS --cacert "$CA" --max-time 10 \
        "${TG_API}${TOKEN}/getFile?file_id=$file_id" 2>/dev/null)
    file_path=$(echo "$resp" | "$JQ" -r '.result.file_path // empty' 2>/dev/null)
    if [ -z "$file_path" ]; then
        rm -f "$UPLOAD_STATE"
        tg_send "$chat_id" "$(printf "${MSG[upload_getfile_failed_fmt]}" "$(echo "$resp" | head -c 200)")"
        return 0
    fi

    # Determine final path
    local final_path
    if [ -d "$target" ] || echo "$target" | grep -qE '/$'; then
        local fname="${orig_name:-$(basename "$file_path")}"
        final_path="${target%/}/$fname"
    else
        final_path="$target"
    fi

    # Download
    local dl_url="https://api.telegram.org/file/bot${TOKEN}/${file_path}"
    if "$CURL" -sSL --cacert "$CA" --max-time 120 -o "$final_path" "$dl_url"; then
        local sz
        sz=$(stat -c %s "$final_path" 2>/dev/null || echo 0)
        rm -f "$UPLOAD_STATE"
        tg_send "$chat_id" "$(printf "${MSG[upload_saved_fmt]}" "$final_path" "$((sz/1024))")"
    else
        rm -f "$UPLOAD_STATE"
        tg_send "$chat_id" "${MSG[upload_download_failed]}"
    fi
    return 0
}

# ─── tailscale (exit-node, adaptive routing, optional separate module) ────
TS_DIR=/data/tailscale
# Resolve binaries at call time — prefer /system/bin (live overlay), then
# module dir (works pre-reboot after install), then modules_update (staged)
ts_find_bin() {
    local name="$1"
    for p in \
        "/system/bin/$name" \
        "/data/adb/modules/tailscale-control/system/bin/$name" \
        "/data/adb/modules_update/tailscale-control/system/bin/$name"
    do
        [ -x "$p" ] && { echo "$p"; return 0; }
    done
    return 1
}
TS_SOCK="$TS_DIR/tailscaled.sock"
TS_STATE="$TS_DIR/tailscaled.state"
TS_LOG="$TS_DIR/tailscaled.log"
TS_PID="$TS_DIR/tailscaled.pid"
TS_AUTHKEY="$TS_DIR/authkey"

ts_is_running() {
    [ -f "$TS_PID" ] || return 1
    local p
    p=$(cat "$TS_PID" 2>/dev/null)
    [ -n "$p" ] && kill -0 "$p" 2>/dev/null
}

ts_cli() {
    local bin
    bin=$(ts_find_bin tailscale) || return 1
    "$bin" --socket="$TS_SOCK" "$@"
}

ts_add_iptables() {
    # Source-based MASQUERADE — adaptive (no -o), only matches tailnet peers.
    # All three rules are idempotent via -C check.
    iptables -t nat -C POSTROUTING -s 100.64.0.0/10 -j MASQUERADE 2>/dev/null \
        || iptables -t nat -A POSTROUTING -s 100.64.0.0/10 -j MASQUERADE
    iptables -C FORWARD -i tailscale0 -j ACCEPT 2>/dev/null \
        || iptables -A FORWARD -i tailscale0 -j ACCEPT
    iptables -C FORWARD -o tailscale0 -j ACCEPT 2>/dev/null \
        || iptables -A FORWARD -o tailscale0 -j ACCEPT
}

ts_del_iptables() {
    iptables -t nat -D POSTROUTING -s 100.64.0.0/10 -j MASQUERADE 2>/dev/null
    iptables -D FORWARD -i tailscale0 -j ACCEPT 2>/dev/null
    iptables -D FORWARD -o tailscale0 -j ACCEPT 2>/dev/null
}

cmd_tailscale() {
    local args="$1"
    local sub
    sub=$(echo "$args" | awk '{print $1}')
    [ -z "$sub" ] && sub=status

    # Resolve binaries lazily — works after install before reboot too
    local TS_BIN TSD_BIN
    TS_BIN=$(ts_find_bin tailscale)
    TSD_BIN=$(ts_find_bin tailscaled)
    if [ -z "$TS_BIN" ] || [ -z "$TSD_BIN" ]; then
        echo "${MSG[ts_binary_missing]}"
        return
    fi

    case "$sub" in
        status)
            if ts_is_running; then
                local ts_ip pinfo
                ts_ip=$(ts_cli ip -4 2>/dev/null | head -1)
                pinfo=$(ts_cli status --self=true --peers=false 2>/dev/null | head -3)
                local pid rss
                pid=$(cat "$TS_PID" 2>/dev/null)
                rss=$(awk '/^VmRSS:/{print $2}' /proc/"$pid"/status 2>/dev/null)
                printf "${MSG[ts_status_on_fmt]}\n" "$pid" "$((rss/1024))" "${ts_ip:-${MSG[ts_ip_pending]}}" "$pinfo"
            else
                local hint="${MSG[ts_hint_on]}"
                [ ! -s "$TS_AUTHKEY" ] && [ ! -s "$TS_STATE" ] && hint="${MSG[ts_hint_auth_first]}"
                printf "${MSG[ts_status_off_fmt]}\n" "$hint"
            fi
            ;;
        on)
            if ts_is_running; then
                echo "${MSG[ts_already_running]}"
                return
            fi
            mkdir -p "$TS_DIR" "$TS_DIR/cache"
            chmod 700 "$TS_DIR"
            # Cleanup leftovers from any prior crash (idempotent)
            rm -f "$TS_SOCK" "$TS_PID"
            ip link delete tailscale0 2>/dev/null  # orphan TUN from previous run
            # ip_forward (idempotent, mostly already 1 on Android with hotspot)
            echo 1 > /proc/sys/net/ipv4/ip_forward 2>/dev/null
            # Start daemon (fwmark=0x80000 default → adaptive routing)
            # - HOME/XDG_CACHE_HOME: tailscaled needs writable cache for logpolicy
            # - TS_DEBUG_FIREWALL_MODE=iptables: skip nftables auto-detect (Android
            #   kernel returns EINVAL on listTables netlink → fatal panic otherwise)
            HOME="$TS_DIR" XDG_CACHE_HOME="$TS_DIR/cache" \
            TS_DEBUG_FIREWALL_MODE=iptables \
            nohup "$TSD_BIN" \
                --tun=tailscale0 \
                --state="$TS_STATE" \
                --socket="$TS_SOCK" \
                --statedir="$TS_DIR" \
                >> "$TS_LOG" 2>&1 &
            echo $! > "$TS_PID"
            # Wait for control socket
            local i=0
            while [ "$i" -lt 15 ]; do
                [ -S "$TS_SOCK" ] && break
                sleep 1; i=$((i+1))
            done
            if [ ! -S "$TS_SOCK" ]; then
                rm -f "$TS_PID"
                tf ts_daemon_failed_fmt "$(tail -5 "$TS_LOG" 2>/dev/null)"
                return
            fi
            # iptables (source-based, adaptive — no -o)
            ts_add_iptables
            # tailscale up
            local upargs="--advertise-exit-node --accept-dns=false --accept-routes=false --hostname=ZTE-F50"
            local key
            if [ -s "$TS_AUTHKEY" ]; then
                key=$(cat "$TS_AUTHKEY")
                upargs="$upargs --auth-key=$key"
            fi
            local upresp
            upresp=$(ts_cli up $upargs 2>&1)
            sleep 2
            local ts_ip
            ts_ip=$(ts_cli ip -4 2>/dev/null | head -1)
            if [ -n "$ts_ip" ]; then
                log "tailscale on: ip=$ts_ip"
                tf ts_active_fmt "$ts_ip"
            else
                # Login URL fallback (no authkey or new node)
                local login
                login=$(echo "$upresp" | grep -oE 'https://login\.tailscale\.com[^ ]*' | head -1)
                if [ -n "$login" ]; then
                    tf ts_login_required_fmt "$login"
                else
                    tf ts_up_response_fmt "$(echo "$upresp" | head -c 800)"
                fi
            fi
            ;;
        off)
            if ! ts_is_running; then
                ts_del_iptables  # cleanup any orphan rules
                echo "${MSG[ts_already_off]}"
                return
            fi
            ts_cli down 2>/dev/null
            local pid
            pid=$(cat "$TS_PID" 2>/dev/null)
            [ -n "$pid" ] && kill "$pid" 2>/dev/null
            sleep 2
            ts_is_running && kill -9 "$(cat "$TS_PID")" 2>/dev/null
            rm -f "$TS_PID"
            ts_del_iptables
            log "tailscale off"
            echo "${MSG[ts_stopped]}"
            ;;
        auth)
            local key
            key=$(echo "$args" | awk '{print $2}')
            if [ -z "$key" ]; then
                echo "${MSG[ts_auth_usage]}"
                return
            fi
            mkdir -p "$TS_DIR"
            chmod 700 "$TS_DIR"
            printf "%s" "$key" > "$TS_AUTHKEY"
            chmod 600 "$TS_AUTHKEY"
            tf ts_auth_saved_fmt "$(wc -c < "$TS_AUTHKEY")"
            ;;
        logout)
            if ts_is_running; then
                ts_cli logout 2>/dev/null
                sleep 1
                local pid
                pid=$(cat "$TS_PID" 2>/dev/null)
                [ -n "$pid" ] && kill "$pid" 2>/dev/null
            fi
            ts_del_iptables
            rm -f "$TS_STATE" "$TS_PID" "$TS_AUTHKEY"
            log "tailscale logout + state wiped"
            echo "${MSG[ts_logout_done]}"
            ;;
        ip)
            ts_is_running || { echo "${MSG[ts_off_short]}"; return; }
            ts_cli ip 2>/dev/null
            ;;
        peers)
            ts_is_running || { echo "${MSG[ts_off_short]}"; return; }
            ts_cli status 2>/dev/null | head -30
            ;;
        log)
            [ ! -f "$TS_LOG" ] && { echo "${MSG[ts_log_none]}"; return; }
            echo "${MSG[ts_log_header]}"
            tail -20 "$TS_LOG"
            ;;
        *)
            echo "${MSG[ts_usage]}" ;;
    esac
}

# ─── /lang — switch UI language ──────────────────────────────────────────
cmd_lang() {
    local arg
    arg=$(echo "$1" | awk '{print $1}' | tr -d ' \r\n')

    # No argument: show current + available languages
    if [ -z "$arg" ] || [ "$arg" = "status" ]; then
        tf lang_current_fmt "$USER_LANG"
        echo
        t lang_available_header
        local f
        for f in "$MODDIR"/lang/*.sh; do
            [ -f "$f" ] || continue
            local code
            code=$(basename "$f" .sh)
            local marker=" "
            [ "$code" = "$USER_LANG" ] && marker="✓"
            echo "  $marker $code"
        done
        echo
        t lang_usage
        return
    fi

    # Validate the requested code (file must exist)
    if [ ! -r "$MODDIR/lang/${arg}.sh" ]; then
        tf lang_invalid_fmt "$arg"
        return
    fi

    # Persist + restart bot for full reload
    mkdir -p "$DATADIR"
    printf "%s\n" "$arg" > "$LANG_FILE_PREF"
    log "lang switched: $USER_LANG -> $arg"
    tf lang_set_fmt "$arg"
    ( sleep 3; kill $(cat "$DATADIR/bot.pid" 2>/dev/null) ) >/dev/null 2>&1 &
}

# ─── /update — fetch latest module versions from GitHub updateJson ───────
# Walks /data/adb/modules/*/module.prop, reads updateJson URL, fetches version,
# compares with installed version. Optionally installs newer ones.
cmd_update() {
    local arg
    arg=$(echo "$1" | awk '{print $1}')
    local target_id
    target_id=$(echo "$1" | awk '{print $2}')

    case "$arg" in
        ""|check|status)
            echo "${MSG[update_header]}"
            echo
            local found=0 outdated=0
            local mod_dir cur_ver cur_vcode cur_id update_url remote_resp remote_ver remote_vcode
            for mod_dir in /data/adb/modules/*/; do
                [ -f "$mod_dir/module.prop" ] || continue
                update_url=$(awk -F= '/^updateJson=/{print $2; exit}' "$mod_dir/module.prop")
                [ -z "$update_url" ] && continue
                cur_id=$(awk -F= '/^id=/{print $2; exit}' "$mod_dir/module.prop")
                cur_ver=$(awk -F= '/^version=/{print $2; exit}' "$mod_dir/module.prop")
                cur_vcode=$(awk -F= '/^versionCode=/{print $2; exit}' "$mod_dir/module.prop")
                found=$((found+1))
                remote_resp=$("$CURL" -sSL --cacert "$CA" --max-time 15 "$update_url" 2>/dev/null)
                if [ -z "$remote_resp" ]; then
                    tf update_remote_unread_fmt "$cur_id" "$cur_ver"
                    continue
                fi
                remote_ver=$(echo "$remote_resp"   | "$JQ" -r '.version // empty' 2>/dev/null)
                remote_vcode=$(echo "$remote_resp" | "$JQ" -r '.versionCode // empty' 2>/dev/null)
                if [ -z "$remote_vcode" ]; then
                    tf update_parse_fail_fmt "$cur_id" "$cur_ver"
                    continue
                fi
                if [ "$remote_vcode" -gt "$cur_vcode" ] 2>/dev/null; then
                    tf update_outdated_fmt "$cur_id" "$cur_ver" "$remote_ver" "$cur_vcode" "$remote_vcode"
                    outdated=$((outdated+1))
                else
                    tf update_uptodate_fmt "$cur_id" "$cur_ver"
                fi
            done
            echo
            if [ "$found" -eq 0 ]; then
                echo "${MSG[update_none_defined]}"
            elif [ "$outdated" -eq 0 ]; then
                echo "${MSG[update_all_current]}"
            else
                tf update_count_outdated_fmt "$outdated"
            fi ;;
        all)
            echo "${MSG[update_all_start]}"
            local total=0 updated=0 failed=0
            local mod_dir update_url cur_id cur_vcode remote_resp remote_ver remote_vcode zipurl
            for mod_dir in /data/adb/modules/*/; do
                [ -f "$mod_dir/module.prop" ] || continue
                update_url=$(awk -F= '/^updateJson=/{print $2; exit}' "$mod_dir/module.prop")
                [ -z "$update_url" ] && continue
                cur_id=$(awk -F= '/^id=/{print $2; exit}' "$mod_dir/module.prop")
                cur_vcode=$(awk -F= '/^versionCode=/{print $2; exit}' "$mod_dir/module.prop")
                total=$((total+1))
                remote_resp=$("$CURL" -sSL --cacert "$CA" --max-time 15 "$update_url" 2>/dev/null)
                remote_vcode=$(echo "$remote_resp" | "$JQ" -r '.versionCode // empty' 2>/dev/null)
                remote_ver=$(echo "$remote_resp"   | "$JQ" -r '.version // empty' 2>/dev/null)
                zipurl=$(echo "$remote_resp"       | "$JQ" -r '.zipUrl // empty' 2>/dev/null)
                if [ -z "$remote_vcode" ] || [ "$remote_vcode" -le "$cur_vcode" ] 2>/dev/null; then
                    continue
                fi
                if [ -z "$zipurl" ]; then
                    tf update_no_zipurl_fmt "$cur_id"
                    failed=$((failed+1))
                    continue
                fi
                tf update_downloading_fmt "$cur_id" "$remote_ver"
                local tmp_zip=/data/local/tmp/.update_$cur_id.zip
                if "$CURL" -sSL --cacert "$CA" --max-time 300 -o "$tmp_zip" "$zipurl"; then
                    if magisk --install-module "$tmp_zip" 2>&1 | grep -q "Done"; then
                        if [ "$cur_id" = "statusbot" ] && [ -f "/data/adb/modules_update/statusbot/bot/bot.sh" ]; then
                            cp /data/adb/modules_update/statusbot/bot/bot.sh /data/adb/modules/statusbot/bot/bot.sh
                            chmod 755 /data/adb/modules/statusbot/bot/bot.sh
                        fi
                        tf update_installed_fmt "$cur_id" "$remote_ver"
                        updated=$((updated+1))
                    else
                        tf update_install_failed_fmt "$cur_id"
                        failed=$((failed+1))
                    fi
                    rm -f "$tmp_zip"
                else
                    tf update_download_failed_fmt "$cur_id"
                    failed=$((failed+1))
                fi
            done
            echo
            tf update_summary_fmt "$total" "$updated" "$failed"
            if [ "$updated" -gt 0 ]; then
                echo "${MSG[update_reboot_hint]}"
                if grep -q "statusbot.*✅" /data/statusbot/bot.log.tmp 2>/dev/null; then
                    ( sleep 3; kill $(cat "$DATADIR/bot.pid" 2>/dev/null) ) &
                fi
            fi ;;
        *)
            local mod_dir="/data/adb/modules/$arg"
            if [ ! -d "$mod_dir" ]; then
                tf update_module_not_found_fmt "$arg"
                return
            fi
            local update_url cur_vcode cur_id remote_resp remote_vcode remote_ver zipurl
            update_url=$(awk -F= '/^updateJson=/{print $2; exit}' "$mod_dir/module.prop")
            if [ -z "$update_url" ]; then
                tf update_no_updatejson_fmt "$arg"
                return
            fi
            cur_id=$(awk -F= '/^id=/{print $2; exit}' "$mod_dir/module.prop")
            cur_vcode=$(awk -F= '/^versionCode=/{print $2; exit}' "$mod_dir/module.prop")
            remote_resp=$("$CURL" -sSL --cacert "$CA" --max-time 15 "$update_url" 2>/dev/null)
            remote_vcode=$(echo "$remote_resp" | "$JQ" -r '.versionCode // empty' 2>/dev/null)
            remote_ver=$(echo "$remote_resp"   | "$JQ" -r '.version // empty' 2>/dev/null)
            zipurl=$(echo "$remote_resp"       | "$JQ" -r '.zipUrl // empty' 2>/dev/null)
            if [ -z "$remote_vcode" ]; then
                tf update_remote_unread_long_fmt "$(echo "$remote_resp" | head -c 200)"
                return
            fi
            if [ "$remote_vcode" -le "$cur_vcode" ] 2>/dev/null; then
                tf update_already_current_fmt "$cur_id" "$remote_ver"
                return
            fi
            tf update_downloading_fmt "$cur_id" "$remote_ver"
            local tmp_zip=/data/local/tmp/.update_$cur_id.zip
            "$CURL" -sSL --cacert "$CA" --max-time 300 -o "$tmp_zip" "$zipurl" || {
                echo "${MSG[update_download_failed]}"; return; }
            local install_out
            install_out=$(magisk --install-module "$tmp_zip" 2>&1)
            rm -f "$tmp_zip"
            if echo "$install_out" | grep -q "Done"; then
                if [ "$cur_id" = "statusbot" ] && [ -f "/data/adb/modules_update/statusbot/bot/bot.sh" ]; then
                    cp /data/adb/modules_update/statusbot/bot/bot.sh /data/adb/modules/statusbot/bot/bot.sh
                    chmod 755 /data/adb/modules/statusbot/bot/bot.sh
                    tf update_self_installed_fmt "$remote_ver"
                    ( sleep 5; kill $(cat "$DATADIR/bot.pid" 2>/dev/null) ) &
                else
                    tf update_other_installed_fmt "$cur_id" "$remote_ver"
                fi
            else
                tf update_install_failed_long_fmt "$(echo "$install_out" | tail -5)"
            fi ;;
    esac
}

cmd_iptal() {
    local cancelled=""
    # IMEI sorgu
    if [ -f "$DATADIR/pending_imei_sorgu" ]; then
        rm -f "$DATADIR/pending_imei_sorgu" "$DATADIR/.edevlet_cookies" "$DATADIR/.captcha.png"
        cancelled="$cancelled
${MSG[iptal_imei]}"
    fi
    # Upload
    if [ -f "$DATADIR/pending_upload" ]; then
        rm -f "$DATADIR/pending_upload"
        cancelled="$cancelled
${MSG[iptal_upload]}"
    fi
    # Speedtest loop
    if [ -f "$DATADIR/speedtest_loop.pid" ]; then
        local pid
        pid=$(cat "$DATADIR/speedtest_loop.pid" 2>/dev/null)
        rm -f "$DATADIR/speedtest_loop.pid"
        [ -n "$pid" ] && kill "$pid" 2>/dev/null
        cancelled="$cancelled
${MSG[iptal_speedtest]}"
    fi
    if [ -z "$cancelled" ]; then
        echo "${MSG[iptal_none]}"
    else
        tf iptal_done_fmt "$cancelled"
    fi
}

cmd_file() {
    # $1 chat_id, $2 path
    local chat_id="$1"
    local path="$2"
    if [ -z "$path" ]; then
        tg_send "$chat_id" "${MSG[file_usage]}"
        return
    fi
    if [ ! -f "$path" ]; then
        tg_send "$chat_id" "$(printf "${MSG[file_not_found_fmt]}" "$path")"
        return
    fi
    local size
    size=$(stat -c %s "$path" 2>/dev/null || echo 0)
    if [ "$size" -eq 0 ]; then
        tg_send "$chat_id" "$(printf "${MSG[file_empty_fmt]}" "$path")"
        return
    fi
    if [ "$size" -gt 52428800 ]; then
        tg_send "$chat_id" "$(printf "${MSG[file_too_big_fmt]}" "$((size/1048576))" "$path")"
        return
    fi
    local size_kb
    size_kb=$(awk -v s=$size 'BEGIN{printf "%.1f KB", s/1024}')
    tg_send "$chat_id" "$(printf "${MSG[file_sending_fmt]}" "$size_kb")" >/dev/null
    local resp
    resp=$(tg_send_document "$chat_id" "$path" "$(printf "${MSG[file_caption_fmt]}" "$(basename "$path")")")
    local ok
    ok=$(echo "$resp" | "$JQ" -r '.ok // empty' 2>/dev/null)
    if [ "$ok" != "true" ]; then
        local err
        err=$(echo "$resp" | "$JQ" -r ".description // \"${MSG[file_unknown_error]}\"" 2>/dev/null)
        tg_send "$chat_id" "$(printf "${MSG[file_tg_rejected_fmt]}" "$err")"
    fi
}

cmd_screenshot() {
    local chat_id="$1"
    local out="/data/local/tmp/.statusbot_ss.png"
    rm -f "$out"
    if command -v screencap >/dev/null 2>&1; then
        screencap -p "$out" 2>/dev/null
    fi
    if [ ! -s "$out" ]; then
        tg_send "$chat_id" "${MSG[ss_failed]}"
        return
    fi
    tg_send "$chat_id" "$(printf "${MSG[ss_taken_fmt]}" "$(stat -c %s "$out" 2>/dev/null)")" >/dev/null
    tg_send_photo "$chat_id" "$out" "$(printf "${MSG[ss_caption_fmt]}" "$(date '+%H:%M:%S')")"
    rm -f "$out"
}

cmd_wifi() {
    echo "${MSG[wifi_header]}"
    echo
    # Find hostapd config — ZTE F50 uses /data/vendor/wifi/hostapd/hostapd_wlan0.conf
    local conf
    for p in /data/vendor/wifi/hostapd/hostapd_wlan0.conf \
             /data/vendor/wifi/hostapd/hostapd.conf \
             /data/vendor/wifi/hostapd.conf \
             /data/misc/wifi/hostapd.conf \
             /vendor/etc/hostapd.conf; do
        [ -r "$p" ] && conf="$p" && break
    done
    if [ -n "$conf" ]; then
        # SSID: prefer plaintext 'ssid=' then hex-encoded 'ssid2='
        local ssid ssid_hex pass wpa_ver
        ssid=$(awk -F= '/^ssid=/{print $2; exit}' "$conf" 2>/dev/null)
        if [ -z "$ssid" ]; then
            ssid_hex=$(awk -F= '/^ssid2=/{print $2; exit}' "$conf" 2>/dev/null)
            # Decode hex pairs to ASCII (toybox-safe)
            if [ -n "$ssid_hex" ]; then
                ssid=$(echo "$ssid_hex" | awk '{
                    out = ""
                    for (i=1; i<=length($0); i+=2) {
                        hex = substr($0, i, 2)
                        # Convert hex to decimal
                        decimal = 0
                        for (j=1; j<=2; j++) {
                            c = substr(hex, j, 1)
                            v = index("0123456789abcdef", tolower(c)) - 1
                            decimal = decimal * 16 + v
                        }
                        out = out sprintf("%c", decimal)
                    }
                    print out
                }')
            fi
        fi
        pass=$(awk -F= '/^wpa_passphrase=/{print $2; exit}' "$conf" 2>/dev/null)
        local wpa_num
        wpa_num=$(awk -F= '/^wpa=/{print $2; exit}' "$conf" 2>/dev/null)
        case "$wpa_num" in
            1) wpa_ver="WPA" ;;
            2) wpa_ver="WPA2" ;;
            3) wpa_ver="WPA/WPA2" ;;
            *) wpa_ver="$wpa_num" ;;
        esac

        # Actual operating freq/standard via dumpsys (more accurate than conf)
        local dumpsys_info actual_freq wifi_std bssid
        dumpsys_info=$(dumpsys wifi 2>/dev/null | grep -A2 "mCurrentSoftApInfoMap" | head -3)
        actual_freq=$(echo "$dumpsys_info" | grep -oE 'frequency= [0-9]+' | awk '{print $2}')
        wifi_std=$(echo "$dumpsys_info" | grep -oE 'wifiStandard= [0-9]+' | awk '{print $2}')
        bssid=$(dumpsys wifi 2>/dev/null | grep -oE 'bssid = [0-9a-f:]+' | head -1 | awk '{print $3}')

        local band="?"
        if [ -n "$actual_freq" ]; then
            [ "$actual_freq" -lt 3000 ] && band="2.4 GHz"
            [ "$actual_freq" -gt 3000 ] && band="5 GHz"
        fi
        local std_label="?"
        case "$wifi_std" in
            4) std_label="802.11n" ;;
            5) std_label="802.11ac" ;;
            6) std_label="802.11ax" ;;
            *) std_label="legacy" ;;
        esac

        [ -n "$ssid" ]  && tf wifi_ssid_fmt "$ssid"
        [ -n "$pass" ]  && tf wifi_pass_fmt "$pass"
        [ -n "$wpa_ver" ] && tf wifi_sec_fmt "$wpa_ver"
        [ -n "$bssid" ] && tf wifi_bssid_fmt "$bssid"
        [ -n "$actual_freq" ] && printf "${MSG[wifi_freq_fmt]}\n" "$actual_freq" "$band" "$std_label"
        echo
    else
        echo "${MSG[wifi_no_conf]}"
        echo
    fi

    # Bridge IP
    local br_ip
    br_ip=$(ip -4 -o addr show br0 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
    [ -n "$br_ip" ] && tf wifi_bridge_fmt "$br_ip"
    echo

    # Connected clients from ARP (filter br0 + valid MACs)
    echo "${MSG[wifi_clients_header]}"
    local count=0
    if [ -r /proc/net/arp ]; then
        while IFS= read -r line; do
            local ip mac iface
            ip=$(echo "$line" | awk '{print $1}')
            mac=$(echo "$line" | awk '{print $4}')
            iface=$(echo "$line" | awk '{print $6}')
            [ "$ip" = "IP" ] && continue
            [ "$mac" = "00:00:00:00:00:00" ] && continue
            [ "$iface" != "br0" ] && continue
            echo "  • $ip  $mac"
            count=$((count+1))
        done < /proc/net/arp
    fi
    [ "$count" -eq 0 ] && echo "${MSG[wifi_no_clients]}"
}

cmd_sms_send() {
    local chat_id="$1"
    local args="$2"
    # Parse: first word = number, rest = message
    local num msg
    num=$(echo "$args" | awk '{print $1}')
    msg=$(echo "$args" | awk '{$1=""; sub(/^ /,""); print}')
    if [ -z "$num" ] || [ -z "$msg" ]; then
        tg_send "$chat_id" "${MSG[sms_usage]}"
        return
    fi
    if [ ! -x "$SENDAT" ]; then
        tg_send "$chat_id" "${MSG[sms_no_sendat]}"
        return
    fi
    "$SENDAT" -c "AT+CMGF=1" -n 0 >/dev/null 2>&1
    local resp
    resp=$(printf 'AT+CMGS="%s"\r\n%s\x1A' "$num" "$msg" | xargs -0 -I{} "$SENDAT" -c "{}" -n 0 2>&1)
    case "$resp" in
        *OK*|*CMGS:*) tg_send "$chat_id" "$(printf "${MSG[sms_sent_fmt]}" "$num" "$msg")" ;;
        *)            tg_send "$chat_id" "$(printf "${MSG[sms_failed_fmt]}" "$resp")" ;;
    esac
}

# ─── ZTE goform API (performance mode etc.) ──────────────────────────────
ZTE_BASE="http://localhost:8080"
ZTE_HOST_HDR="Host: 192.168.0.1"
ZTE_REF_HDR="Referer: http://192.168.0.1/index.html"
ZTE_PWD_FILE="$DATADIR/zte_password"

zte_get() {
    # $1 = cmd name → echoes JSON. Pure read, no session needed.
    "$CURL" -sS --max-time 8 \
        -H "$ZTE_HOST_HDR" -H "$ZTE_REF_HDR" \
        "$ZTE_BASE/goform/goform_get_cmd_process?isTest=false&cmd=$1&_=$(date +%s%3N)" 2>/dev/null
}

zte_session_jar() {
    echo "$DATADIR/.zte_session_jar"
}

zte_login() {
    # Establishes session in $(zte_session_jar). Returns 0 on success.
    # KEY: LD and LOGIN must share the same JSESSIONID cookie.
    local pwd
    pwd=$(cat "$ZTE_PWD_FILE" 2>/dev/null)
    [ -z "$pwd" ] && return 1

    local jar
    jar=$(zte_session_jar)
    rm -f "$jar"

    # GET LD — creates JSESSIONID
    local ld_resp ld
    ld_resp=$("$CURL" -sS --max-time 8 -c "$jar" -b "$jar" \
        -H "$ZTE_HOST_HDR" -H "$ZTE_REF_HDR" \
        "$ZTE_BASE/goform/goform_get_cmd_process?isTest=false&cmd=LD&_=$(date +%s%3N)" 2>/dev/null)
    ld=$(echo "$ld_resp" | "$JQ" -r '.LD // empty')
    [ -z "$ld" ] && { rm -f "$jar"; return 1; }

    # JS-exact: SHA256(SHA256(password).upper() + LD_as_returned).upper()
    local pwd_hash1 final_hash
    pwd_hash1=$(printf %s "$pwd" | sha256sum | awk '{print toupper($1)}')
    final_hash=$(printf %s "${pwd_hash1}${ld}" | sha256sum | awk '{print toupper($1)}')

    # LOGIN — keeps same JSESSIONID via -b jar
    local login_resp result
    login_resp=$("$CURL" -sS --max-time 8 -c "$jar" -b "$jar" \
        -H "$ZTE_HOST_HDR" -H "$ZTE_REF_HDR" \
        -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
        -X POST "$ZTE_BASE/goform/goform_set_cmd_process" \
        --data "goformId=LOGIN&isTest=false&password=$final_hash&user=admin" 2>/dev/null)
    result=$(echo "$login_resp" | "$JQ" -r '.result // empty')
    if [ "$result" != "0" ]; then
        rm -f "$jar"
        return 1
    fi
    return 0
}

zte_compute_AD() {
    # Requires active session in $1 (jar). Echoes AD or empty on failure.
    local jar="$1"
    local ver_resp wa cr rd_resp rd parsed AD
    ver_resp=$("$CURL" -sS --max-time 8 -b "$jar" -c "$jar" \
        -H "$ZTE_HOST_HDR" -H "$ZTE_REF_HDR" \
        "$ZTE_BASE/goform/goform_get_cmd_process?isTest=false&cmd=Language,cr_version,wa_inner_version&multi_data=1&_=$(date +%s%3N)" 2>/dev/null)
    wa=$(echo "$ver_resp" | "$JQ" -r '.wa_inner_version // empty')
    cr=$(echo "$ver_resp" | "$JQ" -r '.cr_version // empty')
    [ -z "$wa" ] || [ -z "$cr" ] && return 1
    rd_resp=$("$CURL" -sS --max-time 8 -b "$jar" -c "$jar" \
        -H "$ZTE_HOST_HDR" -H "$ZTE_REF_HDR" \
        "$ZTE_BASE/goform/goform_get_cmd_process?isTest=false&cmd=RD&_=$(date +%s%3N)" 2>/dev/null)
    rd=$(echo "$rd_resp" | "$JQ" -r '.RD // empty')
    [ -z "$rd" ] && return 1
    parsed=$(printf %s "${wa}${cr}" | sha256sum | awk '{print toupper($1)}')
    AD=$(printf %s "${parsed}${rd}" | sha256sum | awk '{print toupper($1)}')
    echo "$AD"
}

zte_set_perf() {
    # $1 = 0 or 1 → echoes result
    zte_login || { echo "login_failed"; return 1; }
    local jar
    jar=$(zte_session_jar)
    local AD
    AD=$(zte_compute_AD "$jar")
    if [ -z "$AD" ]; then
        rm -f "$jar"
        echo "ad_failed"
        return 1
    fi
    local resp
    resp=$("$CURL" -sS --max-time 8 -b "$jar" -c "$jar" \
        -H "$ZTE_HOST_HDR" -H "$ZTE_REF_HDR" \
        -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
        -X POST "$ZTE_BASE/goform/goform_set_cmd_process" \
        --data "goformId=PERFORMANCE_MODE_SETTING&isTest=false&performance_mode=$1&AD=$AD" 2>/dev/null)
    rm -f "$jar"
    echo "$resp" | "$JQ" -r '.result // "unknown"'
}

cmd_performance() {
    # Special return convention: echo "REBOOT_PROMPT|<text>" to ask for reboot button
    local arg="$1"
    case "$arg" in
        ""|status|durum)
            local resp mode
            resp=$(zte_get "performance_mode")
            mode=$(echo "$resp" | "$JQ" -r '.performance_mode // empty')
            case "$mode" in
                1) echo "${MSG[perf_status_on]}" ;;
                0) echo "${MSG[perf_status_off]}" ;;
                *) tf perf_status_unread_fmt "$resp" ;;
            esac
            ;;
        on|aç|1)
            [ ! -s "$ZTE_PWD_FILE" ] && { echo "${MSG[perf_no_password]}"; return; }
            local result
            result=$(zte_set_perf 1)
            if [ "$result" = "success" ]; then
                echo "REBOOT_PROMPT|${MSG[perf_enabled_reboot]}"
            elif [ "$result" = "login_failed" ]; then
                echo "${MSG[perf_login_failed]}"
            else
                tf perf_set_failed_fmt "$result"
            fi
            ;;
        off|kapat|0)
            [ ! -s "$ZTE_PWD_FILE" ] && { echo "${MSG[perf_no_password]}"; return; }
            local result
            result=$(zte_set_perf 0)
            if [ "$result" = "success" ]; then
                echo "REBOOT_PROMPT|${MSG[perf_disabled_reboot]}"
            elif [ "$result" = "login_failed" ]; then
                echo "${MSG[perf_login_failed_short]}"
            else
                tf perf_set_failed_fmt "$result"
            fi
            ;;
        *) echo "${MSG[perf_usage]}" ;;
    esac
}

# ─── balanced performance (perf_mode + cpufreq cap) ──────────────────────
# Caps policy4 (mid A76) and policy7 (big A76) to a chosen MHz so big cluster
# can be woken (only_use_little_core hint lifted via /performance on) without
# hitting 90°C at 2.7 GHz max. Little cluster (policy0) untouched.
cmd_perf_balanced() {
    local arg
    arg=$(echo "$1" | awk '{print $1}')
    local mhz=1800
    case "$arg" in
        ""|status)
            echo "${MSG[pb_header]}"
            for p in /sys/devices/system/cpu/cpufreq/policy4 /sys/devices/system/cpu/cpufreq/policy7; do
                [ -d "$p" ] || continue
                local cur_max hw_max
                cur_max=$(cat "$p/scaling_max_freq" 2>/dev/null)
                hw_max=$(cat "$p/cpuinfo_max_freq" 2>/dev/null)
                printf "${MSG[pb_policy_fmt]}" \
                    "$(basename "$p")" "$((cur_max/1000))" "$((hw_max/1000))"
            done
            echo
            local pmode
            pmode=$(zte_get "performance_mode" 2>/dev/null | "$JQ" -r '.performance_mode // empty' 2>/dev/null)
            case "$pmode" in
                1) echo "${MSG[pb_hint_on]}" ;;
                0) echo "${MSG[pb_hint_off]}" ;;
                *) echo "${MSG[pb_hint_unread]}" ;;
            esac
            echo
            echo "${MSG[pb_usage]}"
            return ;;
        reset)
            local ok=0
            for p in /sys/devices/system/cpu/cpufreq/policy4 /sys/devices/system/cpu/cpufreq/policy7; do
                [ -d "$p" ] || continue
                local hw_max first affected
                hw_max=$(cat "$p/cpuinfo_max_freq" 2>/dev/null)
                [ -z "$hw_max" ] && continue
                affected=$(cat "$p/affected_cpus" 2>/dev/null)
                if [ -z "$affected" ]; then
                    first=$(awk '{print $1}' "$p/related_cpus")
                    echo 1 > "/sys/devices/system/cpu/cpu$first/online" 2>/dev/null
                    sleep 1
                fi
                if echo "$hw_max" > "$p/scaling_max_freq" 2>/dev/null; then
                    ok=$((ok+1))
                fi
            done
            tf pb_reset_fmt "$ok"
            return ;;
        *[!0-9]*)
            tf pb_invalid_mhz_fmt "$arg"
            return ;;
        *)
            mhz="$arg" ;;
    esac

    [ "$mhz" -lt 500 ] && { echo "${MSG[pb_too_low]}"; return; }
    [ "$mhz" -gt 3000 ] && { echo "${MSG[pb_too_high]}"; return; }
    local khz=$((mhz * 1000))

    # Apply cap to mid + big clusters (little untouched)
    local applied=0 lines=""
    for p in /sys/devices/system/cpu/cpufreq/policy4 /sys/devices/system/cpu/cpufreq/policy7; do
        [ -d "$p" ] || continue
        local hw_max first affected
        hw_max=$(cat "$p/cpuinfo_max_freq" 2>/dev/null)
        affected=$(cat "$p/affected_cpus" 2>/dev/null)
        # Bring up first related CPU temporarily if offline (write needs online)
        if [ -z "$affected" ]; then
            first=$(awk '{print $1}' "$p/related_cpus")
            echo 1 > "/sys/devices/system/cpu/cpu$first/online" 2>/dev/null
            sleep 1
        fi
        if echo "$khz" > "$p/scaling_max_freq" 2>/dev/null; then
            local now
            now=$(cat "$p/scaling_max_freq")
            applied=$((applied+1))
            lines="$lines
  $(basename "$p"): cap → $((now/1000)) MHz (hw max $((hw_max/1000)))"
        fi
    done

    if [ "$applied" -eq 0 ]; then
        echo "${MSG[pb_no_clusters]}"
        return
    fi

    local pmode warn=""
    pmode=$(zte_get "performance_mode" 2>/dev/null | "$JQ" -r '.performance_mode // empty' 2>/dev/null)
    if [ "$pmode" != "1" ]; then
        warn="${MSG[pb_warn_hint_off]}"
    fi
    printf "${MSG[pb_applied_fmt]}\n" "$applied" "$lines" "$warn"
}

# ─── minimal mode (allowlist-based, transient) ───────────────────────────
# Approach: KEEP a small allowlist of essentials (cellular stack, SMS, root,
# user VPN, bot itself, thermal). Force-stop ALL OTHER user-space packages.
# `am force-stop` is NON-PERSISTENT — reboot reverts everything. Some packages
# (systemui, launcher) respawn within seconds; persist mode adds pm disable-user
# on top of those.

# Essentials regex (anchored, ERE) — these stay running, nothing else.
MIN_KEEP_RE='^(android|com\.android\.systemui|com\.android\.providers\.media\.module|com\.android\.providers\.settings|com\.android\.networkstack|com\.android\.networkstack\.tethering|com\.android\.NetworkStatsServer\.NetworkStats|com\.android\.networkstack\.permissionconfig|com\.android\.phone|com\.android\.subsys|com\.android\.smspush|com\.android\.se|com\.android\.permissioncontroller|com\.android\.shell|com\.android\.captiveportallogin|com\.android\.providers\.telephony|com\.android\.cellbroadcastreceiver|com\.android\.cellbroadcastservice|com\.android\.cellbroadcastreceiver\.module|com\.android\.location\.fused|com\.android\.providers\.contacts|com\.android\.providers\.media|com\.android\.bluetoothmidiservice|com\.topjohnwu\.magisk|com\.spreadtrum\..*|com\.sprd\..*|com\.zte\.thermalbridge|com\.zte\.telephony\.api|com\.v2ray\..*|com\.wireguard\..*|com\.openvpn\..*|com\.protonvpn\..*)$'

# Heavy respawners — even with /minimal_mode on, they come back. persist mode
# adds pm disable-user for these (revert with /minimal_mode off).
MIN_PKGS_RESPAWN="com.android.systemui
com.android.launcher3
com.zte.web"

# Tracked-list file: every package we disable goes here, one per line.
# /minimal_mode disabled lists it, enable <pkg> selectively reverts.
MIN_DISABLED_FILE="$DATADIR/minimal_disabled.txt"

# Append a package to disabled-list (dedupe)
min_track_disabled() {
    local pkg="$1"
    [ -z "$pkg" ] && return
    touch "$MIN_DISABLED_FILE"
    grep -qxF "$pkg" "$MIN_DISABLED_FILE" || echo "$pkg" >> "$MIN_DISABLED_FILE"
}

# Remove package from disabled-list
min_untrack() {
    local pkg="$1"
    [ ! -f "$MIN_DISABLED_FILE" ] && return
    grep -vxF "$pkg" "$MIN_DISABLED_FILE" > "$MIN_DISABLED_FILE.tmp"
    mv "$MIN_DISABLED_FILE.tmp" "$MIN_DISABLED_FILE"
    [ ! -s "$MIN_DISABLED_FILE" ] && rm -f "$MIN_DISABLED_FILE"
}

cmd_minimal_mode() {
    local sub
    sub=$(echo "$1" | awk '{print $1}')
    case "$sub" in
        ""|status)
            local mem_avail disabled_count
            mem_avail=$(awk '/^MemAvailable:/{printf "%d", $2/1024}' /proc/meminfo)
            disabled_count=$(pm list packages -d 2>/dev/null | wc -l)
            local running_total
            running_total=$(ps -A -o name 2>/dev/null | grep -cE '^com\.|^android\.' || echo 0)
            tf mm_status_fmt "$mem_avail" "$disabled_count" "$running_total" ;;
        list|keep)
            echo "${MSG[mm_allowlist]}" ;;
        preview)
            local would_kill=0 keep=0
            local pkg
            pm list packages 2>/dev/null > "$DATADIR/.pkgs.tmp"
            while IFS= read -r pkg; do
                pkg="${pkg#package:}"
                if echo "$pkg" | grep -qE "$MIN_KEEP_RE"; then
                    keep=$((keep+1))
                else
                    would_kill=$((would_kill+1))
                fi
            done < "$DATADIR/.pkgs.tmp"
            rm -f "$DATADIR/.pkgs.tmp"
            tf mm_preview_fmt "$keep" "$would_kill" ;;
        on|kill)
            local killed=0 skipped=0 mem_before mem_after pkg
            mem_before=$(awk '/^MemAvailable:/{printf "%d", $2/1024}' /proc/meminfo)
            pm list packages 2>/dev/null > "$DATADIR/.pkgs.tmp"
            while IFS= read -r pkg; do
                pkg="${pkg#package:}"
                if echo "$pkg" | grep -qE "$MIN_KEEP_RE"; then
                    skipped=$((skipped+1))
                    continue
                fi
                am force-stop "$pkg" 2>/dev/null && killed=$((killed+1))
            done < "$DATADIR/.pkgs.tmp"
            rm -f "$DATADIR/.pkgs.tmp"
            sleep 2
            mem_after=$(awk '/^MemAvailable:/{printf "%d", $2/1024}' /proc/meminfo)
            log "minimal_mode on: killed=$killed kept=$skipped mem_delta=$((mem_after-mem_before))"
            tf mm_transient_done_fmt "$killed" "$skipped" "$mem_before" "$mem_after" "$((mem_after-mem_before))" ;;
        persist|disable_all)
            local killed=0 disabled=0 mem_before mem_after pkg
            mem_before=$(awk '/^MemAvailable:/{printf "%d", $2/1024}' /proc/meminfo)
            pm list packages 2>/dev/null > "$DATADIR/.pkgs.tmp"
            while IFS= read -r pkg; do
                pkg="${pkg#package:}"
                echo "$pkg" | grep -qE "$MIN_KEEP_RE" && continue
                am force-stop "$pkg" 2>/dev/null && killed=$((killed+1))
            done < "$DATADIR/.pkgs.tmp"
            rm -f "$DATADIR/.pkgs.tmp"
            for pkg in $MIN_PKGS_RESPAWN; do
                if pm disable-user --user 0 "$pkg" 2>/dev/null | grep -q "disabled"; then
                    am force-stop "$pkg" 2>/dev/null
                    min_track_disabled "$pkg"
                    disabled=$((disabled+1))
                fi
            done
            sleep 2
            mem_after=$(awk '/^MemAvailable:/{printf "%d", $2/1024}' /proc/meminfo)
            log "minimal_mode persist: killed=$killed disabled=$disabled mem_delta=$((mem_after-mem_before))"
            tf mm_persist_done_fmt "$killed" "$disabled" "$mem_before" "$mem_after" "$((mem_after-mem_before))" ;;
        off|restore|reset)
            local enabled=0 pkg
            if [ -s "$MIN_DISABLED_FILE" ]; then
                while IFS= read -r pkg; do
                    [ -z "$pkg" ] && continue
                    if pm enable "$pkg" 2>/dev/null | grep -q "enabled"; then
                        enabled=$((enabled+1))
                    fi
                done < "$MIN_DISABLED_FILE"
                rm -f "$MIN_DISABLED_FILE"
            fi
            log "minimal_mode off: enabled=$enabled"
            tf mm_off_done_fmt "$enabled" ;;
        disabled|tracked|disabled_list)
            if [ ! -s "$MIN_DISABLED_FILE" ]; then
                echo "${MSG[mm_disabled_none]}"
                return
            fi
            echo "${MSG[mm_disabled_header]}"
            local i=0 pkg state
            while IFS= read -r pkg; do
                [ -z "$pkg" ] && continue
                i=$((i+1))
                if pm list packages -d 2>/dev/null | grep -qF "package:$pkg"; then
                    state="${MSG[mm_disabled_state_disabled]}"
                else
                    state="${MSG[mm_disabled_state_mismatch]}"
                fi
                printf "  %d. %s  %s\n" "$i" "$pkg" "$state"
            done < "$MIN_DISABLED_FILE"
            echo
            echo "${MSG[mm_disabled_footer]}" ;;
        enable)
            local target
            target=$(echo "$1" | awk '{print $2}')
            if [ -z "$target" ]; then
                echo "${MSG[mm_enable_usage]}"
                return
            fi
            local pkg=""
            if [ -s "$MIN_DISABLED_FILE" ]; then
                if grep -qxF "$target" "$MIN_DISABLED_FILE"; then
                    pkg="$target"
                else
                    pkg=$(grep -iF "$target" "$MIN_DISABLED_FILE" | head -1)
                fi
            fi
            if [ -z "$pkg" ]; then
                tf mm_enable_not_tracked_fmt "$target" "$target"
                return
            fi
            local result
            result=$(pm enable "$pkg" 2>&1)
            case "$result" in
                *enabled*)
                    min_untrack "$pkg"
                    log "minimal_mode enable: $pkg"
                    tf mm_enable_success_fmt "$pkg" ;;
                *)
                    tf mm_enable_failed_fmt "$result" ;;
            esac ;;
        disable)
            local target
            target=$(echo "$1" | awk '{print $2}')
            if [ -z "$target" ]; then
                echo "${MSG[mm_disable_usage]}"
                return
            fi
            if echo "$target" | grep -qE "$MIN_KEEP_RE"; then
                tf mm_disable_essential_fmt "$target" "$target"
                return
            fi
            local result
            result=$(pm disable-user --user 0 "$target" 2>&1)
            case "$result" in
                *disabled*)
                    am force-stop "$target" 2>/dev/null
                    min_track_disabled "$target"
                    log "minimal_mode disable: $target"
                    tf mm_disable_success_fmt "$target" "$target" ;;
                *)
                    tf mm_disable_failed_fmt "$result" ;;
            esac ;;
        *)
            echo "${MSG[mm_usage]}" ;;
    esac
}

# Performance modes user guide
cmd_perf_help() {
    echo "${MSG[perf_help_full]}"
}

cmd_zte_setpw() {
    local pwd="$1"
    if [ -z "$pwd" ]; then
        if [ -s "$ZTE_PWD_FILE" ]; then
            tf zte_pw_set_fmt "$(wc -c < "$ZTE_PWD_FILE")"
        else
            echo "${MSG[zte_pw_usage]}"
        fi
        return
    fi
    printf %s "$pwd" > "$ZTE_PWD_FILE"
    chmod 600 "$ZTE_PWD_FILE"
    tf zte_pw_saved_fmt "$(wc -c < "$ZTE_PWD_FILE")"
}

cmd_imei() {
    [ ! -x "$SENDAT" ] && { echo "❌ sendat yok"; return; }
    local s0=$(at_cmd "AT+CGSN" 0 | sed 's/[^0-9]//g')
    echo "📱 IMEI (slot 0): $s0"
    local s1=$(at_cmd "AT+CGSN" 1 2>/dev/null | sed 's/[^0-9]//g')
    [ -n "$s1" ] && [ "$s1" != "$s0" ] && echo "📱 IMEI (slot 1): $s1"
}

luhn_check() {
    # echo IMEI on stdin; exit 0 if valid Luhn, 1 otherwise
    echo "$1" | awk '
    {
        n = $0
        if (length(n) != 15) exit 1
        for (i = 1; i <= 15; i++) {
            c = substr(n, i, 1)
            if (c !~ /[0-9]/) exit 1
        }
        sum = 0
        for (i = 1; i <= 15; i++) {
            d = substr(n, i, 1) + 0
            # Position i from LEFT. Right pos = 16 - i.
            # Double when right pos is even, i.e., i is even.
            if (i % 2 == 0) {
                d *= 2
                if (d > 9) d -= 9
            }
            sum += d
        }
        if (sum % 10 != 0) exit 1
        exit 0
    }'
}

cmd_imei_degis() {
    [ ! -x "$SENDAT" ] && { echo "❌ sendat yok"; return; }
    local arg1="$1"
    local arg2="$2"
    local pending="$DATADIR/pending_imei_change"
    local now=$(date +%s)

    # Confirmation flow: /imei_degis YES
    if [ "$arg1" = "YES" ]; then
        if [ ! -f "$pending" ]; then
            echo "⚠️ Bekleyen IMEI değişikliği yok. Önce: /imei_degis <yeni_imei>"
            return
        fi
        local ts new_imei
        ts=$(awk -F= '/^ts=/{print $2}' "$pending")
        new_imei=$(awk -F= '/^imei=/{print $2}' "$pending")
        if [ $((now - ts)) -ge 120 ]; then
            rm -f "$pending"
            echo "⚠️ Süre doldu (>2dk). Yeniden başlat."
            return
        fi
        local old=$(at_cmd "AT+CGSN" 0 | sed 's/[^0-9]//g')
        local resp=$(at_cmd "AT+SPIMEI=0,\"$new_imei\"")
        rm -f "$pending"
        echo "📱 IMEI değişikliği uygulandı.
Eski: $old
Yeni: $new_imei
Modem yanıtı: $resp

🔁 5sn içinde cihaz reboot olacak..."
        ( sleep 5; /system/bin/reboot ) &
        return
    fi

    # First step: validate
    if [ -z "$arg1" ]; then
        cat <<'EOF'
Kullanım: /imei_degis <yeni_imei>
- 15 haneli rakam olmalı
- Onay için "/imei_degis YES" yaz (2 dakika içinde)
- Onaylanınca uygulanır + cihaz reboot olur

⚠️ AT+SPIMEI=0,"..." kullanır (Unisoc-spesifik).
Yanlış IMEI cihazı yasal sorunlara sokabilir.
EOF
        return
    fi

    # Validate: 15 digits only
    case "$arg1" in
        ''|*[!0-9]*) echo "❌ IMEI sadece rakam içermeli"; return ;;
    esac
    local len=${#arg1}
    if [ "$len" -ne 15 ]; then
        echo "❌ IMEI 15 hane olmalı (girdiğin $len hane)"
        return
    fi
    if ! luhn_check "$arg1"; then
        echo "❌ Geçersiz IMEI (Luhn checksum tutmuyor).
Son hane check digit'tir, hesaplayıcı kullan."
        return
    fi

    local old=$(at_cmd "AT+CGSN" 0 | sed 's/[^0-9]//g')
    echo "ts=$now"  > "$pending"
    echo "imei=$arg1" >> "$pending"
    cat <<EOF
⚠️ IMEI Değişikliği — Onay Bekleniyor

Mevcut: $old
Yeni:   $arg1

Onaylamak için 2dk içinde:
  /imei_degis YES

Uygulanınca cihaz REBOOT olacak.
EOF
}

cmd_airplane() {
    [ ! -x "$SENDAT" ] && { echo "${MSG[airplane_no_sendat]}"; return; }
    local action="$1"
    case "$action" in
        on|açik|açık|kapat)
            local resp=$(at_cmd "AT+CFUN=4")
            printf "${MSG[airplane_on_fmt]}\n" "$resp" ;;
        off|kapali|kapalı|aç)
            local resp=$(at_cmd "AT+CFUN=1")
            printf "${MSG[airplane_off_fmt]}\n" "$resp" ;;
        ""|status|durum)
            local resp=$(at_cmd "AT+CFUN?")
            local mode=$(echo "$resp" | sed -n 's/.*+CFUN: *\([0-9]*\).*/\1/p')
            case "$mode" in
                0) echo "${MSG[airplane_off_state]}" ;;
                1) echo "${MSG[airplane_active_state]}" ;;
                4) echo "${MSG[airplane_on_state]}" ;;
                *) tf airplane_unknown_fmt "$mode" ;;
            esac ;;
        *) echo "${MSG[airplane_usage]}" ;;
    esac
}


cmd_qos() {
    [ ! -x "$SENDAT" ] && { echo "❌ sendat yok"; return; }
    local r=$(at_cmd "AT+CGEQOSRDP=1")
    echo "📊 QoS / Band Info"
    echo "$r"
    # parse: +CGEQOSRDP: cid,qci,maxUL,maxDL,guarUL,guarDL,...
    local qci=$(echo "$r" | sed -n 's/.*+CGEQOSRDP: *[0-9]*, *\([0-9]*\),.*/\1/p')
    [ -n "$qci" ] && echo "
QCI: $qci (Quality Class Indicator)"
}

cmd_sms_list() {
    # Read SMS from Android content provider (UFI-TOOLS approach)
    # Optional arg: count (default 10)
    local count="${1:-10}"
    case "$count" in
        ''|*[!0-9]*) count=10 ;;
    esac
    [ "$count" -gt 50 ] && count=50

    local raw=$(content query --uri content://sms/inbox \
        --projection _id:address:body:date \
        --sort 'date DESC' 2>/dev/null)

    if [ -z "$raw" ]; then
        echo "💬 SMS okunamadı (içerik sağlayıcı erişilemedi)"
        return
    fi

    echo "💬 Son $count SMS:"
    echo "$raw" | head -n "$count" | awk -F'address=|, body=|, date=' '
    {
        addr=$2; gsub(/,$/, "", addr)
        body=$3
        date_ms=$4 + 0
        date_s=int(date_ms / 1000)
        # Truncate body
        if (length(body) > 200) body = substr(body, 1, 197) "..."
        # Print (date formatted later by shell)
        printf "TS=%d|%s|%s\n", date_s, addr, body
    }' | while IFS='|' read -r tsline addr body; do
        ts=$(echo "$tsline" | cut -d= -f2)
        when=$(date -d "@$ts" '+%d.%m %H:%M' 2>/dev/null || echo "?")
        echo ""
        echo "📨 $when — $addr"
        echo "   $body"
    done
}

cmd_sms_count() {
    local raw=$(content query --uri content://sms/inbox --projection _id 2>/dev/null)
    local total=$(echo "$raw" | grep -c "Row:")
    echo "💬 Inbox: $total SMS
Listeyi gör: /sms_list  (varsayılan 10, /sms_list 20 gibi)"
}

cmd_cellinfo() {
    if [ ! -x "$SENDAT" ]; then
        echo "❌ UFI-TOOLS (sendat) bulunamadı. Cellular bilgi alınamaz."
        return
    fi
    echo "📡 Cellular Bilgileri"
    echo ""
    local op_raw=$(at_cmd "AT+COPS?")
    local creg=$(at_cmd "AT+CREG?")
    local imei=$(at_cmd "AT+CGSN")
    local iccid=$(at_cmd "AT+CCID")
    local cnum=$(at_cmd "AT+CNUM")

    # Operator
    local mccmnc=$(echo "$op_raw" | sed -n 's/.*"\([0-9]*\)".*/\1/p')
    local nettype=$(echo "$op_raw" | awk -F, '{print $NF}' | tr -d ' ')
    local nettype_label
    case "$nettype" in
        0) nettype_label="GSM" ;;
        2) nettype_label="UMTS" ;;
        7) nettype_label="LTE" ;;
        12|13) nettype_label="LTE-A" ;;
        14) nettype_label="5G NSA" ;;
        16) nettype_label="5G SA" ;;
        *) nettype_label="$nettype" ;;
    esac
    echo "Operatör: $(fmt_operator)"
    [ -n "$mccmnc" ] && echo "MCC/MNC: $mccmnc"
    [ -n "$nettype_label" ] && echo "Şebeke: $nettype_label"

    # Phone number
    local phone=$(echo "$cnum" | sed -n 's/.*"My Number","\([+0-9]*\)".*/\1/p')
    [ -z "$phone" ] && phone=$(echo "$cnum" | sed -n 's/.*"\([+0-9]*\)".*/\1/p')
    [ -n "$phone" ] && echo "Telefon: $phone"

    # IDs
    local imei_clean=$(echo "$imei" | sed 's/[^0-9]//g')
    [ -n "$imei_clean" ] && echo "IMEI: $imei_clean"
    local iccid_clean=$(echo "$iccid" | sed -n 's/.*"\([0-9A-Fa-f]*\)".*/\1/p')
    [ -n "$iccid_clean" ] && echo "ICCID: $iccid_clean"
}

cmd_ip() {
    echo "🌐 Public IP:"
    echo "  $(fmt_public_ip)"
    echo
    echo "🏠 Local arayüzler:"
    fmt_local_ips
}

cmd_modules() {
    echo "🧩 Magisk Modülleri:"
    for d in /data/adb/modules/*/; do
        [ -d "$d" ] || continue
        name=$(basename "$d")
        ver=$(awk -F= '/^version=/{print $2}' "$d/module.prop" 2>/dev/null)
        if [ -f "$d/disable" ]; then
            echo "  ❌ $name ($ver) [disabled]"
        else
            echo "  ✅ $name ($ver)"
        fi
    done
}

cmd_tunnel() {
    if pgrep -f /system/bin/cloudflared >/dev/null 2>&1; then
        pid=$(pgrep -f /system/bin/cloudflared | head -1)
        if [ -n "$pid" ] && [ -d "/proc/$pid" ]; then
            stime=$(stat -c %Y "/proc/$pid" 2>/dev/null)
            now=$(date +%s)
            up=$((now - stime))
            echo "✅ Cloudflared aktif (PID $pid, $((up/60))dk uptime)"
        else
            echo "✅ Cloudflared aktif"
        fi
        tail_line=$(tail -1 /data/cloudflared/cloudflared.log 2>/dev/null | head -c 200)
        [ -n "$tail_line" ] && echo "Son log: $tail_line"
    else
        echo "❌ Cloudflared kapalı"
    fi
}

cmd_clients() {
    echo "📶 ARP/Komşu Tablosu:"
    local count=0
    if [ -r /proc/net/arp ]; then
        while IFS= read -r line; do
            ip=$(echo "$line" | awk '{print $1}')
            mac=$(echo "$line" | awk '{print $4}')
            iface=$(echo "$line" | awk '{print $6}')
            [ "$ip" = "IP" ] && continue
            [ "$mac" = "00:00:00:00:00:00" ] && continue
            echo "  $ip @ $mac ($iface)"
            count=$((count+1))
        done < /proc/net/arp
    fi
    [ "$count" -eq 0 ] && echo "  (aktif kayıt yok)"
}

cmd_ping() {
    local host="$1"
    [ -z "$host" ] && { echo "Kullanım: /ping <host>"; return; }
    case "$host" in
        *[!a-zA-Z0-9.-]*) echo "❌ Geçersiz host"; return ;;
    esac
    echo "🏓 ping $host:"
    ping -c 3 -W 2 "$host" 2>&1 | tail -5
}

# Speedtest dispatcher: cloudflare (default), ookla (multi-stream), fast.com
OOKLA_BIN=/data/statusbot/bin/speedtest
OOKLA_URL="https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz"
FAST_API_TOKEN="YXNkZmFzZGxmbnNkYWZoYXNkZmhrYWxm"
SPEEDTEST_LOOP_PID="$DATADIR/speedtest_loop.pid"

# Spawn background loop. $1=cleaned args (provider+size), $2=count (0=infinite)
speedtest_start_loop() {
    local cleaned="$1"
    local count="$2"
    if [ -f "$SPEEDTEST_LOOP_PID" ]; then
        local oldpid
        oldpid=$(cat "$SPEEDTEST_LOOP_PID" 2>/dev/null)
        if [ -n "$oldpid" ] && kill -0 "$oldpid" 2>/dev/null; then
            echo "⚠ Zaten loop çalışıyor (PID $oldpid). Önce: /iptal"
            return
        fi
        rm -f "$SPEEDTEST_LOOP_PID"
    fi
    local label="${cleaned:-cf}"
    local count_label="∞"
    [ "$count" != "0" ] && count_label="$count"
    # Background subshell — write its stdio to a log file (not /dev/null) so
    # any unexpected error is debuggable. The log file IS a separate FD, so
    # the parent's $() pipe still closes normally for the dispatcher.
    local bg_log="$DATADIR/speedtest_loop.log"
    echo "[$(date)] loop start: cleaned=$cleaned count=$count" > "$bg_log"
    (
        i=1
        log "speedtest loop: starting subshell"
        while [ -f "$SPEEDTEST_LOOP_PID" ]; do
            if [ "$count" != "0" ] && [ "$i" -gt "$count" ]; then
                break
            fi
            res=$(SPEEDTEST_QUIET=1 cmd_speedtest "$cleaned")
            rc=$?
            [ -f "$SPEEDTEST_LOOP_PID" ] || break
            if [ -z "$res" ]; then
                tg_send "$OWNER" "⚠ Loop #$i: boş sonuç (rc=$rc), durduruluyor" >/dev/null
                rm -f "$SPEEDTEST_LOOP_PID"
                break
            fi
            tg_send "$OWNER" "🔁 Loop #$i ($label)
$res" >/dev/null
            log "speedtest loop: iter=$i provider=$label rc=$rc"
            i=$((i+1))
            [ -f "$SPEEDTEST_LOOP_PID" ] || break
            sleep 5
        done
        if [ -f "$SPEEDTEST_LOOP_PID" ]; then
            rm -f "$SPEEDTEST_LOOP_PID"
            tg_send "$OWNER" "✅ Speedtest loop bitti ($((i-1)) iter, $label)" >/dev/null
        fi
    ) </dev/null >>"$bg_log" 2>&1 &
    echo $! > "$SPEEDTEST_LOOP_PID"
    echo "🔁 Loop başlatıldı
provider: $label
adet: $count_label
İlk sonuç 15-30 sn içinde gelir.

Durdurmak: /iptal"
}

cmd_speedtest() {
    local arg arg2
    arg=$(echo "$1" | awk '{print $1}')
    arg2=$(echo "$1" | awk '{print $2}')

    # ─ Loop detection: scan all args for the keyword "loop"
    # Grammar: /speedtest [provider] [size] loop [count]
    # If "loop" found anywhere, run loop mode with everything before it as
    # the inner command, and the integer right after as count (default 0=∞).
    case " $1 " in
        *' loop '*|*' loop')
            local nf last_word second_last loop_count cleaned
            nf=$(echo "$1" | awk '{print NF}')
            last_word=$(echo "$1" | awk '{print $NF}')
            second_last=$(echo "$1" | awk 'NF>1 {print $(NF-1)}')
            if [ "$last_word" = "loop" ]; then
                # ... loop  (no count)
                loop_count=0
                cleaned=$(echo "$1" | awk 'NF>1 {for(i=1;i<NF;i++) printf "%s ", $i}' | sed 's/ $//')
            elif [ "$second_last" = "loop" ]; then
                # ... loop COUNT
                case "$last_word" in
                    *[!0-9]*) loop_count=0; cleaned="$1" ;;  # invalid count → treat as data
                    *)
                        loop_count="$last_word"
                        cleaned=$(echo "$1" | awk 'NF>2 {for(i=1;i<NF-1;i++) printf "%s ", $i}' | sed 's/ $//') ;;
                esac
            fi
            speedtest_start_loop "$cleaned" "$loop_count"
            return ;;
    esac

    case "$arg" in
        ookla|speedtest-cli)
            cmd_speedtest_ookla
            return ;;
        fast|fastcom|fast.com|netflix)
            cmd_speedtest_fast
            return ;;
        cf|cloudflare)
            arg="$arg2" ;;  # fall through to CF, arg2 = size/modifier
        help|?)
            echo "${MSG[st_usage]}"
            return ;;
    esac

    # Cloudflare provider (existing behavior)
    local size_mb=50
    local do_upload=0
    case "$arg" in
        ""|down|download) size_mb=50 ;;
        full|both|up) size_mb=50; do_upload=1 ;;
        quick) size_mb=10 ;;
        *[!0-9]*) echo "${MSG[st_usage]}"; return ;;
        *)
            size_mb="$arg"
            [ "$size_mb" -lt 5 ] && size_mb=5
            [ "$size_mb" -gt 200 ] && size_mb=200 ;;
    esac
    local bytes=$((size_mb * 1024 * 1024))

    if [ "$SPEEDTEST_QUIET" != "1" ]; then
        local up_suffix=""
        [ "$do_upload" = "1" ] && up_suffix="${MSG[st_cf_starting_upload]}"
        tg_send "$OWNER" "$(printf "${MSG[st_cf_starting_fmt]}" "$size_mb" "$up_suffix")" >/dev/null
    fi

    # Latency: time_connect = TCP handshake (RTT proxy, ICMP'siz)
    local connect_ms
    connect_ms=$("$CURL" -sSI --cacert "$CA" --max-time 5 \
        -o /dev/null -w "%{time_connect}" \
        "https://speed.cloudflare.com/__down?bytes=1024" 2>/dev/null)
    connect_ms=$(awk "BEGIN {printf \"%.0f\", $connect_ms * 1000}")

    # Download test
    local dl_result
    dl_result=$("$CURL" -sS --cacert "$CA" --max-time 60 \
        -o /dev/null \
        -w "%{size_download} %{speed_download} %{time_total}" \
        "https://speed.cloudflare.com/__down?bytes=$bytes" 2>/dev/null)
    set -- $dl_result
    local dl_size="$1" dl_bps="$2" dl_time="$3"
    [ -z "$dl_bps" ] && { echo "${MSG[st_cf_download_failed]}"; return; }
    local dl_mbps
    dl_mbps=$(awk "BEGIN {printf \"%.1f\", $dl_bps * 8 / 1000000}")

    local ul_section=""
    if [ "$do_upload" = "1" ]; then
        local ul_bytes=$((25 * 1024 * 1024))
        local ul_result
        ul_result=$(dd if=/dev/zero bs=1M count=25 2>/dev/null | \
            "$CURL" -sS --cacert "$CA" --max-time 60 \
            -o /dev/null \
            -w "%{size_upload} %{speed_upload} %{time_total}" \
            -X POST -H "Content-Type: application/octet-stream" \
            --data-binary @- \
            "https://speed.cloudflare.com/__up" 2>/dev/null)
        if [ -n "$ul_result" ]; then
            set -- $ul_result
            local ul_size="$1" ul_bps="$2" ul_time="$3"
            local ul_mbps
            ul_mbps=$(awk "BEGIN {printf \"%.1f\", $ul_bps * 8 / 1000000}")
            ul_section=$(printf "${MSG[st_cf_upload_fmt]}" "$ul_mbps" "$(awk "BEGIN {printf \"%.1f\", $ul_size/1048576}")" "$ul_time")
        else
            ul_section="${MSG[st_cf_upload_failed]}"
        fi
    fi

    # CPU governor + active cluster note (helps debug why slow)
    local clusters=""
    local p
    for p in /sys/devices/system/cpu/cpufreq/policy*; do
        local aff
        aff=$(cat "$p/affected_cpus" 2>/dev/null)
        [ -n "$aff" ] && clusters="$clusters$(basename "$p")=online "
        [ -z "$aff" ] && clusters="${clusters}$(basename "$p")=OFFLINE "
    done

    printf "${MSG[st_cf_result_fmt]}\n" \
        "$dl_mbps" \
        "$(awk "BEGIN {printf \"%.1f\", $dl_size/1048576}")" \
        "$dl_time" \
        "$ul_section" \
        "$connect_ms" \
        "$clusters" \
        "$(fmt_temp)"
}

cmd_speedtest_ookla() {
    if [ ! -x "$OOKLA_BIN" ]; then
        tg_send "$OWNER" "${MSG[st_ookla_downloading]}" >/dev/null
        mkdir -p "$(dirname "$OOKLA_BIN")"
        local tgz=/data/statusbot/.ookla.tgz
        if ! "$CURL" -sSL --cacert "$CA" --max-time 60 -o "$tgz" "$OOKLA_URL"; then
            echo "${MSG[st_ookla_download_failed]}"
            return
        fi
        if ! tar -xzf "$tgz" -C "$(dirname "$OOKLA_BIN")" speedtest 2>/dev/null; then
            echo "${MSG[st_ookla_extract_failed]}"
            rm -f "$tgz"
            return
        fi
        chmod 755 "$OOKLA_BIN"
        rm -f "$tgz"
    fi
    [ "$SPEEDTEST_QUIET" != "1" ] && tg_send "$OWNER" "${MSG[st_ookla_starting]}" >/dev/null
    # HOME = writable dir for license cache, --ca-certificate = bundled CA bundle
    local ookla_home=/data/statusbot/bin/ookla_home
    mkdir -p "$ookla_home"
    local out
    out=$(HOME="$ookla_home" "$OOKLA_BIN" \
        --accept-license --accept-gdpr \
        --ca-certificate="$CA" \
        --format=json --progress=no 2>&1)
    # Find the result line (CLI emits multiple log lines, last is .type=result)
    local result_line
    result_line=$(echo "$out" | grep -F '"type":"result"' | tail -1)
    if [ -z "$result_line" ]; then
        tf st_ookla_failed_fmt "$(echo "$out" | head -c 400)"
        return
    fi
    local ping_ms dl_bps ul_bps server_name server_loc isp iface ext_ip is_vpn jitter
    ping_ms=$(echo "$result_line"   | "$JQ" -r '.ping.latency // empty')
    jitter=$(echo "$result_line"    | "$JQ" -r '.ping.jitter // empty')
    dl_bps=$(echo "$result_line"    | "$JQ" -r '.download.bandwidth // empty')
    ul_bps=$(echo "$result_line"    | "$JQ" -r '.upload.bandwidth // empty')
    server_name=$(echo "$result_line" | "$JQ" -r '.server.name // empty')
    server_loc=$(echo "$result_line"  | "$JQ" -r '.server.location // empty')
    isp=$(echo "$result_line"        | "$JQ" -r '.isp // empty')
    iface=$(echo "$result_line"      | "$JQ" -r '.interface.name // empty')
    ext_ip=$(echo "$result_line"     | "$JQ" -r '.interface.externalIp // empty')
    is_vpn=$(echo "$result_line"     | "$JQ" -r '.interface.isVpn // empty')
    local dl_mbps ul_mbps ping_fmt jitter_fmt
    dl_mbps=$(awk "BEGIN {printf \"%.1f\", $dl_bps * 8 / 1000000}")
    ul_mbps=$(awk "BEGIN {printf \"%.1f\", $ul_bps * 8 / 1000000}")
    ping_fmt=$(awk "BEGIN {printf \"%.1f\", $ping_ms}")
    jitter_fmt=$(awk "BEGIN {printf \"%.1f\", $jitter}")
    local vpn_tag=""
    [ "$is_vpn" = "true" ] && vpn_tag=" 🛡 VPN"
    printf "${MSG[st_ookla_result_fmt]}\n" \
        "$dl_mbps" "$ul_mbps" "$ping_fmt" "$jitter_fmt" \
        "$server_name" "$server_loc" "$isp" \
        "$iface" "$ext_ip" "$vpn_tag" \
        "$(fmt_temp)"
}

cmd_speedtest_fast() {
    [ "$SPEEDTEST_QUIET" != "1" ] && tg_send "$OWNER" "${MSG[st_fast_starting]}" >/dev/null
    local api_resp
    api_resp=$("$CURL" -sS --cacert "$CA" --max-time 10 \
        "https://api.fast.com/netflix/speedtest/v2?https=true&token=$FAST_API_TOKEN&urlCount=3" 2>/dev/null)
    local urls_file=/data/statusbot/.fast_urls
    echo "$api_resp" | "$JQ" -r '.targets[].url // empty' > "$urls_file" 2>/dev/null
    if [ ! -s "$urls_file" ]; then
        tf st_fast_api_failed_fmt "$(echo "$api_resp" | head -c 300)"
        rm -f "$urls_file"
        return
    fi
    local total_bytes=0 total_time=0 count=0 server="?"
    local url
    while IFS= read -r url; do
        [ -z "$url" ] && continue
        if [ "$count" = 0 ]; then
            server=$(echo "$url" | sed 's|https://||; s|/.*||' | head -c 60)
        fi
        local r
        r=$("$CURL" -sS --cacert "$CA" --max-time 15 -o /dev/null \
            -w "%{size_download} %{time_total}" "$url" 2>/dev/null)
        [ -z "$r" ] && continue
        set -- $r
        local size="$1" tm="$2"
        total_bytes=$((total_bytes + size))
        total_time=$(awk "BEGIN {printf \"%.3f\", $total_time + $tm}")
        count=$((count + 1))
    done < "$urls_file"
    rm -f "$urls_file"
    if [ "$count" = 0 ] || [ "$total_bytes" = 0 ]; then
        echo "${MSG[st_fast_download_failed]}"
        return
    fi
    local mbps
    mbps=$(awk "BEGIN {printf \"%.1f\", $total_bytes * 8 / $total_time / 1000000}")
    printf "${MSG[st_fast_result_fmt]}\n" \
        "$mbps" \
        "$(awk "BEGIN {printf \"%.1f\", $total_bytes/1048576}")" \
        "$total_time" \
        "$count" \
        "$server" \
        "$(fmt_temp)"
}

cmd_ps() {
    echo "🔝 Top 10 process (CPU%):"
    top -b -n 1 2>/dev/null | awk '
        /^  *PID/ { print; header=1; next }
        header && NF > 7 {
            count++
            if (count <= 10) print
        }
    ' | awk '{
        # Reformat: PID, %CPU, %MEM, COMMAND (truncated)
        if (NR==1) {
            printf "%-7s %-5s %-5s %s\n", "PID", "CPU%", "MEM%", "CMD"
        } else {
            cmd=$NF
            for (i=NF-1; i>=12; i--) cmd=$i" "cmd
            if (length(cmd) > 40) cmd = substr(cmd, 1, 37) "..."
            # Columns: PID(1) USER(2) PR(3) NI(4) VIRT(5) RES(6) SHR(7) S(8) %CPU(9) %MEM(10) TIME+(11) ARGS(12+)
            printf "%-7s %-5s %-5s %s\n", $1, $9, $10, cmd
        }
    }'
}

cmd_reboot() {
    local arg="$1"
    local now=$(date +%s)
    if [ "$arg" = "YES" ]; then
        if [ -f "$PENDING_REBOOT" ]; then
            pending_ts=$(cat "$PENDING_REBOOT")
            if [ $((now - pending_ts)) -lt 60 ]; then
                rm -f "$PENDING_REBOOT"
                echo "${MSG[reboot_starting]}"
                ( sleep 2; /system/bin/reboot ) &
                return
            fi
        fi
        echo "${MSG[reboot_expired]}"
    else
        echo "$now" > "$PENDING_REBOOT"
        echo "${MSG[reboot_confirm]}"
    fi
}

cmd_version() {
    printf "${MSG[version_fmt]}\n" \
        "$BOT_VERSION" \
        "$(getprop ro.product.model)" \
        "$(getprop ro.build.display.id)" \
        "$(getprop ro.build.version.release)" \
        "$(getprop ro.build.version.sdk)" \
        "$(uname -r | cut -d- -f1)"
}

cmd_komut() {
    # Run arbitrary command in background, send cancel button, edit message on completion
    local chat_id="$1"
    local user_msg_id="$2"
    local cmd="$3"

    if [ -z "$cmd" ]; then
        tg_send "$chat_id" "Kullanım: /komut <shell komutu>
Örnek: /komut ls /data
Maks $((KOMUT_TIMEOUT))sn çalışır, üzeri otomatik iptal." "$user_msg_id" >/dev/null
        return
    fi

    # Send placeholder with cancel button. Task ID = user_msg_id (unique per command).
    local task_id="$user_msg_id"
    local outfile="$TASK_DIR/${task_id}.out"
    local pidfile="$TASK_DIR/${task_id}.pid"
    local cmdfile="$TASK_DIR/${task_id}.cmd"
    local metafile="$TASK_DIR/${task_id}.meta"

    : > "$outfile"
    echo "$cmd" > "$cmdfile"

    local resp=$(tg_send_with_cancel "$chat_id" "🔄 Çalışıyor:
\$ $cmd" "$task_id")
    local bot_msg_id=$(echo "$resp" | "$JQ" -r '.result.message_id // empty')

    if [ -z "$bot_msg_id" ]; then
        log "komut: failed to send placeholder"
        return
    fi

    # Save metadata for poller + cancel handler
    echo "chat_id=$chat_id"   >  "$metafile"
    echo "bot_msg_id=$bot_msg_id" >> "$metafile"
    echo "started=$(date +%s)" >> "$metafile"

    # Spawn the command as a child of a subshell so we can kill the group
    (
        sh -c "$cmd" > "$outfile" 2>&1
        touch "$TASK_DIR/${task_id}.done"
    ) &
    echo $! > "$pidfile"
    log "komut started: task=$task_id pid=$(cat $pidfile) cmd=$cmd"
}

# ─── auto: SMS forward + alerts ───────────────────────────────────────────
# State files track what we've already seen / alerted to avoid spam.
SMS_LAST_ID_FILE="$DATADIR/.sms_last_id"
ALERT_STATE_FILE="$DATADIR/.alert_state"

# Thresholds (tweak as needed)
ALERT_TEMP_C=65       # CPU °C above which we alert
ALERT_MEM_PCT=10      # MemAvailable % below which we alert
ALERT_REARM_SEC=900   # Don't re-alert same condition within 15 min

poll_sms_forward() {
    # Forward new SMS to owner. First run baselines (no flood).
    [ "$OWNER" ] || return
    local raw last_id new_last
    raw=$(content query --uri content://sms/inbox \
        --projection _id:address:body:date --sort 'date DESC' 2>/dev/null | head -20)
    [ -z "$raw" ] && return
    new_last=$(echo "$raw" | head -1 | sed -n 's/.*_id=\([0-9]*\).*/\1/p')
    [ -z "$new_last" ] && return
    last_id=$(cat "$SMS_LAST_ID_FILE" 2>/dev/null)
    if [ -z "$last_id" ]; then
        # First run — baseline, don't flood with history
        echo "$new_last" > "$SMS_LAST_ID_FILE"
        return
    fi
    [ "$new_last" = "$last_id" ] && return
    # Walk lines from oldest-of-new to newest, forward each
    echo "$raw" | awk -F'_id=|, address=|, body=|, date=' -v base="$last_id" '
    {
        id = $2 + 0
        gsub(/,$/, "", $2)
        if (id > base) {
            addr = $3; sub(/,$/, "", addr)
            body = $4
            ts_ms = $5 + 0
            ts_s = int(ts_ms / 1000)
            printf "%d|%d|%s|%s\n", id, ts_s, addr, body
        }
    }' | sort -t'|' -k1n | while IFS='|' read -r id ts addr body; do
        local when
        when=$(date -d "@$ts" '+%d.%m %H:%M' 2>/dev/null || echo "?")
        # Truncate very long
        [ ${#body} -gt 800 ] && body="${body:0:800}…"
        tg_send "$OWNER" "📨 Gelen SMS — $when
👤 $addr

$body" >/dev/null
        log "sms forwarded: id=$id from $addr"
    done
    echo "$new_last" > "$SMS_LAST_ID_FILE"
}

alert_fired_recently() {
    # $1 = alert key. Returns 0 if fired within ALERT_REARM_SEC.
    local key="$1"
    local now=$(date +%s)
    local last
    last=$(awk -F= -v k="$key" '$1==k {print $2}' "$ALERT_STATE_FILE" 2>/dev/null)
    [ -z "$last" ] && return 1
    [ $((now - last)) -lt "$ALERT_REARM_SEC" ]
}

alert_mark() {
    local key="$1"
    local now=$(date +%s)
    local tmp="${ALERT_STATE_FILE}.tmp"
    : > "$tmp"
    if [ -f "$ALERT_STATE_FILE" ]; then
        awk -F= -v k="$key" '$1!=k {print}' "$ALERT_STATE_FILE" >> "$tmp"
    fi
    echo "$key=$now" >> "$tmp"
    mv "$tmp" "$ALERT_STATE_FILE"
}

poll_auto_alerts() {
    [ "$OWNER" ] || return
    # Quiet hours suppress automatic alerts (incoming commands always reply)
    is_quiet_hours && return

    # Temperature
    local temp_raw temp_c
    for z in /sys/class/thermal/thermal_zone*/; do
        [ "$(cat "$z/type" 2>/dev/null)" = "apcpu0-thmzone" ] && temp_raw=$(cat "$z/temp" 2>/dev/null) && break
    done
    if [ -n "$temp_raw" ]; then
        temp_c=$((temp_raw / 1000))
        if [ "$temp_c" -ge "$ALERT_TEMP_C" ]; then
            if ! alert_fired_recently "temp_high"; then
                tg_send "$OWNER" "$(printf "${MSG[alert_temp_fmt]}" "$temp_c" "$ALERT_TEMP_C" "$ALERT_REARM_SEC")" >/dev/null
                alert_mark "temp_high"
                log "ALERT: temp=${temp_c}C"
            fi
        fi
    fi

    # Memory available %
    local mem_avail_pct
    mem_avail_pct=$(awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END {if (t>0) printf "%d", a*100/t}' /proc/meminfo)
    if [ -n "$mem_avail_pct" ] && [ "$mem_avail_pct" -lt "$ALERT_MEM_PCT" ]; then
        if ! alert_fired_recently "mem_low"; then
            local mem_mb
            mem_mb=$(awk '/^MemAvailable:/{printf "%.0f", $2/1024}' /proc/meminfo)
            tg_send "$OWNER" "$(printf "${MSG[alert_mem_fmt]}" "$mem_avail_pct" "$mem_mb")" >/dev/null
            alert_mark "mem_low"
            log "ALERT: mem_avail=${mem_avail_pct}%"
        fi
    fi

    # Cloudflared tunnel down
    if ! pgrep -f /system/bin/cloudflared >/dev/null 2>&1; then
        if ! alert_fired_recently "tunnel_down"; then
            tg_send "$OWNER" "${MSG[alert_tunnel]}" >/dev/null
            alert_mark "tunnel_down"
            log "ALERT: tunnel_down"
        fi
    fi
}

# ─── task poller (runs every loop iteration) ──────────────────────────────
poll_tasks() {
    local now=$(date +%s)
    for done_file in "$TASK_DIR"/*.done; do
        [ -e "$done_file" ] || continue
        local task_id=$(basename "$done_file" .done)
        local metafile="$TASK_DIR/${task_id}.meta"
        [ -f "$metafile" ] || { rm -f "$done_file"; continue; }
        # Read meta
        . "$metafile" 2>/dev/null
        local out=$(head -c "$KOMUT_MAX_OUTPUT" "$TASK_DIR/${task_id}.out" 2>/dev/null)
        local cmd=$(cat "$TASK_DIR/${task_id}.cmd" 2>/dev/null)
        local size=$(stat -c %s "$TASK_DIR/${task_id}.out" 2>/dev/null || echo 0)
        local truncated=""
        [ "$size" -gt "$KOMUT_MAX_OUTPUT" ] && truncated=$(printf "${MSG[komut_truncated_fmt]}" "$size")
        tg_edit "$chat_id" "$bot_msg_id" "$(printf "${MSG[komut_done_fmt]}" "$cmd" "$out" "$truncated")"
        rm -f "$TASK_DIR/${task_id}.out" "$TASK_DIR/${task_id}.pid" "$TASK_DIR/${task_id}.cmd" "$TASK_DIR/${task_id}.meta" "$TASK_DIR/${task_id}.done"
        log "komut done: task=$task_id"
    done

    # Timeout enforcement
    for metafile in "$TASK_DIR"/*.meta; do
        [ -e "$metafile" ] || continue
        local task_id=$(basename "$metafile" .meta)
        [ -f "$TASK_DIR/${task_id}.done" ] && continue  # already done
        . "$metafile" 2>/dev/null
        if [ -n "$started" ] && [ "$((now - started))" -gt "$KOMUT_TIMEOUT" ]; then
            local pid=$(cat "$TASK_DIR/${task_id}.pid" 2>/dev/null)
            if [ -n "$pid" ]; then
                pkill -TERM -P "$pid" 2>/dev/null
                kill -TERM "$pid" 2>/dev/null
                sleep 1
                pkill -KILL -P "$pid" 2>/dev/null
                kill -KILL "$pid" 2>/dev/null
            fi
            local out=$(head -c "$KOMUT_MAX_OUTPUT" "$TASK_DIR/${task_id}.out" 2>/dev/null)
            local cmd=$(cat "$TASK_DIR/${task_id}.cmd" 2>/dev/null)
            tg_edit "$chat_id" "$bot_msg_id" "⏱ Timeout (${KOMUT_TIMEOUT}sn): \$ $cmd

$out"
            rm -f "$TASK_DIR/${task_id}.out" "$TASK_DIR/${task_id}.pid" "$TASK_DIR/${task_id}.cmd" "$TASK_DIR/${task_id}.meta" "$TASK_DIR/${task_id}.done"
            log "komut timeout: task=$task_id"
        fi
    done
}

# ─── callback (button press) handler ──────────────────────────────────────
handle_callback() {
    local cb_id="$1"
    local from_chat="$2"
    local message_id="$3"
    local data="$4"

    # Owner check
    if [ "$from_chat" != "$OWNER" ]; then
        tg_answer_callback "$cb_id" "${MSG[cb_unauthorized]}"
        return
    fi

    case "$data" in
        reboot_now)
            tg_answer_callback "$cb_id" "${MSG[cb_reboot_in_progress]}"
            tg_edit "$from_chat" "$message_id" "${MSG[cb_reboot_msg]}"
            log "reboot_now triggered via inline button"
            ( sleep 2; /system/bin/reboot ) &
            return
            ;;
        cancel:*)
            local task_id="${data#cancel:}"
            local metafile="$TASK_DIR/${task_id}.meta"
            local donefile="$TASK_DIR/${task_id}.done"
            if [ -f "$donefile" ] || [ ! -f "$metafile" ]; then
                tg_answer_callback "$cb_id" "${MSG[cb_task_done]}"
                return
            fi
            tg_answer_callback "$cb_id" "${MSG[cb_cancelling]}"
            . "$metafile" 2>/dev/null
            local pid=$(cat "$TASK_DIR/${task_id}.pid" 2>/dev/null)
            if [ -n "$pid" ]; then
                pkill -TERM -P "$pid" 2>/dev/null
                kill -TERM "$pid" 2>/dev/null
                sleep 1
                pkill -KILL -P "$pid" 2>/dev/null
                kill -KILL "$pid" 2>/dev/null
            fi
            local out=$(head -c "$KOMUT_MAX_OUTPUT" "$TASK_DIR/${task_id}.out" 2>/dev/null)
            local cmd=$(cat "$TASK_DIR/${task_id}.cmd" 2>/dev/null)
            tg_edit "$from_chat" "$message_id" "$(printf "${MSG[cb_cancel_msg_fmt]}" "$cmd" "${out:-${MSG[cb_no_output]}}")"
            rm -f "$TASK_DIR/${task_id}.out" "$TASK_DIR/${task_id}.pid" "$TASK_DIR/${task_id}.cmd" "$TASK_DIR/${task_id}.meta" "$TASK_DIR/${task_id}.done"
            log "komut cancelled: task=$task_id"
            ;;
        *)
            tg_answer_callback "$cb_id" "${MSG[cb_unknown]}"
            ;;
    esac
}

# ─── message dispatcher ───────────────────────────────────────────────────
dispatch() {
    local chat_id="$1"
    local msg_id="$2"
    local text="$3"

    [ "$chat_id" != "$OWNER" ] && return

    # Intercept pending IMEI captcha response (before normal commands)
    local pending="$DATADIR/pending_imei_sorgu"
    if [ -f "$pending" ]; then
        local now=$(date +%s)
        local created
        created=$(awk -F= '/^created=/{print $2}' "$pending")
        if [ -n "$created" ] && [ $((now - created)) -lt 120 ]; then
            case "$text" in
                /iptal|/cancel)
                    rm -f "$pending" "$DATADIR/.edevlet_cookies" "$DATADIR/.captcha.png"
                    tg_send "$chat_id" "${MSG[imei_cancel_done]}" "$msg_id" >/dev/null
                    return ;;
                /*) ;;  # Other commands take precedence
                *)
                    # If looks like a captcha (4-8 alphanumeric, no spaces), treat as such
                    local trimmed=$(echo "$text" | tr -d ' \r\n')
                    # Toybox grep doesn't support {N,M}, use shell length + simple regex
                    local len=${#trimmed}
                    if [ "$len" -ge 4 ] && [ "$len" -le 8 ] && echo "$trimmed" | grep -qE '^[A-Za-z0-9]+$'; then
                        log "captcha response: $trimmed"
                        handle_captcha_response "$chat_id" "$msg_id" "$trimmed"
                        return
                    fi
                    ;;
            esac
        else
            # Expired
            rm -f "$pending" "$DATADIR/.edevlet_cookies" "$DATADIR/.captcha.png"
        fi
    fi

    local cmd=$(echo "$text" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
    cmd="${cmd%%@*}"
    local args=$(echo "$text" | awk '{$1=""; sub(/^ /,""); print}')

    local reply=""
    case "$cmd" in
        /start|/help|help|/menu|menu)  reply=$(cmd_help) ;;
        /status|/durum)                reply=$(cmd_status) ;;
        /ip|/ipler)                    reply=$(cmd_ip) ;;
        /uptime|/calismasuresi)        reply="⏱ $(fmt_uptime)" ;;
        /load|/yuk)                    reply=$(fmt_load) ;;
        /mem|/ram|/memory)             reply="💾 $(fmt_mem)" ;;
        /disk|/depo)                   reply="💿 $(fmt_disk)" ;;
        /temp|/sicaklik|/isi)          reply="🌡 $(fmt_temp)" ;;
        /signal|/sinyal)               reply=$(fmt_signal) ;;
        /cellinfo|/hucresel|/sim)      reply=$(cmd_cellinfo) ;;
        /imei)                         reply=$(cmd_imei) ;;
        /imei_sorgula|/imeisorgula|/imeicheck)
            cmd_imei_sorgula "$chat_id" "$(echo "$args" | awk '{print $1}')"
            return ;;
        /iptal|/cancel)
            reply=$(cmd_iptal) ;;
        /imei_degis|/imeidegis|/imeichange)
            reply=$(cmd_imei_degis "$(echo "$args" | awk '{print $1}')" "$(echo "$args" | awk '{print $2}')") ;;
        /qos|/band)                    reply=$(cmd_qos) ;;
        /sms_list|/smslist|/smsler)    reply=$(cmd_sms_list "$args") ;;
        /sms_count|/smscount|/smssayi) reply=$(cmd_sms_count) ;;
        /sms_send|/smssend|/smsyolla)  cmd_sms_send "$chat_id" "$args"; return ;;
        /wifi|/hotspot)                reply=$(cmd_wifi) ;;
        /file|/dosya)                  cmd_file "$chat_id" "$(echo "$args" | awk '{print $1}')"; return ;;
        /screenshot|/ekran|/ss)        cmd_screenshot "$chat_id"; return ;;
        /ramclean|/ramtemizle|/clean)  reply=$(cmd_ramclean "$args") ;;
        /at)                           reply=$(cmd_at "$args") ;;
        /traffic|/veri|/data)          reply=$(fmt_traffic) ;;
        /operator|/operatör)           reply="📡 $(fmt_operator)" ;;
        /modules|/moduller)            reply=$(cmd_modules) ;;
        /perf_balanced|/balanced|/perfbalanced)
            reply=$(cmd_perf_balanced "$args") ;;
        /minimal_mode|/minimal|/lite)
            reply=$(cmd_minimal_mode "$args") ;;
        /perf_help|/perfhelp|/cpuhelp)
            reply=$(cmd_perf_help) ;;
        /performance|/perf|/performans)
            reply=$(cmd_performance "$(echo "$args" | awk '{print $1}')")
            # Special: if reply starts with REBOOT_PROMPT|, send with reboot button instead
            case "$reply" in
                REBOOT_PROMPT\|*)
                    local text="${reply#REBOOT_PROMPT|}"
                    tg_send_with_reboot "$chat_id" "$text"
                    return
                    ;;
            esac
            ;;
        /zte_setpw|/ztepw|/ztesetpw)   reply=$(cmd_zte_setpw "$args") ;;
        /tunnel|/cf)                   reply=$(cmd_tunnel) ;;
        /clients|/bagli)               reply=$(cmd_clients) ;;
        /ping)                         reply=$(cmd_ping "$args") ;;
        /speedtest|/speed|/hiz|/hiztesti)
            reply=$(cmd_speedtest "$args") ;;
        /ps|/processes)                reply=$(cmd_ps) ;;
        /reboot|/yenidenbaslat)        reply=$(cmd_reboot "$args") ;;
        /version|/v)                   reply=$(cmd_version) ;;
        /komut|/run|/exec|/sh)
            cmd_komut "$chat_id" "$msg_id" "$args"
            return  # cmd_komut handles its own messaging
            ;;
        # ─── filesystem ────────────────────────────────────────────────
        /ls)                           reply=$(cmd_ls "$args") ;;
        /cat)                          reply=$(cmd_cat "$args") ;;
        /df)                           reply=$(cmd_df) ;;
        /du)                           reply=$(cmd_du "$args") ;;
        /log|/botlog)                  reply=$(cmd_log "$args") ;;
        /dump_sms|/dumpsms)            cmd_dump_sms "$chat_id"; return ;;
        # ─── network extras ────────────────────────────────────────────
        /connections|/conn)            reply=$(cmd_connections) ;;
        /listening|/listen|/ports)     reply=$(cmd_listening) ;;
        /dhcp|/leases)                 reply=$(cmd_dhcp) ;;
        /dns)                          reply=$(cmd_dns) ;;
        # ─── power / kernel ────────────────────────────────────────────
        /cpu_freq|/cpufreq|/freq)      reply=$(cmd_cpu_freq) ;;
        /cpu_governor|/governor|/gov)  reply=$(cmd_cpu_governor "$args") ;;
        /wakelock|/wakelocks)          reply=$(cmd_wakelock) ;;
        # ─── apps ──────────────────────────────────────────────────────
        /freeze|/donduran)             reply=$(cmd_freeze "$(echo "$args" | awk '{print $1}')") ;;
        /unfreeze|/aktifet)            reply=$(cmd_unfreeze "$(echo "$args" | awk '{print $1}')") ;;
        /installed|/packages|/paketler) reply=$(cmd_installed "$(echo "$args" | awk '{print $1}')") ;;
        # ─── security / audit ──────────────────────────────────────────
        /who|/sessions|/oturumlar)     reply=$(cmd_who) ;;
        /last_boot|/lastboot|/bootlog) reply=$(cmd_last_boot) ;;
        # ─── bot self ──────────────────────────────────────────────────
        /bot_stats|/botstats|/stats)   reply=$(cmd_bot_stats) ;;
        /restart_bot|/restartbot)
            cmd_restart_bot
            tg_send "$chat_id" "🔄 Bot 2 sn içinde restart, supervisor tekrar başlatır." "$msg_id" >/dev/null
            return ;;
        # ─── schedule / heartbeat / quiet ──────────────────────────────
        /quiet_hours|/quiet|/sessiz)   reply=$(cmd_quiet_hours "$args") ;;
        /heartbeat|/hb)                reply=$(cmd_heartbeat "$args") ;;
        /alarm)                        reply=$(cmd_alarm "$args") ;;
        /schedule|/cron|/zamanla)      reply=$(cmd_schedule "$args") ;;
        # ─── upload ────────────────────────────────────────────────────
        /upload|/yukle)                cmd_upload "$chat_id" "$(echo "$args" | awk '{print $1}')"; return ;;
        # ─── tailscale ─────────────────────────────────────────────────
        /tailscale|/ts)                reply=$(cmd_tailscale "$args") ;;
        /update|/güncelle|/guncelle)   reply=$(cmd_update "$args") ;;
        /lang|/dil|/language)          reply=$(cmd_lang "$args") ;;
        *)
            local lc=$(echo "$text" | tr '[:upper:]' '[:lower:]' | tr -d ' .,!?')
            case "$lc" in
                selam|selammm*|merhaba|sa|selamünaleyküm|selamunaleykum|sb|hi|hello)
                    reply=$(printf "${MSG[chat_greeting_fmt]}" "$(greeting)") ;;
                naber|nbr|nasilsin|nasıl|nasılsın|nasilbakalim)
                    reply=$(printf "${MSG[chat_naber_fmt]}" "$(greeting)" "$(cmd_status)") ;;
                saat|saatkac|saatkaç)
                    reply=$(printf "${MSG[chat_time_fmt]}" "$(date '+%H:%M:%S — %d %B %Y')") ;;
                iyimisin|iyimi|naptın|naptin|nicesin)
                    reply=$(printf "${MSG[chat_imisin_fmt]}" "$(fmt_temp)" "$(fmt_uptime)") ;;
                teşekkür*|tesekkur*|tşk|tsk|sağol*|sagol*|saol*|thanks|thx)
                    reply="${MSG[chat_thanks]}" ;;
                günaydın*|gunaydin*|hayırlısabahlar*)
                    reply=$(printf "${MSG[chat_morning_fmt]}" "$(fmt_uptime)") ;;
                iyigeceler|iyiakşamlar|iyiaksamlar|hayırlıgeceler)
                    reply="${MSG[chat_night]}" ;;
                *) return ;;
            esac
            ;;
    esac

    [ -n "$reply" ] && tg_send "$chat_id" "$reply" "$msg_id" >/dev/null
}

# ─── main ─────────────────────────────────────────────────────────────────
TOKEN=$(cat "$TOKEN_FILE" 2>/dev/null)
OWNER=$(cat "$CHAT_FILE" 2>/dev/null)

if [ -z "$TOKEN" ] || [ -z "$OWNER" ]; then
    log "Missing TOKEN or CHAT_ID, exiting"
    exit 1
fi

log "Bot $BOT_VERSION starting"

# Register bot commands with Telegram (once per version - cached marker)
register_commands() {
    # Marker scoped by version AND language — switching lang triggers re-register
    local marker="$DATADIR/.cmds_registered_${BOT_VERSION}_${USER_LANG}"
    [ -f "$marker" ] && return 0
    local body
    body='{"commands":[
        {"command":"start","description":"Yardım ve komut listesi"},
        {"command":"help","description":"Tüm komutları göster"},
        {"command":"status","description":"Cihaz durumu özeti"},
        {"command":"uptime","description":"Çalışma süresi"},
        {"command":"load","description":"CPU yükü"},
        {"command":"mem","description":"RAM kullanımı"},
        {"command":"disk","description":"Disk kullanımı"},
        {"command":"temp","description":"CPU sıcaklığı"},
        {"command":"ps","description":"Top 10 process (CPU)"},
        {"command":"ip","description":"Public + local IP adresleri"},
        {"command":"traffic","description":"Trafik (RX/TX) boot sonrası"},
        {"command":"ping","description":"Ping testi - /ping <host>"},
        {"command":"clients","description":"Bağlı cihazlar (ARP)"},
        {"command":"tunnel","description":"Cloudflared tunnel durumu"},
        {"command":"operator","description":"Cellular operatör"},
        {"command":"signal","description":"Sinyal kalitesi"},
        {"command":"cellinfo","description":"Operatör + IMEI + ICCID + telefon"},
        {"command":"imei","description":"IMEI(ler) - her slot için"},
        {"command":"imei_sorgula","description":"e-Devlet IMEI sorgu (captcha sorar)"},
        {"command":"imei_degis","description":"IMEI değiştir - onaylı reboot"},
        {"command":"qos","description":"QoS / Band detayları"},
        {"command":"sms_list","description":"SIM SMS listesi"},
        {"command":"sms_count","description":"SMS sayısı"},
        {"command":"sms_send","description":"SMS gönder - /sms_send <num> <text>"},
        {"command":"wifi","description":"Hotspot SSID/şifre/bağlı cihazlar"},
        {"command":"file","description":"Dosya çek - /file <path>"},
        {"command":"screenshot","description":"Ekran görüntüsü"},
        {"command":"ramclean","description":"RAM temizle (VPN/sistem korunur)"},
        {"command":"at","description":"Tekil AT komutu - /at <cmd>"},
        {"command":"modules","description":"Magisk modülleri"},
        {"command":"performance","description":"ZTE Performance Mode - on/off"},
        {"command":"zte_setpw","description":"ZTE admin şifresini ayarla"},
        {"command":"komut","description":"Shell komutu (iptal düğmeli)"},
        {"command":"reboot","description":"Cihazı yeniden başlat (onaylı)"},
        {"command":"version","description":"Bot ve cihaz versiyonu"},
        {"command":"iptal","description":"Bekleyen IMEI/upload iptal"},
        {"command":"ls","description":"Dizin listesi"},
        {"command":"cat","description":"Dosya içeriği (4 KB)"},
        {"command":"df","description":"Disk doluluk"},
        {"command":"du","description":"Alt dizin boyutları"},
        {"command":"log","description":"Bot log son N satır"},
        {"command":"dump_sms","description":"Tüm inbox SMS dump (dosya)"},
        {"command":"upload","description":"Cihaza dosya yükle - /upload <hedef>"},
        {"command":"connections","description":"Aktif TCP bağlantıları"},
        {"command":"listening","description":"Dinleyen portlar"},
        {"command":"dhcp","description":"DHCP lease tablosu"},
        {"command":"dns","description":"DNS yapılandırması"},
        {"command":"cpu_freq","description":"CPU frekansları"},
        {"command":"cpu_governor","description":"Governor göster/değiştir"},
        {"command":"wakelock","description":"Aktif wakelocklar"},
        {"command":"freeze","description":"Paketi dondur"},
        {"command":"unfreeze","description":"Paketi aktive et"},
        {"command":"installed","description":"Kurulu paketler [3rd|disabled|system|all]"},
        {"command":"who","description":"Aktif SSH/ADB oturumları"},
        {"command":"last_boot","description":"Boot geçmişi"},
        {"command":"bot_stats","description":"Bot iç istatistikler"},
        {"command":"restart_bot","description":"Botu yeniden başlat"},
        {"command":"quiet_hours","description":"Sessiz saatler - alarmları sustur"},
        {"command":"heartbeat","description":"Periyodik canlı sinyali"},
        {"command":"alarm","description":"Tek seferlik alarm - /alarm HH:MM <msg>"},
        {"command":"schedule","description":"Tekrarlayan zamanlama"},
        {"command":"tailscale","description":"Tailscale exit-node aç/kapat (modül gerekli)"},
        {"command":"perf_balanced","description":"8 core + freq cap (önerilen perf modu)"},
        {"command":"perf_help","description":"CPU/Performance kılavuzu"},
        {"command":"minimal_mode","description":"Gereksiz servisleri dondur (~640 MB)"},
        {"command":"speedtest","description":"Cloudflare speed test - /speedtest [quick|<mb>|full]"},
        {"command":"update","description":"Modülleri GitHub uzerinden guncelle - /update [all|<id>]"},
        {"command":"lang","description":"Bot dilini degistir - /lang [code]"}
    ]}'
    local resp
    resp=$("$CURL" -sS --cacert "$CA" --max-time 10 \
        -H "Content-Type: application/json" \
        -X POST "${TG_API}${TOKEN}/setMyCommands" \
        --data "$body" 2>/dev/null)
    local ok
    ok=$(echo "$resp" | "$JQ" -r '.ok // empty' 2>/dev/null)
    if [ "$ok" = "true" ]; then
        touch "$marker"
        log "Commands registered for $BOT_VERSION"
    else
        log "setMyCommands failed: $(echo "$resp" | head -c 200)"
    fi
}
register_commands &

# Boot greeting (once per boot)
if [ ! -f "$BOOT_FLAG" ]; then
    msg=$(printf "${MSG[boot_greeting_fmt]}" \
        "$(greeting)" "$(getprop ro.product.model)" "$(fmt_uptime)")
    tg_send "$OWNER" "$msg" >/dev/null
    log "Boot greeting sent"
    touch "$BOOT_FLAG"
fi

# Long-polling loop
OFFSET=$(cat "$OFFSET_FILE" 2>/dev/null)
[ -z "$OFFSET" ] && OFFSET=0

while true; do
    response=$("$CURL" -sS --cacert "$CA" --max-time 35 \
        "${TG_API}${TOKEN}/getUpdates?timeout=20&offset=${OFFSET}&allowed_updates=%5B%22message%22%2C%22callback_query%22%5D" \
        2>/dev/null)

    # Always run task poller (handles done/timeout regardless of incoming updates)
    poll_tasks
    # Auto background pollers (every long-poll iteration ≈ every 20-25s)
    poll_sms_forward
    poll_auto_alerts
    poll_heartbeat
    poll_schedules

    if [ -z "$response" ]; then
        sleep 3; continue
    fi

    ok=$(echo "$response" | "$JQ" -r '.ok' 2>/dev/null)
    if [ "$ok" != "true" ]; then
        log "Bad API response: $(echo "$response" | head -c 200)"
        sleep 10; continue
    fi

    count=$(echo "$response" | "$JQ" '.result | length' 2>/dev/null)
    [ "$count" -gt 0 ] 2>/dev/null || continue

    TMP_UPDATES="$DATADIR/.updates.tmp"
    echo "$response" | "$JQ" -c '.result[]' > "$TMP_UPDATES"
    while IFS= read -r upd; do
        update_id=$(echo "$upd" | "$JQ" -r '.update_id')
        OFFSET=$((update_id + 1))
        echo "$OFFSET" > "$OFFSET_FILE"

        # callback_query?
        cb_id=$(echo "$upd" | "$JQ" -r '.callback_query.id // empty')
        if [ -n "$cb_id" ]; then
            cb_chat=$(echo "$upd" | "$JQ" -r '.callback_query.message.chat.id // empty')
            cb_msg_id=$(echo "$upd" | "$JQ" -r '.callback_query.message.message_id // empty')
            cb_data=$(echo "$upd" | "$JQ" -r '.callback_query.data // empty')
            log "callback from $cb_chat: $cb_data"
            handle_callback "$cb_id" "$cb_chat" "$cb_msg_id" "$cb_data"
            continue
        fi

        # message?
        chat_id=$(echo "$upd" | "$JQ" -r '.message.chat.id // empty')
        msg_id=$(echo "$upd"  | "$JQ" -r '.message.message_id // empty')
        text=$(echo "$upd"    | "$JQ" -r '.message.text   // empty')

        # Document / photo upload — only owner, only if /upload state is pending
        if [ "$chat_id" = "$OWNER" ] && [ -f "$UPLOAD_STATE" ]; then
            doc_file_id=$(echo "$upd" | "$JQ" -r '.message.document.file_id // empty')
            doc_name=$(echo "$upd"    | "$JQ" -r '.message.document.file_name // empty')
            if [ -n "$doc_file_id" ]; then
                log "upload (document) from $chat_id: $doc_name"
                handle_upload_response "$chat_id" "$doc_file_id" "$doc_name"
                continue
            fi
            # Photo: pick largest size
            photo_file_id=$(echo "$upd" | "$JQ" -r '.message.photo | (sort_by(.file_size) | last).file_id // empty')
            if [ -n "$photo_file_id" ]; then
                log "upload (photo) from $chat_id"
                handle_upload_response "$chat_id" "$photo_file_id" ""
                continue
            fi
        fi

        if [ -n "$chat_id" ] && [ -n "$text" ]; then
            log "msg from $chat_id: $(echo "$text" | head -c 80)"
            dispatch "$chat_id" "$msg_id" "$text"
        fi
    done < "$TMP_UPDATES"
    rm -f "$TMP_UPDATES"
done
