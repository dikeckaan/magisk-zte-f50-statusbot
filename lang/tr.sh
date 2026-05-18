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
