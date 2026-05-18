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
)
