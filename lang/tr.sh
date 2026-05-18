# statusbot Türkçe strings
#
# en.sh source edildikten SONRA okunur — buradaki anahtarlar EN'deki
# karşılıklarını override eder. Eksik anahtar EN'den gelir, kullanıcı
# bozuk mesaj görmez.

declare -gA MSG=(
    # ─── /lang ────────────────────────────────────────────────────────
    [lang_current_fmt]="Mevcut dil: %s"
    [lang_available_header]="Mevcut diller:"
    [lang_set_fmt]="Dil %s olarak ayarlandı. Bot 3 sn içinde yeniden başlatılacak."
    [lang_invalid_fmt]="Bilinmeyen dil kodu: %s. Liste için /lang"
    [lang_usage]="Kullanım: /lang [kod]
Argümansız: mevcut dili + mevcut seçenekleri gösterir.
Kod ile: dili değiştirir ve botu restart eder."

    # ─── selamlamalar ─────────────────────────────────────────────────
    [greet_morning]="Günaydın"
    [greet_noon]="Tünaydın"
    [greet_evening]="İyi akşamlar"
    [greet_night]="İyi geceler"
    [boot_greeting_fmt]="%s, ben ayaktayım 🤖
%s — uptime: %s
Komutlar için /help"

    # ─── /help (tam metin) ───────────────────────────────────────────
    [help_full_fmt]="ZTE F50 Bot — Komutlar

📊 Durum
/status — Genel özet (her şey)
/uptime — Çalışma süresi
/load — CPU yükü (detaylı)
/mem — RAM
/disk — Disk
/temp — Sıcaklık (CPU)
/ps — Top 10 process (CPU)

📡 Cellular
/signal — Sinyal kalitesi (RSSI, RSRP, RSRQ)
/cellinfo — Operatör, IMEI, ICCID, telefon
/imei — IMEI(ler)
/imei_sorgula [imei] — IMEI yapı analizi + e-Devlet sorgusu
/imei_degis <imei> — IMEI değiştir (onaylı, reboot eder)
/operator — Sadece operatör
/qos — QoS / Band detayları (AT+CGEQOSRDP)
/sms_list [N] — Son N SMS'i listele (default 10)
/sms_count — Inbox toplam sayısı
/sms_send <num> <text> — SMS gönder (AT denenir; her modem desteklemez)
/at <komut> — Tekil AT komutu çalıştır

🌐 Ağ
/ip — Public + local IP'ler
/traffic — Boot'tan beri trafik (RX/TX)
/ping <host> — Ping testi
/speedtest [cf|ookla|fast] [size] — speedtest (default cf, /speedtest help)
/clients — Bağlı cihazlar (ARP)
/wifi — Hotspot SSID + şifre + bağlı cihazlar
/tunnel — Cloudflared durumu

🔧 Sistem
/modules — Magisk modülleri
/version — Versiyon
/reboot — Yeniden başlat (onay gerekli)
/komut <kmt> — Shell komutu (iptal düğmeli)
/file <path> — Cihazdan dosya çek
/upload <hedef> — Cihaza dosya yükle (sonraki ekli)
/screenshot — Ekran görüntüsü
/ramclean [pkg...] — RAM temizle (VPN/sistem korunur)
/performance [on|off] — ZTE Performance Modu (reboot gerekir)
/perf_balanced [mhz] — 8 core + freq cap (önerilen, default 1800)
/perf_help — Mod karşılaştırma + kılavuz
/minimal_mode [on|persist|off] — servisleri kapat (on=transient ~240MB, persist=~640MB)
/zte_setpw <şifre> — ZTE admin şifresini ayarla
/lang [kod] — Bot dilini değiştir

🗂 Filesystem
/ls <yol> — Dizin listesi
/cat <dosya> — Dosya içeriği (4 KB limit)
/df — Disk doluluk
/du <dizin> — Alt dizin boyutları
/log [N] — Bot log son N satır
/dump_sms — Tüm inbox SMS dump (dosya olarak)

🌐 Ağ (ekstra)
/connections — Aktif TCP bağlantıları
/listening — Dinleyen portlar
/dhcp — DHCP lease tablosu
/dns — DNS yapılandırması

⚡ Güç / Kernel
/cpu_freq — CPU frekansları
/cpu_governor [name] — Governor göster/değiştir
/wakelock — Aktif wakelock'lar

📦 Uygulamalar
/installed [3rd|disabled|system|all]
/freeze <pkg> — Paketi dondur
/unfreeze <pkg> — Aktive et

⏰ Zamanlama
/alarm HH:MM <msg> — Tek seferlik
/schedule <sn> <kmt> — Tekrarlayan
/schedule list/clear — Listele/sil
/heartbeat <saat> — Periyodik canlı sinyali
/quiet_hours <from> <to> — Sessiz saatler (alarmlar susar)

🔒 Güvenlik
/who — Aktif SSH/ADB oturumları
/last_boot — Boot geçmişi
/bot_stats — Bot iç istatistik
/restart_bot — Botu yeniden başlat
/update [all|<id>] — Modülleri GitHub'dan güncelle

🌍 Tailscale (opsiyonel modül)
/tailscale auth <key> — auth key kaydet
/tailscale on / off — başlat/durdur
/tailscale status — durum + RAM
/tailscale ip / peers / log / logout

🔔 Otomatik (arka plan):
• Yeni gelen SMS otomatik forward
• Sıcaklık > %d°C, RAM < %%%d, tunnel düşmesi alarm
• Heartbeat (varsa) ve zamanlamalar
• Quiet hours alarmları susturur

💬 Sohbet
selam, merhaba, sa — selamlama
naber — durum + selamlama
saat — cihaz saati
iyi misin — durum kontrol"

    # ─── fmt_uptime ──────────────────────────────────────────────────
    [uptime_days_fmt]="%d gün %02d sa %02d dk"
    [uptime_hours_fmt]="%d sa %02d dk"
    [uptime_short_fmt]="%d dk %02d sn"

    # ─── fmt_disk ────────────────────────────────────────────────────
    [disk_fmt]="%s / %s (%s dolu)"

    # ─── fmt_load ────────────────────────────────────────────────────
    [load_status_calm]="🟢 Rahat (%d%%)"
    [load_status_active]="🟡 Aktif (%d%%)"
    [load_status_full]="🟠 Dolu (%d%%)"
    [load_status_busy]="🔴 Yoğun (%d%%)"
    [load_full_fmt]="📊 CPU Yükü (%d çekirdek)

Şu an (1dk ort):   %s
Son 5dk:           %s
Son 15dk:          %s

Durum: %s

Yük rehberi:
  %d.0 = tüm CPU'lar tam dolu
  < %d.0 = boşta kapasite var
  > %d.0 = kuyruk var, yavaşlamalar olabilir"

    # ─── /file ───────────────────────────────────────────────────────
    [file_usage]="Kullanım: /file <yol>
Örnek: /file /data/statusbot/bot.log
Maks 50 MB (Telegram limiti)"
    [file_not_found_fmt]="❌ Dosya bulunamadı: %s"
    [file_empty_fmt]="⚠️ Dosya boş: %s"
    [file_too_big_fmt]="❌ Çok büyük: %d MB (limit 50 MB).
Bölmek için: split -b 49M %s /tmp/part_"
    [file_sending_fmt]="📤 Gönderiliyor (%s)…"
    [file_unknown_error]="bilinmeyen"
    [file_tg_rejected_fmt]="❌ Telegram reddetti: %s"
    [file_caption_fmt]="📄 %s"

    # ─── /screenshot ─────────────────────────────────────────────────
    [ss_failed]="❌ Screencap başarısız (cihaz uyuyor olabilir veya secure window'da)"
    [ss_taken_fmt]="📸 Çekildi (%d byte), gönderiliyor…"
    [ss_caption_fmt]="📸 Ekran görüntüsü — %s"

    # ─── /wifi ───────────────────────────────────────────────────────
    [wifi_header]="📶 WiFi (Hotspot)"
    [wifi_no_conf]="⚠️ hostapd.conf bulunamadı"
    [wifi_ssid_fmt]="📡 SSID:    %s"
    [wifi_pass_fmt]="🔑 Şifre:   %s"
    [wifi_sec_fmt]="🔐 Güvenlik: %s"
    [wifi_bssid_fmt]="🏷 BSSID:   %s"
    [wifi_freq_fmt]="📻 Frekans: %s MHz (%s, %s)"
    [wifi_bridge_fmt]="🌐 Bridge:  %s"
    [wifi_clients_header]="👥 Bağlı cihazlar:"
    [wifi_no_clients]="  (şu an aktif istemci yok)"

    # ─── /upload ─────────────────────────────────────────────────────
    [upload_usage_fmt]="Kullanım: /upload <hedef-yol>
Örnek: /upload /sdcard/Download/

Sonraki gönderdiğin dosya buraya kaydedilir (2dk içinde).
İptal: /iptal"
    [upload_waiting_fmt]="📥 Bekleniyor: sıradaki dosya '%s' altına kaydedilecek.
İptal: /iptal"
    [upload_getfile_failed_fmt]="❌ getFile başarısız: %s"
    [upload_saved_fmt]="✅ Kaydedildi: %s (%d KB)"
    [upload_download_failed]="❌ İndirme başarısız"

    # ─── /at ─────────────────────────────────────────────────────────
    [at_usage]="Kullanım: /at <AT komutu>
Örnek: /at AT+CSQ
Slot 1 için: /at slot=1 AT+CSQ
Tehlikeli! Modem'i bozabilirsin, dikkatli kullan."
    [at_no_sendat]="❌ sendat yok (UFI-TOOLS gerekli)"
    [at_must_start_with]="❌ Komut 'AT' ile başlamalı"
    [at_request_fmt]="📟 \$ %s (slot=%d)"
    [at_empty_response]="(boş yanıt)"

    # ─── /ramclean ───────────────────────────────────────────────────
    [rc_list_header]="🔝 RAM Tüketim (top 15):"
    [rc_mode_soft]="🧹 Soft Clean"
    [rc_mode_aggressive]="🧨 Agresif Clean"
    [rc_mode_nuke]="💣 NUKE Clean"
    [rc_before_fmt]="Önce:  RAM %d MB | Swap %d MB"
    [rc_after_fmt]="Sonra: RAM %d MB | Swap %d MB"
    [rc_ram_gain_fmt]="✅ RAM kazanımı: +%d MB"
    [rc_ram_loss_fmt]="⚠️ RAM azaldı: %d MB"
    [rc_ram_same]="≈ RAM aynı"
    [rc_swap_gain_fmt]="✅ Swap kazanımı: +%d MB"
    [rc_killed_fmt]="🔥 Force-stop: %d app%s"
    [rc_killed_more_fmt]="  ... ve %d tane daha"
    [rc_modes_help]="Modlar:
• /ramclean — soft (bilinen heavy)
• /ramclean aggressive — 3rd-party hepsi
• /ramclean nuke — agresif + trim-memory
• /ramclean list — top 15 RAM"

    # ─── /airplane ───────────────────────────────────────────────────
    [airplane_no_sendat]="❌ sendat yok"
    [airplane_on_fmt]="✈️ Uçak modu AÇIK
%s"
    [airplane_off_fmt]="📡 Uçak modu KAPALI
%s"
    [airplane_off_state]="✈️ Modem KAPALI (CFUN=0)"
    [airplane_active_state]="📡 Modem aktif (CFUN=1)"
    [airplane_on_state]="✈️ Uçak modu AÇIK (CFUN=4)"
    [airplane_unknown_fmt]="Mod: %s"
    [airplane_usage]="Kullanım: /airplane on|off|status"

    # ─── /sms_send ───────────────────────────────────────────────────
    [sms_usage]="Kullanım: /sms_send <numara> <mesaj>
Örnek: /sms_send +905551234567 merhaba

⚠️ Shell tabanlı SMS gönderimi sınırlı. AT+CMGS denenir, modem desteklerse çalışır."
    [sms_no_sendat]="❌ sendat yok"
    [sms_sent_fmt]="✅ SMS gönderildi (ya da kuyruğa alındı):
to: %s
msg: %s"
    [sms_failed_fmt]="❌ Gönderim başarısız:
%s

Not: bu modem AT tabanlı SMS gönderimi desteklemiyor olabilir. UFI web UI'sını dene."

    # ─── fmt_battery ─────────────────────────────────────────────────
    [bat_unread]="🔋 Pil bilgisi alınamadı"
    [bat_status_charging]="🔌 Şarj oluyor"
    [bat_status_discharging]="🔋 Pil ile"
    [bat_status_full]="✅ Dolu"
    [bat_status_not_charging]="⏸ Şarj durduruldu"
    [bat_header]="🔋 Pil Durumu"
    [bat_charge_fmt]="Şarj: %%%d %s"
    [bat_state_fmt]="Durum: %s"
    [bat_temp_fmt]="Sıcaklık: %s"
    [bat_volt_fmt]="Voltaj: %s"

    # ─── handle_callback ─────────────────────────────────────────────
    [cb_unauthorized]="Yetkisiz"
    [cb_reboot_in_progress]="Yeniden başlatılıyor..."
    [cb_reboot_msg]="🔁 Cihaz yeniden başlatılıyor... (~50sn)"
    [cb_task_done]="Görev zaten tamamlandı"
    [cb_cancelling]="İptal ediliyor..."
    [cb_cancel_msg_fmt]="❌ İptal edildi: \$ %s

%s"
    [cb_no_output]="<çıktı yok>"
    [cb_unknown]="Bilinmeyen action"

    # ─── /imei_sorgula ──────────────────────────────────────────────
    [imeis_usage]="Kullanım: /imei_sorgula <15 haneli imei>"
    [imeis_digits_only]="❌ IMEI sadece rakam olmalı"
    [imeis_length_fmt]="❌ 15 hane olmalı (girdiğin %d hane)"
    [imeis_luhn_ok]="✓ Luhn geçerli"
    [imeis_luhn_bad]="❌ Luhn geçersiz"
    [imeis_header_fmt]="📱 IMEI: %s

🔍 Yapısal Analiz
TAC: %s (üretici+model kodu)
SNR: %s (seri no)
Check: %s (%s)"
    [imeis_edevlet_failed_fmt]="%s

⚠️ e-Devlet'e erişilemedi"
    [imeis_captcha_caption]="📱 IMEI Sorgu için captcha:
Görseldekini bir mesaj olarak yaz (2dk, 4-7 karakter).
İptal: /iptal"
    [imeis_result_fmt]="%s

📋 e-Devlet Sonucu
%s"
    [imeis_captcha_failed_fmt]="%s

❌ Captcha yanlış veya zaman aşımı.
Tekrar: /imei_sorgula %s"

    # ─── /imei_degis ─────────────────────────────────────────────────
    [imei_degis_no_sendat]="❌ sendat yok"
    [imei_degis_no_pending]="⚠️ Bekleyen IMEI değişikliği yok. Önce: /imei_degis <yeni_imei>"
    [imei_degis_expired]="⚠️ Süre doldu (>2dk). Yeniden başlat."
    [imei_degis_applied_fmt]="📱 IMEI değişikliği uygulandı.
Eski: %s
Yeni: %s
Modem yanıtı: %s

🔁 5sn içinde cihaz reboot olacak…"
    [imei_degis_usage]="Kullanım: /imei_degis <yeni_imei>
- 15 haneli rakam olmalı
- Onay için \"/imei_degis YES\" yaz (2 dakika içinde)
- Onaylanınca uygulanır + cihaz reboot olur

⚠️ AT+SPIMEI=0,\"…\" kullanır (Unisoc-spesifik).
Yanlış IMEI cihazı yasal sorunlara sokabilir."
    [imei_degis_digits_only]="❌ IMEI sadece rakam içermeli"
    [imei_degis_length_fmt]="❌ IMEI 15 hane olmalı (girdiğin %d hane)"
    [imei_degis_bad_luhn]="❌ Geçersiz IMEI (Luhn checksum tutmuyor).
Son hane check digit'tir, hesaplayıcı kullan."
    [imei_degis_pending_fmt]="⚠️ IMEI Değişikliği — Onay Bekleniyor

Mevcut: %s
Yeni:   %s

Onaylamak için 2dk içinde:
  /imei_degis YES

Uygulanınca cihaz REBOOT olacak."

    # ─── /iptal during IMEI captcha ──────────────────────────────────
    [imei_cancel_done]="✓ IMEI sorgu iptal edildi"

    # ─── misc inline (file ops, errors) ──────────────────────────────
    [common_not_exists_fmt]="❌ Yok: %s"

    # ─── poll_auto_alerts ────────────────────────────────────────────
    [alert_temp_fmt]="🌡 UYARI: CPU sıcaklığı yüksek — %d°C
(Eşik %d°C, %dsn boyunca tekrar uyarmaz)"
    [alert_mem_fmt]="💾 UYARI: RAM çok düşük — %%%d kullanılabilir
(%d MB)"
    [alert_tunnel]="🔌 UYARI: Cloudflared tunnel çalışmıyor (process yok)"
    [alert_sms_forward_fmt]="📨 Gelen SMS — %s
👤 %s

%s"

    # ─── /komut completion ───────────────────────────────────────────
    [komut_truncated_fmt]="
... (truncated, toplam %d bayt)"
    [komut_done_fmt]="✅ Tamamlandı: \$ %s

%s%s"

    # ─── Sohbet tetikleyicileri ──────────────────────────────────────
    [chat_greeting_fmt]="%s, buradayım 👋"
    [chat_naber_fmt]="%s! Durumum şöyle:

%s"
    [chat_time_fmt]="🕐 %s"
    [chat_imisin_fmt]="İyiyim 🙂 (sıcaklık %s, uptime %s)"
    [chat_thanks]="🤖 Rica ederim 👍"
    [chat_morning_fmt]="Günaydın! ☀️ %s sürüyor şu an"
    [chat_night]="Sana da 🌙 ben uyanık beklerim"

    # ─── /quiet_hours ────────────────────────────────────────────────
    [qh_active]="🔇 sessizdeyiz"
    [qh_inactive]="🔊 aktif değil"
    [qh_status_fmt]="Quiet hours: %s:00 — %s:00 (%s)"
    [qh_not_set]="Quiet hours tanımlı değil.
Kullanım: /quiet_hours <from> <to>
Örnek: /quiet_hours 23 7  (gece 23 → sabah 7 sessiz)"
    [qh_off]="🔊 Quiet hours kapatıldı"
    [qh_invalid_from]="❌ Geçersiz from"
    [qh_invalid_to]="❌ Geçersiz to"
    [qh_range_from]="❌ from 0-23 olmalı"
    [qh_range_to]="❌ to 0-23 olmalı"
    [qh_set_fmt]="🔇 Quiet hours: %s:00 — %s:00 (alarmlar bu saatlerde susar)"

    # ─── /heartbeat ──────────────────────────────────────────────────
    [hb_status_fmt]="❤️ Heartbeat: her %d saatte bir
Kapatmak: /heartbeat off"
    [hb_not_set]="Heartbeat kapalı.
Kullanım: /heartbeat <interval-saat>
Örnek: /heartbeat 6  (6 saatte bir 'ayaktayım' mesajı)"
    [hb_disabled]="❤️ Heartbeat kapatıldı"
    [hb_not_number]="❌ Saat (rakam) olmalı"
    [hb_min_one]="❌ En az 1 saat"
    [hb_set_fmt]="❤️ Heartbeat: her %d saatte bir aktive edildi"
    [hb_ping_fmt]="❤️ Heartbeat — %s, ayaktayım.
Uptime: %s | Sıcaklık: %s"

    # ─── /alarm ──────────────────────────────────────────────────────
    [alarm_usage]="Kullanım: /alarm HH:MM <mesaj>
Örnek: /alarm 14:30 Toplantı zamanı"
    [alarm_no_msg]="❌ Mesaj eksik"
    [alarm_bad_hour]="❌ Saat?"
    [alarm_bad_min]="❌ Dakika?"
    [alarm_bad_time]="❌ Geçersiz saat"
    [alarm_set_fmt]="⏰ Alarm: %s:%s (%dsa %02ddk sonra)
mesaj: %s"
    [alarm_fired_fmt]="⏰ ALARM
%s"

    # ─── /schedule ───────────────────────────────────────────────────
    [sch_empty]="Hiç zamanlama yok.

Kullanım:
/alarm HH:MM <mesaj>
/schedule <saniye> <komut>    (tekrarlı)
/schedule clear               (hepsini sil)"
    [sch_header]="📅 Zamanlamalar:"
    [sch_now_label]="şimdi"
    [sch_sec_fmt]="%dsn"
    [sch_min_fmt]="%ddk"
    [sch_hour_fmt]="%dsa %02ddk"
    [sch_entry_fmt]="  %d. [%s] %s — %s\n"
    [sch_cleared]="🗑 Tüm zamanlamalar silindi"
    [sch_cancel_usage]="Kullanım: /schedule cancel <idx>"
    [sch_cancelled_fmt]="✓ Silindi: %s"
    [sch_invalid_usage]="Kullanım: /schedule <saniye> <komut>"
    [sch_no_cmd]="❌ Komut eksik"
    [sch_min_secs]="❌ En az 10 saniye"
    [sch_added_fmt]="🔁 Zamanlandı: her %d saniyede '%s'
İlki %d saniye sonra"
    [sch_fire_fmt]="🔁 Schedule [%s]
%s"
    [sch_unsupported_fmt]="(unsupported in schedule: %s)"

    # ─── /speedtest ──────────────────────────────────────────────────
    [st_usage]="Kullanım: /speedtest [PROVIDER] [SIZE] [loop [COUNT]]

PROVIDER:
  (boş)|cf      Cloudflare endpoint (single-stream, hızlı default)
  ookla         Ookla Speedtest CLI (multi-stream, en doğru)
  fast          fast.com (Netflix CDN)

SIZE (sadece cf modda):
  quick         10 MB DL
  <mb>          5-200 MB DL
  full          50 MB DL + 25 MB UL
  (boş)         50 MB DL

LOOP:
  loop          Sonsuz döngü — her sonuç mesaj olarak gelir
  loop N        N kere çalıştır
  Durdurmak için: /iptal

Örnekler:
  /speedtest ookla
  /speedtest cf 100 loop 5
  /speedtest fast loop
  /speedtest loop 3"
    [st_cf_starting_fmt]="🚀 Cloudflare speedtest başlıyor (%d MB DL%s)…"
    [st_cf_starting_upload]=" + 25 MB UL"
    [st_cf_download_failed]="❌ Download başarısız (curl error)"
    [st_cf_upload_failed]="
⬆ Upload:    başarısız"
    [st_cf_upload_fmt]="
⬆ Upload:    %s Mbit/s (%s MB / %ss)"
    [st_cf_result_fmt]="📊 Cloudflare Speedtest

⬇ Download:  %s Mbit/s (%s MB / %ss)%s
🏓 Latency:   %s ms (TCP connect)
🖥 CPU:        %s
🌡 Sıcaklık:  %s

Sunucu: speed.cloudflare.com (single-stream)
Multi-stream test: /speedtest ookla"
    [st_ookla_downloading]="📥 İlk çalıştırma: Ookla CLI indiriliyor (~1.5 MB, ~5s)…"
    [st_ookla_download_failed]="❌ Ookla binary indirilemedi (network?)"
    [st_ookla_extract_failed]="❌ Ookla tar çıkartma başarısız"
    [st_ookla_starting]="🚀 Ookla Speedtest başlıyor (multi-stream, en yakın sunucu)…"
    [st_ookla_failed_fmt]="❌ Ookla başarısız:
%s"
    [st_ookla_result_fmt]="📊 Ookla Speedtest

⬇ Download:  %s Mbit/s
⬆ Upload:    %s Mbit/s
🏓 Ping:      %s ms (jitter %s ms)
🖥 Sunucu:    %s (%s)
🌐 ISP:       %s
🔌 Interface: %s  ext_ip=%s%s
🌡 Sıcaklık:  %s

Multi-stream — endüstri standardı, en doğru."
    [st_fast_starting]="🚀 fast.com (Netflix CDN) speedtest başlıyor…"
    [st_fast_api_failed_fmt]="❌ fast.com API başarısız:
%s"
    [st_fast_download_failed]="❌ fast.com download başarısız"
    [st_fast_result_fmt]="📊 fast.com Speedtest

⬇ Download:  %s Mbit/s
   (%s MB / %ss, %d stream)
🖥 Sunucu:    %s
🌡 Sıcaklık:  %s

Netflix CDN endpoint — Netflix kullanıcısı bias'lı ama gerçek hızı yansıtır."

    # ─── /minimal_mode ───────────────────────────────────────────────
    [mm_status_fmt]="📦 Minimal Mode

RAM kullanılabilir: %d MB
Disabled paketler: %d
Çalışan com.* süreçler: %d

Komutlar:
  /minimal_mode on       — Allowlist hariç HER ŞEYİ force-stop'la
                            (cellular/SMS/root/VPN/bot dokunulmaz)
                            Reboot resetler. Brick riski: yok.
                            ⚠ /performance geçici kullanılamaz
  /minimal_mode persist  — on + SystemUI/Launcher/zte.web kalıcı disable
                            ~640 MB kazanç. Reboot'ta korunur.
                            /minimal_mode off ile geri açılır.
  /minimal_mode off      — Disable'ları enable'a çevir (reboot tavsiye)
  /minimal_mode list     — Şu an allowlist'te tutulanlar
  /minimal_mode preview  — 'on' denese ne öldürür (test etmeden)"
    [mm_allowlist]="🛡 Allowlist (bunlar KALIR, hepsi gerekli):

Android core:
  android, system_server, zygote, kernel threads
Cellular/SMS:
  com.android.phone, com.android.subsys, com.android.smspush,
  com.android.se, com.android.providers.telephony,
  com.android.cellbroadcast*, com.android.networkstack*,
  com.android.NetworkStatsServer
  com.spreadtrum.*, com.sprd.*  (radio/IMS)
Storage/permissions:
  com.android.providers.media*, com.android.providers.settings,
  com.android.providers.contacts, com.android.permissioncontroller,
  com.android.shell, com.android.captiveportallogin,
  com.android.location.fused
Magisk:
  com.topjohnwu.magisk*
Thermal:
  com.zte.thermalbridge, com.zte.telephony.api
VPN:
  com.v2ray.*, com.wireguard.*, com.openvpn.*, com.protonvpn.*
[Bot kendisi root süreci, paket değil — etkilenmez]"
    [mm_preview_fmt]="👁 Preview: 'on' çalıştırılsa
  Allowlist'te tutulur: %d paket
  force-stop hedefi:    %d paket
(çoğu zaten çalışmıyor olabilir, no-op)"
    [mm_transient_done_fmt]="💨 Transient kill
%d paket force-stop edildi (%d allowlist'te tutuldu)
RAM: %d MB → %d MB (kazanç %d MB)

⚠ Şu komutlar geçici çalışmaz: /performance (com.zte.web kapandı)
✓ Reboot'ta her şey clean state'e döner — brick riski yok
Daha kalıcı: /minimal_mode persist"
    [mm_persist_done_fmt]="🧊 Persist mode aktif
Force-stop: %d paket
Disable-user: %d paket (SystemUI/Launcher/zte.web)
RAM: %d MB → %d MB (kazanç %d MB)

⚠ /performance kullanılamaz (com.zte.web disabled)
⚠ Web UI (192.168.0.1:8080) gelmez
✓ Reboot'tan sonra da kapalı kalır
✓ Geri açmak: /minimal_mode off (sonra reboot tavsiye)"
    [mm_off_done_fmt]="✅ Minimal Mode kapatıldı
%d tracked paket geri enable edildi (sadece bizim disable ettiklerimiz).
Force-stop edilenler gerektiğinde Android tarafından başlatılır.
Tam temiz state için: cihazı reboot et."
    [mm_disabled_none]="📋 Hiç tracked-disable paket yok"
    [mm_disabled_header]="📋 Bot tarafından disable edilen paketler:"
    [mm_disabled_state_disabled]="❄ disabled"
    [mm_disabled_state_mismatch]="? mismatch (already enabled)"
    [mm_disabled_footer]="Tek tek aç: /minimal_mode enable <pkg>
Hepsini aç: /minimal_mode off"
    [mm_enable_usage]="Kullanım: /minimal_mode enable <pkg>
Mevcut tracked liste: /minimal_mode disabled"
    [mm_enable_not_tracked_fmt]="❌ '%s' tracked listesinde yok.
Yine de zorla enable: pm enable %s  (shell)"
    [mm_enable_success_fmt]="✅ %s geri açıldı (tracked listeden çıkarıldı)"
    [mm_enable_failed_fmt]="❌ Başarısız: %s"
    [mm_disable_usage]="Kullanım: /minimal_mode disable <pkg>"
    [mm_disable_essential_fmt]="❌ '%s' essentials listesinde (cellular/SMS/root/VPN).
Bu paketi disable etmek sistemi kırabilir. İstersen:
  pm disable-user --user 0 %s  (shell — sorumluluk sana ait)"
    [mm_disable_success_fmt]="❄ %s disable edildi + tracked
Geri açmak: /minimal_mode enable %s"
    [mm_disable_failed_fmt]="❌ Başarısız: %s"
    [mm_usage]="Kullanım: /minimal_mode <subcommand>

Toplu işlemler:
  on / kill      — Allowlist hariç hepsi force-stop (transient)
  persist        — on + SystemUI/Launcher/zte.web disable (tracked)
  off / restore  — Bizim disable ettiklerimizi geri aç

Sorgulama:
  status         — Genel durum
  preview        — 'on' kaç paketi öldürür (test etmeden)
  list / keep    — Allowlist
  disabled       — Tracked liste (bot'un kapadığı paketler)

Tekil:
  disable <pkg>  — Bir paketi disable et + tracked
  enable <pkg>   — Tracked listeden bir paketi aç"

    # ─── /perf_balanced ──────────────────────────────────────────────
    [pb_header]="⚖️ Perf Balanced — mevcut cap'ler:"
    [pb_policy_fmt]="  %s: cap=%d MHz  (hw_max=%d MHz)\n"
    [pb_hint_on]="Performance hint: AÇIK 🟢 → big cluster wakeable"
    [pb_hint_off]="Performance hint: KAPALI ⚪ → big cluster offline kilitli
   /perf_balanced'ın etkili olması için: /performance on + reboot"
    [pb_hint_unread]="Performance hint: ? (okunamadı)"
    [pb_usage]="Uygulamak: /perf_balanced [mhz]   (default 1800)
Sıfırlamak: /perf_balanced reset"
    [pb_reset_fmt]="✅ %d policy cap'i sıfırlandı (hw max'a açıldı).
Performance hint'i değiştirilmedi."
    [pb_invalid_mhz_fmt]="❌ Geçersiz mhz: %s
Kullanım: /perf_balanced [mhz|reset]"
    [pb_too_low]="❌ En az 500 MHz"
    [pb_too_high]="❌ En çok 3000 MHz"
    [pb_no_clusters]="❌ Hiçbir cluster'a uygulanamadı"
    [pb_warn_hint_off]="

⚠ Performance hint KAPALI — big cluster boot'tan beri offline.
  Tam fayda için: /performance on → cihazı reboot et → sonra bu komutu tekrar çalıştır."
    [pb_applied_fmt]="⚖️ Perf Balanced uygulandı (%d cluster):%s
%s

Reboot'ta cap sıfırlanır (sysfs RAM-only — risk yok)."

    # ─── /update ──────────────────────────────────────────────────────
    [update_header]="🔍 Modül güncelleme kontrolü"
    [update_remote_unread_fmt]="  %s: %s  ⚠ remote okunamadı"
    [update_parse_fail_fmt]="  %s: %s  ⚠ JSON parse hatası"
    [update_outdated_fmt]="  📦 %s: %s → %s (vCode %d→%d) ⬆"
    [update_uptodate_fmt]="  ✓ %s: %s (güncel)"
    [update_none_defined]="Hiçbir modülde updateJson tanımlı değil."
    [update_all_current]="Tüm modüller güncel."
    [update_count_outdated_fmt]="%d modül güncellenebilir.
Hepsini güncelle: /update all
Tek tek: /update <module-id>"
    [update_all_start]="📥 Tüm güncelleme kontrolü + install başlatılıyor…"
    [update_no_zipurl_fmt]="  %s: zipUrl yok, atlandı"
    [update_downloading_fmt]="  ⬇ %s %s indiriliyor…"
    [update_installed_fmt]="  ✅ %s → %s"
    [update_install_failed_fmt]="  ❌ %s install başarısız"
    [update_download_failed_fmt]="  ❌ %s download başarısız"
    [update_summary_fmt]="📊 Özet: %d kontrol edildi, %d güncellendi, %d başarısız"
    [update_reboot_hint]="
Binary'ler değişti ise tam etki için reboot tavsiye edilir.
statusbot kendisi güncellendiyse 10 sn içinde restart (supervisor)."
    [update_module_not_found_fmt]="❌ Modül bulunamadı: %s
Liste için: /update"
    [update_no_updatejson_fmt]="❌ %s için updateJson tanımlı değil"
    [update_remote_unread_long_fmt]="❌ Remote okunamadı: %s"
    [update_already_current_fmt]="✓ %s zaten güncel (%s)"
    [update_download_failed]="❌ Download başarısız"
    [update_self_installed_fmt]="✅ statusbot %s kuruldu, bot 5 sn içinde restart…"
    [update_other_installed_fmt]="✅ %s %s kuruldu
Binary değiştiyse reboot tavsiye edilir."
    [update_install_failed_long_fmt]="❌ Install başarısız:
%s"

    # ─── /tailscale ───────────────────────────────────────────────────
    [ts_binary_missing]="❌ tailscale binary'leri bulunamadı.
Aranan yerler:
  /system/bin/{tailscale,tailscaled}
  /data/adb/modules/tailscale-control/system/bin/
  /data/adb/modules_update/tailscale-control/system/bin/
tailscale-control modülünü kur."
    [ts_status_on_fmt]="Tailscale: 🟢 AÇIK
PID: %s  (RSS: %d MB)
IP:  %s
%s

Diğer komutlar: /tailscale {on|off|auth|ip|peers|logout|log}"
    [ts_ip_pending]="(login bekleniyor)"
    [ts_status_off_fmt]="Tailscale: 🔴 KAPALI
%s"
    [ts_hint_on]="Açmak için: /tailscale on"
    [ts_hint_auth_first]="Önce: /tailscale auth <key>   sonra: /tailscale on"
    [ts_already_running]="Zaten çalışıyor. /tailscale status"
    [ts_daemon_failed_fmt]="❌ tailscaled başlamadı. Son log:
%s"
    [ts_active_fmt]="✅ Tailscale aktif
IP: %s
Exit-node: advertised (admin panelden onayla)
Routing: adaptive (default route'u takip eder)"
    [ts_login_required_fmt]="🔑 Login gerekli:
%s

Tarayıcıdan aç, onaylayınca otomatik bağlanır."
    [ts_up_response_fmt]="⚠️ Up cevabı:
%s"
    [ts_already_off]="Zaten kapalı (orphan iptables temizlendi)"
    [ts_stopped]="🔴 Tailscale kapatıldı
iptables kuralları silindi
(VPN'e dokunulmadı)"
    [ts_auth_usage]="Kullanım: /tailscale auth <tsauth-key>
Tailscale admin > Settings > Keys > Generate
Önerilen: reusable + ephemeral"
    [ts_auth_saved_fmt]="🔑 Auth key kaydedildi (%d byte).
Şimdi: /tailscale on"
    [ts_logout_done]="👋 Logout
State + authkey silindi"
    [ts_off_short]="Tailscale kapalı"
    [ts_log_none]="Log yok"
    [ts_log_header]="📝 tailscaled son 20 satır:"
    [ts_usage]="Kullanım: /tailscale [on|off|status|auth|ip|peers|logout|log]"

    # ─── /performance ─────────────────────────────────────────────────
    [perf_status_on]="⚡ Performance Modu: AÇIK 🟢
Kapatmak: /performance off"
    [perf_status_off]="⚡ Performance Modu: KAPALI ⚪
Açmak: /performance on"
    [perf_status_unread_fmt]="⚠️ Durum okunamadı: %s"
    [perf_no_password]="❌ ZTE şifresi tanımlı değil. Önce: /zte_setpw <şifre>"
    [perf_login_failed]="❌ ZTE login başarısız. Şifre yanlış olabilir, /zte_setpw ile güncelle."
    [perf_login_failed_short]="❌ ZTE login başarısız."
    [perf_set_failed_fmt]="❌ Set başarısız: %s"
    [perf_enabled_reboot]="⚡ Performance Modu AÇILDI 🟢
Değişikliğin geçerli olması için cihazı yeniden başlat."
    [perf_disabled_reboot]="⚡ Performance Modu KAPATILDI ⚪
Değişikliğin geçerli olması için cihazı yeniden başlat."
    [perf_usage]="Kullanım: /performance [on|off|status]"

    # ─── /zte_setpw ──────────────────────────────────────────────────
    [zte_pw_set_fmt]="ZTE şifresi tanımlı (uzunluk: %d byte).
Değiştirmek için: /zte_setpw <yeni_şifre>"
    [zte_pw_usage]="Kullanım: /zte_setpw <şifre>
(ZTE web admin şifresi — /performance vs için)"
    [zte_pw_saved_fmt]="✓ ZTE şifresi kaydedildi (%d byte).
Test: /performance"

    # ─── /iptal ──────────────────────────────────────────────────────
    [iptal_imei]="  ✓ IMEI sorgusu"
    [iptal_upload]="  ✓ Bekleyen upload"
    [iptal_speedtest]="  ✓ Speedtest loop"
    [iptal_none]="Beklemede iptal edilecek bir şey yok"
    [iptal_done_fmt]="🛑 İptal edildi:%s"

    # ─── /reboot ─────────────────────────────────────────────────────
    [reboot_starting]="🔁 Reboot başlatılıyor…"
    [reboot_expired]="⚠️ Süre doldu. Önce /reboot komutu ver."
    [reboot_confirm]="⚠️ Onayla: 60sn içinde \"/reboot YES\" yaz."

    # ─── /version ────────────────────────────────────────────────────
    [version_fmt]="🤖 Bot %s
📱 %s
🏷  %s
🤖 Android %s (SDK %s)
🐧 %s"

    # ─── /status ─────────────────────────────────────────────────────
    [status_model_fmt]="📱 %s\n"
    [status_uptime_fmt]="⏱  Uptime: %s\n"
    [status_ram_fmt]="💾 RAM: %s\n"
    [status_disk_fmt]="💿 Disk: %s\n"
    [status_temp_fmt]="🌡  Sıcaklık: %s\n"
    [status_perf_on]="⚡ Performance: AÇIK 🟢\n"
    [status_perf_off]="⚡ Performance: KAPALI ⚪\n"
    [status_operator_fmt]="📡 Operatör: %s\n"
    [status_signal_fmt]="📶 Sinyal: RSSI %s (%s)\n"
    [status_public_ip_fmt]="🌐 Public IP: %s"

    # ─── /perf_help ──────────────────────────────────────────────────
    [perf_help_full]="⚡ CPU/Performance Kullanım Kılavuzu

Cihaz octa-core (UMS9620): 4× A55 (little) + 3× A76 (mid) + 1× A76 (big).
ZTE pil ömrü için boot'ta sadece little cluster'ı (cpu0-3) açıyor — büyük
cluster (cpu4-7) \"only_use_little_core\" hint'iyle offline kilitleniyor.

4 MOD KARŞILAŞTIRMASI

A) Default (hiçbir şey yapma)
   Aktif: cpu0-3 (4 core), schedutil
   Throughput: ~35 Mbit/s   Sıcaklık: 55-65°C
   ✗ Network bottleneck — CPU tek thread fast-path'i doyuruyor

B) /performance on  (+ reboot)
   Aktif: cpu0-7 (8 core), schedutil up to 2.7 GHz
   Throughput: ~550 Mbit/s  Sıcaklık: 85-90°C 🔥
   ✓ En yüksek hız  ✗ Aşırı ısınma, pil hızla biter

C) /cpu_governor powersave (tüm core'lar min freq)
   Yavaş, tek-thread iş için kullanılmaz
   ✗ Genelde önerilmez

D) /perf_balanced 1800  (ÖNERİLEN)
   Aktif: cpu0-7 (8 core), policy4/7 cap'li @ 1.8 GHz
   Throughput tahmini: ~400 Mbit/s   Sıcaklık: 70-75°C
   ✓ Throughput 10x↑   ✓ Güvenli sıcaklık   ✓ Pil makul

ÖNERİLEN AKIŞ

  1) /zte_setpw <şifre>            (ilk kurulum, 1 kez)
  2) /performance on               (only_use_little_core hint'ini kaldırır)
  3) Cihazı reboot et              (hint config flash'ından okunur)
  4) /perf_balanced 1800           (1.8 GHz cap uygula)

  Test:
    /temp        — sıcaklık
    /cpu_freq    — aktif frekanslar
    /cpu_governor — hangi cluster online + governor

  Geri almak için:
    /perf_balanced reset           (cap'leri kaldır — full freq'e döner)
    /performance off               (only_use_little_core'a geri dön, reboot)

DİKKAT
  • /perf_balanced cap'i reboot'ta sıfırlanır (sysfs RAM-only).
    Kalıcı istersen her boot'ta tekrar çalıştır.
  • /performance ZTE config flash'ında kalıcı.
  • Sıcaklık trip point 100°C — yine de 80°C üstüne çıkmaması iyi olur.
  • VPN kullanıyorsan WireGuard kernel-mode etkilenmez, OpenVPN userspace
    1.8 GHz cap'inde de hızlı olmalı.

FARKLI MHZ DEĞERLERİ

  1500 MHz cap → daha serin, ~300 Mbit
  1800 MHz cap → balanced (önerilen), ~400 Mbit
  2000 MHz cap → daha hızlı, ~450 Mbit, ~80°C
  2200 MHz cap → near-full, ~500 Mbit, 80-85°C
  reset       → hw_max (2.3 / 2.7 GHz), ~550 Mbit, 85-90°C"
)
