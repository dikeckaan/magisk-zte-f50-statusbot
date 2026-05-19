# statusbot हिन्दी — community translation seeded by upstream
# Sourced AFTER en.sh; keys here override English. Missing keys fall back.

declare -gA MSG=(
    [lang_current_fmt]="वर्तमान भाषा: %s"
    [lang_available_header]="उपलब्ध भाषाएँ:"
    [lang_set_fmt]="भाषा %s में बदली गई। बॉट 3 सेकंड में रीस्टार्ट होगा।"
    [lang_invalid_fmt]="अज्ञात भाषा कोड: %s। सूची हेतु /lang देखें।"
    [lang_usage]="उपयोग: /lang [कोड]
बिना तर्क: वर्तमान + उपलब्ध भाषाएँ।
कोड के साथ: बदलकर बॉट रीस्टार्ट।"

    [greet_morning]="सुप्रभात"
    [greet_noon]="नमस्ते"
    [greet_evening]="शुभ संध्या"
    [greet_night]="शुभ रात्रि"
    [boot_greeting_fmt]="%s, मैं ऑनलाइन हूँ 🤖
%s — uptime: %s
कमांड के लिए /help टाइप करें।"

    [help_full_fmt]="ZTE F50 बॉट — कमांड

📊 स्थिति
/status — पूर्ण विवरण
/uptime — चलने का समय
/load — CPU लोड (विस्तृत)
/mem — RAM
/disk — डिस्क
/temp — तापमान (CPU)
/ps — टॉप 10 प्रोसेस (CPU)

📡 सेल्युलर
/signal — सिग्नल गुणवत्ता (RSSI, RSRP, RSRQ)
/cellinfo — ऑपरेटर + IMEI + ICCID + नंबर
/imei — IMEI (हर स्लॉट)
/imei_sorgula [imei] — IMEI विश्लेषण + e-Devlet
/imei_degis <imei> — IMEI बदलें (पुष्टि + रीबूट)
/operator — केवल ऑपरेटर
/qos — QoS / बैंड विवरण
/sms_list [N] — पिछले N SMS (डिफ़ॉल्ट 10)
/sms_count — इनबॉक्स कुल
/sms_send <num> <text> — AT से SMS भेजें
/at <cmd> — कच्चा AT कमांड

🌐 नेटवर्क
/ip — पब्लिक + लोकल IP
/traffic — बूट के बाद RX/TX
/ping <host>
/speedtest [cf|ookla|fast] [size] — स्पीड टेस्ट
/clients — कनेक्टेड क्लाइंट (ARP)
/wifi — हॉटस्पॉट SSID + पासवर्ड + क्लाइंट
/tunnel — Cloudflared स्थिति

🔧 सिस्टम
/modules — Magisk मॉड्यूल
/version
/reboot — रीबूट (पुष्टि)
/komut <cmd> — शेल कमांड (कैंसल योग्य)
/file <path> — डिवाइस से फ़ाइल लाएं
/upload <target> — डिवाइस में फ़ाइल अपलोड
/screenshot — स्क्रीनशॉट
/ramclean [pkg…] — मेमोरी सफाई
/performance [on|off] — ZTE Performance मोड (रीबूट चाहिए)
/perf_balanced [mhz] — 8 कोर + फ़्रीक्वेंसी कैप (अनुशंसित 1800)
/perf_help — मोड तुलना गाइड
/minimal_mode [on|persist|off] — सर्विसेज़ फ़्रीज़ (~640 MB)
/zte_setpw <pwd> — ZTE एडमिन पासवर्ड सेट
/lang [code] — बॉट भाषा बदलें

🗂 फ़ाइल सिस्टम
/ls <path>
/cat <file> — सामग्री (4 KB)
/df — डिस्क उपयोग
/du <dir> — सब-डायरेक्टरी आकार
/log [N] — लॉग की अंतिम N पंक्तियाँ
/dump_sms — पूरा इनबॉक्स डंप

🌐 नेटवर्क (अतिरिक्त)
/connections — सक्रिय TCP
/listening — लिसनिंग पोर्ट
/dhcp — DHCP लीज़ टेबल
/dns — DNS कॉन्फ़िगरेशन

⚡ पावर / कर्नेल
/cpu_freq — CPU फ़्रीक्वेंसी
/cpu_governor [name] — गवर्नर दिखाएँ/बदलें
/wakelock — सक्रिय वेकलॉक

📦 ऐप्स
/installed [3rd|disabled|system|all]
/freeze <pkg> — पैकेज फ़्रीज़
/unfreeze <pkg> — पैकेज सक्रिय

⏰ शेड्यूलिंग
/alarm HH:MM <msg> — एक बार
/schedule <sec> <cmd> — दोहराने वाला
/schedule list / clear / cancel <idx>
/heartbeat <घंटे> — आवधिक पिंग
/quiet_hours <से> <तक> — मौन घंटे

🔒 सुरक्षा
/who — सक्रिय SSH/ADB सत्र
/last_boot — बूट इतिहास
/bot_stats — बॉट आंतरिक आंकड़े
/restart_bot — बॉट रीस्टार्ट
/update [all|<id>] — GitHub से मॉड्यूल अपडेट

🌍 Tailscale (वैकल्पिक मॉड्यूल)
/tailscale auth <key> — auth-key सहेजें
/tailscale on / off — शुरू/बंद
/tailscale status — स्थिति + RAM
/tailscale ip / peers / log / logout

🔔 स्वचालित (पृष्ठभूमि):
• आने वाले SMS फ़ॉरवर्ड
• temp > %d°C, RAM < %d%%, tunnel बंद होने पर अलर्ट
• Heartbeat (अगर कॉन्फ़िगर) और शेड्यूल
• Quiet hours अलर्ट दबाते हैं

💬 चैट ट्रिगर
selam, merhaba, sa — अभिवादन
naber — स्थिति + अभिवादन
saat — डिवाइस समय
iyi misin — स्थिति जाँच"

    [uptime_days_fmt]="%d दि %02d घ %02d मि"
    [uptime_hours_fmt]="%d घ %02d मि"
    [uptime_short_fmt]="%d मि %02d से"
    [disk_fmt]="%s / %s (%s प्रयुक्त)"

    [load_status_calm]="🟢 शांत (%d%%)"
    [load_status_active]="🟡 सक्रिय (%d%%)"
    [load_status_full]="🟠 पूर्ण (%d%%)"
    [load_status_busy]="🔴 व्यस्त (%d%%)"
    [load_full_fmt]="📊 CPU लोड (%d कोर)

अभी (1 मि):     %s
पिछले 5 मि:     %s
पिछले 15 मि:    %s

स्थिति: %s

गाइड:
  %d.0 = सभी CPU पूरी क्षमता पर
  < %d.0 = क्षमता उपलब्ध
  > %d.0 = कतार, देरी संभव"

    [status_model_fmt]="📱 %s\n"
    [status_uptime_fmt]="⏱  Uptime: %s\n"
    [status_ram_fmt]="💾 RAM: %s\n"
    [status_disk_fmt]="💿 डिस्क: %s\n"
    [status_temp_fmt]="🌡  तापमान: %s\n"
    [status_perf_on]="⚡ Performance: ON 🟢\n"
    [status_perf_off]="⚡ Performance: OFF ⚪\n"
    [status_operator_fmt]="📡 ऑपरेटर: %s\n"
    [status_signal_fmt]="📶 सिग्नल: RSSI %s (%s)\n"
    [status_public_ip_fmt]="🌐 पब्लिक IP: %s"

    [perf_status_on]="⚡ Performance मोड: ON 🟢
बंद करने: /performance off"
    [perf_status_off]="⚡ Performance मोड: OFF ⚪
चालू करने: /performance on"
    [perf_no_password]="❌ ZTE पासवर्ड सेट नहीं। पहले: /zte_setpw <pwd>"
    [perf_login_failed]="❌ ZTE लॉगिन विफल। गलत पासवर्ड? /zte_setpw से अपडेट करें।"
    [perf_login_failed_short]="❌ ZTE लॉगिन विफल।"
    [perf_set_failed_fmt]="❌ सेट विफल: %s"
    [perf_enabled_reboot]="⚡ Performance मोड सक्षम 🟢
परिवर्तन लागू करने के लिए रीबूट करें।"
    [perf_disabled_reboot]="⚡ Performance मोड अक्षम ⚪
परिवर्तन लागू करने के लिए रीबूट करें।"
    [perf_usage]="उपयोग: /performance [on|off|status]"

    [zte_pw_set_fmt]="ZTE पासवर्ड सेट (लंबाई: %d बाइट)।
बदलने के लिए: /zte_setpw <नया_pwd>"
    [zte_pw_usage]="उपयोग: /zte_setpw <pwd>
(ZTE वेब एडमिन पासवर्ड — /performance आदि के लिए)"
    [zte_pw_saved_fmt]="✓ ZTE पासवर्ड सहेजा (%d बाइट)।
परीक्षण: /performance"
    [iptal_imei]="  ✓ IMEI क्वेरी"
    [iptal_upload]="  ✓ लंबित अपलोड"
    [iptal_speedtest]="  ✓ Speedtest लूप"
    [iptal_none]="कोई लंबित कार्य रद्द करने को नहीं"
    [iptal_done_fmt]="🛑 रद्द:%s"
    [reboot_starting]="🔁 रीबूट शुरू…"
    [reboot_expired]="⚠️ समय समाप्त। पहले /reboot दोबारा चलाएं।"
    [reboot_confirm]="⚠️ पुष्टि: 60 सेकंड में \"/reboot YES\" टाइप करें।"
    [version_fmt]="🤖 Bot %s
📱 %s
🏷  %s
🤖 Android %s (SDK %s)
🐧 %s"

    [common_not_exists_fmt]="❌ मौजूद नहीं: %s"
    [btn_cancel]="❌ रद्द"
    [btn_reboot_now]="🔁 अभी रीबूट"

    [csq_excellent]="🟢 उत्कृष्ट"
    [csq_good]="🟢 अच्छा"
    [csq_moderate]="🟡 मध्यम"
    [csq_weak]="🟠 कमज़ोर"
    [csq_very_weak]="🔴 बहुत कमज़ोर"
    [csq_unknown]="🔴 अज्ञात"

    [alert_temp_fmt]="🌡 चेतावनी: CPU तापमान अधिक — %d°C
(सीमा %d°C, %d सेकंड फिर अलर्ट नहीं)"
    [alert_mem_fmt]="💾 चेतावनी: RAM बहुत कम — %d%% उपलब्ध
(%d MB)"
    [alert_tunnel]="🔌 चेतावनी: Cloudflared tunnel नहीं चल रहा (प्रोसेस नहीं)"
    [alert_sms_forward_fmt]="📨 आने वाला SMS — %s
👤 %s

%s"

    [chat_greeting_fmt]="%s, मैं यहाँ हूँ 👋"
    [chat_naber_fmt]="%s! मेरी स्थिति:

%s"
    [chat_time_fmt]="🕐 %s"
    [chat_imisin_fmt]="ठीक हूँ 🙂 (temp %s, uptime %s)"
    [chat_thanks]="🤖 आपका स्वागत है 👍"
    [chat_morning_fmt]="सुप्रभात! ☀️ बूट के बाद %s"
    [chat_night]="आपको भी 🌙 मैं जागता रहूँगा"

    [update_header]="🔍 मॉड्यूल अपडेट जाँच"
    [update_all_current]="सभी मॉड्यूल अद्यतन हैं।"
    [update_none_defined]="किसी मॉड्यूल में updateJson परिभाषित नहीं।"
)
