# statusbot العربية — community translation seeded by upstream
# Sourced AFTER en.sh; keys here override English. Missing keys fall back.
# Note: terminals/clients render Arabic right-to-left automatically.

declare -gA MSG=(
    [lang_current_fmt]="اللغة الحالية: %s"
    [lang_available_header]="اللغات المتاحة:"
    [lang_set_fmt]="تم تغيير اللغة إلى %s. سيُعاد تشغيل البوت خلال 3 ثوانٍ."
    [lang_invalid_fmt]="رمز لغة غير معروف: %s. راجع /lang للقائمة."
    [lang_usage]="الاستخدام: /lang [رمز]
بدون وسيط: يعرض اللغة الحالية + المتاحة.
مع رمز: يبدّل ويعيد تشغيل البوت."

    [greet_morning]="صباح الخير"
    [greet_noon]="مساء الخير"
    [greet_evening]="مساء الخير"
    [greet_night]="ليلة سعيدة"
    [boot_greeting_fmt]="%s، أنا متصل 🤖
%s — uptime: %s
اكتب /help لقائمة الأوامر."

    [help_full_fmt]="بوت ZTE F50 — الأوامر

📊 الحالة
/status — نظرة عامة كاملة
/uptime — وقت التشغيل
/load — حمل CPU (تفصيلي)
/mem — RAM
/disk — القرص
/temp — درجة الحرارة (CPU)
/ps — أعلى 10 عمليات (CPU)

📡 الخلوي
/signal — جودة الإشارة (RSSI, RSRP, RSRQ)
/cellinfo — المشغل + IMEI + ICCID + الرقم
/imei — IMEI
/imei_sorgula [imei] — تحليل IMEI + e-Devlet
/imei_degis <imei> — تغيير IMEI (مع تأكيد، إعادة تشغيل)
/operator — المشغل فقط
/qos — تفاصيل QoS / النطاق
/sms_list [N] — آخر N رسالة (افتراضي 10)
/sms_count — إجمالي صندوق الوارد
/sms_send <num> <نص> — إرسال SMS عبر AT
/at <cmd> — أمر AT خام

🌐 الشبكة
/ip — IP عام + محلي
/traffic — RX/TX منذ الإقلاع
/ping <host>
/speedtest [cf|ookla|fast] [size] — اختبار السرعة
/clients — العملاء المتصلون (ARP)
/wifi — SSID الهوت سبوت + كلمة السر + العملاء
/tunnel — حالة Cloudflared

🔧 النظام
/modules — وحدات Magisk
/version
/reboot — إعادة تشغيل (مع تأكيد)
/komut <cmd> — أمر shell (قابل للإلغاء)
/file <مسار> — جلب ملف من الجهاز
/upload <هدف> — رفع ملف إلى الجهاز
/screenshot — لقطة شاشة
/ramclean [pkg…] — تنظيف الذاكرة
/performance [on|off] — وضع ZTE Performance (يحتاج إعادة تشغيل)
/perf_balanced [mhz] — 8 أنوية + سقف تردد (موصى به 1800)
/perf_help — دليل المقارنة
/minimal_mode [on|persist|off] — تجميد الخدمات (~640 MB)
/zte_setpw <pwd> — تعيين كلمة سر مسؤول ZTE
/lang [code] — تغيير لغة البوت

🗂 نظام الملفات
/ls <مسار>
/cat <ملف> — المحتوى (4 KB)
/df — استخدام القرص
/du <dir> — أحجام المجلدات الفرعية
/log [N] — آخر N سطر من السجل
/dump_sms — تفريغ صندوق الوارد بالكامل

🌐 الشبكة (إضافي)
/connections — TCP نشطة
/listening — المنافذ المستمعة
/dhcp — جدول DHCP
/dns — تكوين DNS

⚡ الطاقة / النواة
/cpu_freq — ترددات CPU
/cpu_governor [name] — عرض/تغيير governor
/wakelock — wakelocks نشطة

📦 التطبيقات
/installed [3rd|disabled|system|all]
/freeze <pkg> — تجميد الحزمة
/unfreeze <pkg> — إلغاء التجميد

⏰ الجدولة
/alarm HH:MM <msg> — لمرة واحدة
/schedule <sec> <cmd> — متكرر
/schedule list / clear / cancel <idx>
/heartbeat <ساعات> — نبض دوري
/quiet_hours <من> <إلى> — ساعات الصمت

🔒 الأمان
/who — جلسات SSH/ADB نشطة
/last_boot — سجل الإقلاع
/bot_stats — إحصائيات البوت
/restart_bot — إعادة تشغيل البوت
/update [all|<id>] — تحديث الوحدات من GitHub

🌍 Tailscale (وحدة اختيارية)
/tailscale auth <key> — حفظ مفتاح المصادقة
/tailscale on / off — تشغيل/إيقاف
/tailscale status — الحالة + RAM
/tailscale ip / peers / log / logout

🔔 تلقائي (في الخلفية):
• تحويل الرسائل الواردة
• تنبيهات عند الحرارة > %d°C، RAM < %d%%، tunnel معطل
• Heartbeat (إن كان مُهيأ) والجدولة
• Quiet hours تكتم التنبيهات

💬 محفزات الدردشة
selam, merhaba, sa — تحية
naber — حالة + تحية
saat — وقت الجهاز
iyi misin — فحص الحالة"

    [uptime_days_fmt]="%d ي %02d س %02d د"
    [uptime_hours_fmt]="%d س %02d د"
    [uptime_short_fmt]="%d د %02d ث"
    [disk_fmt]="%s / %s (%s مستخدم)"

    [load_status_calm]="🟢 هادئ (%d%%)"
    [load_status_active]="🟡 نشط (%d%%)"
    [load_status_full]="🟠 ممتلئ (%d%%)"
    [load_status_busy]="🔴 مشغول (%d%%)"
    [load_full_fmt]="📊 حمل CPU (%d نواة)

الآن (1 دقيقة):    %s
آخر 5 دقائق:       %s
آخر 15 دقيقة:      %s

الحالة: %s

دليل:
  %d.0 = جميع CPU بأقصى طاقة
  < %d.0 = توجد سعة متاحة
  > %d.0 = طابور، احتمال بطء"

    [status_model_fmt]="📱 %s\n"
    [status_uptime_fmt]="⏱  Uptime: %s\n"
    [status_ram_fmt]="💾 RAM: %s\n"
    [status_disk_fmt]="💿 القرص: %s\n"
    [status_temp_fmt]="🌡  الحرارة: %s\n"
    [status_perf_on]="⚡ Performance: ON 🟢\n"
    [status_perf_off]="⚡ Performance: OFF ⚪\n"
    [status_operator_fmt]="📡 المشغل: %s\n"
    [status_signal_fmt]="📶 الإشارة: RSSI %s (%s)\n"
    [status_public_ip_fmt]="🌐 IP عام: %s"

    [perf_status_on]="⚡ وضع Performance: مُفعّل 🟢
لإيقافه: /performance off"
    [perf_status_off]="⚡ وضع Performance: معطل ⚪
لتفعيله: /performance on"
    [perf_no_password]="❌ كلمة سر ZTE غير محددة. أولاً: /zte_setpw <pwd>"
    [perf_login_failed]="❌ فشل دخول ZTE. كلمة سر خاطئة؟ حدّث عبر /zte_setpw."
    [perf_login_failed_short]="❌ فشل دخول ZTE."
    [perf_set_failed_fmt]="❌ فشل الضبط: %s"
    [perf_enabled_reboot]="⚡ تم تفعيل وضع Performance 🟢
أعد تشغيل الجهاز لتطبيق التغيير."
    [perf_disabled_reboot]="⚡ تم تعطيل وضع Performance ⚪
أعد تشغيل الجهاز لتطبيق التغيير."
    [perf_usage]="الاستخدام: /performance [on|off|status]"

    [zte_pw_set_fmt]="تم تعيين كلمة سر ZTE (الطول: %d بايت).
للتغيير: /zte_setpw <pwd جديدة>"
    [zte_pw_usage]="الاستخدام: /zte_setpw <pwd>
(كلمة سر مسؤول ZTE — لـ /performance إلخ)"
    [zte_pw_saved_fmt]="✓ تم حفظ كلمة سر ZTE (%d بايت).
اختبار: /performance"
    [iptal_imei]="  ✓ استعلام IMEI"
    [iptal_upload]="  ✓ upload معلق"
    [iptal_speedtest]="  ✓ حلقة Speedtest"
    [iptal_none]="لا يوجد شيء معلق لإلغائه"
    [iptal_done_fmt]="🛑 ملغى:%s"
    [reboot_starting]="🔁 إعادة التشغيل بدأت…"
    [reboot_expired]="⚠️ انتهى الوقت. شغّل /reboot مجدداً."
    [reboot_confirm]="⚠️ أكّد: اكتب \"/reboot YES\" خلال 60 ثانية."
    [version_fmt]="🤖 Bot %s
📱 %s
🏷  %s
🤖 Android %s (SDK %s)
🐧 %s"

    [common_not_exists_fmt]="❌ غير موجود: %s"
    [btn_cancel]="❌ إلغاء"
    [btn_reboot_now]="🔁 أعد التشغيل الآن"

    [csq_excellent]="🟢 ممتاز"
    [csq_good]="🟢 جيد"
    [csq_moderate]="🟡 متوسط"
    [csq_weak]="🟠 ضعيف"
    [csq_very_weak]="🔴 ضعيف جداً"
    [csq_unknown]="🔴 غير معروف"

    [alert_temp_fmt]="🌡 تحذير: درجة حرارة CPU مرتفعة — %d°C
(العتبة %d°C، لا تحذير متكرر لمدة %d ث)"
    [alert_mem_fmt]="💾 تحذير: RAM منخفض جداً — %d%% متاحة
(%d MB)"
    [alert_tunnel]="🔌 تحذير: Cloudflared tunnel لا يعمل (لا توجد عملية)"
    [alert_sms_forward_fmt]="📨 SMS وارد — %s
👤 %s

%s"

    [chat_greeting_fmt]="%s، أنا هنا 👋"
    [chat_naber_fmt]="%s! حالتي:

%s"
    [chat_time_fmt]="🕐 %s"
    [chat_imisin_fmt]="بخير 🙂 (temp %s, uptime %s)"
    [chat_thanks]="🤖 على الرحب والسعة 👍"
    [chat_morning_fmt]="صباح الخير! ☀️ %s منذ الإقلاع"
    [chat_night]="ولك أيضاً 🌙 سأبقى مستيقظاً"

    [update_header]="🔍 فحص تحديثات الوحدات"
    [update_all_current]="جميع الوحدات محدّثة."
    [update_none_defined]="لا توجد وحدة بـ updateJson مُعرّف."
)
