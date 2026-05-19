# statusbot Français — community translation seeded by upstream
# Sourced AFTER en.sh; keys here override English. Missing keys fall back.

declare -gA MSG=(
    [lang_current_fmt]="Langue actuelle : %s"
    [lang_available_header]="Langues disponibles :"
    [lang_set_fmt]="Langue changée en %s. Le bot redémarrera dans 3 s."
    [lang_invalid_fmt]="Code de langue inconnu : %s. Voir /lang pour la liste."
    [lang_usage]="Usage : /lang [code]
Sans argument : langue actuelle + disponibles.
Avec un code : change et redémarre le bot."

    [greet_morning]="Bonjour"
    [greet_noon]="Bon après-midi"
    [greet_evening]="Bonsoir"
    [greet_night]="Bonne nuit"
    [boot_greeting_fmt]="%s, je suis en ligne 🤖
%s — uptime : %s
Tapez /help pour les commandes."

    [help_full_fmt]="Bot ZTE F50 — Commandes

📊 Statut
/status — vue d'ensemble complète
/uptime — temps de fonctionnement
/load — charge CPU (détaillée)
/mem — RAM
/disk — disque
/temp — température (CPU)
/ps — top 10 processus (CPU)

📡 Cellulaire
/signal — qualité du signal (RSSI, RSRP, RSRQ)
/cellinfo — opérateur + IMEI + ICCID + numéro
/imei — IMEI(s)
/imei_sorgula [imei] — analyse IMEI + recherche e-Devlet
/imei_degis <imei> — changer IMEI (confirmé, redémarrage)
/operator — opérateur seulement
/qos — détails QoS / bande
/sms_list [N] — derniers N SMS (défaut 10)
/sms_count — total boîte de réception
/sms_send <num> <texte> — envoyer SMS via AT
/at <cmd> — commande AT brute

🌐 Réseau
/ip — IPs publiques + locales
/traffic — RX/TX depuis démarrage
/ping <host>
/speedtest [cf|ookla|fast] [size] — test de vitesse
/clients — clients connectés (ARP)
/wifi — hotspot SSID + mot de passe + clients
/tunnel — état Cloudflared

🔧 Système
/modules — modules Magisk
/version
/reboot — redémarrer (confirmation)
/komut <cmd> — commande shell (annulable)
/file <chemin> — télécharger fichier depuis l'appareil
/upload <cible> — envoyer fichier à l'appareil
/screenshot — capture d'écran
/ramclean [pkg…] — nettoyage mémoire
/performance [on|off] — Mode Performance ZTE (redémarrage requis)
/perf_balanced [mhz] — 8-cœurs + cap fréquence (recommandé, 1800)
/perf_help — guide comparatif
/minimal_mode [on|persist|off] — geler les services (~640 MB)
/zte_setpw <pwd> — définir mot de passe admin ZTE
/lang [code] — changer la langue du bot

🗂 Système de fichiers
/ls <chemin>
/cat <fichier> — contenu (4 KB)
/df — utilisation disque
/du <dir> — tailles sous-répertoires
/log [N] — N dernières lignes log
/dump_sms — dump complet inbox SMS

🌐 Réseau (extras)
/connections — TCP établies
/listening — ports en écoute
/dhcp — table DHCP
/dns — configuration DNS

⚡ Énergie / Noyau
/cpu_freq — fréquences CPU
/cpu_governor [name] — voir/changer governor
/wakelock — wakelocks actifs

📦 Applications
/installed [3rd|disabled|system|all]
/freeze <pkg> — geler paquet
/unfreeze <pkg> — dégeler paquet

⏰ Planification
/alarm HH:MM <msg> — unique
/schedule <sec> <cmd> — récurrent
/schedule list / clear / cancel <idx>
/heartbeat <heures> — ping périodique
/quiet_hours <de> <à> — heures silencieuses

🔒 Sécurité
/who — sessions SSH/ADB actives
/last_boot — historique de démarrage
/bot_stats — stats internes
/restart_bot — redémarrer le bot
/update [all|<id>] — MAJ modules depuis GitHub

🌍 Tailscale (module optionnel)
/tailscale auth <key> — sauvegarder auth-key
/tailscale on / off — démarrer/arrêter
/tailscale status — état + RAM
/tailscale ip / peers / log / logout

🔔 Automatique (arrière-plan) :
• SMS entrants transférés
• Alertes si temp > %d°C, RAM < %d%%, tunnel down
• Heartbeat (si configuré) et planifications
• Heures silencieuses suppriment les alertes

💬 Déclencheurs chat
selam, merhaba, sa — salutation
naber — statut + salutation
saat — heure de l'appareil
iyi misin — vérification de statut"

    [uptime_days_fmt]="%d j %02d h %02d m"
    [uptime_hours_fmt]="%d h %02d m"
    [uptime_short_fmt]="%d m %02d s"
    [disk_fmt]="%s / %s (%s utilisé)"

    [load_status_calm]="🟢 calme (%d%%)"
    [load_status_active]="🟡 actif (%d%%)"
    [load_status_full]="🟠 plein (%d%%)"
    [load_status_busy]="🔴 occupé (%d%%)"
    [load_full_fmt]="📊 Charge CPU (%d cœurs)

Maintenant (1 min) : %s
5 dernières min :   %s
15 dernières min :  %s

Statut : %s

Guide :
  %d.0 = toutes les CPU au max
  < %d.0 = capacité disponible
  > %d.0 = file d'attente, lenteur possible"

    [status_model_fmt]="📱 %s\n"
    [status_uptime_fmt]="⏱  Uptime : %s\n"
    [status_ram_fmt]="💾 RAM : %s\n"
    [status_disk_fmt]="💿 Disque : %s\n"
    [status_temp_fmt]="🌡  Température : %s\n"
    [status_perf_on]="⚡ Performance : ON 🟢\n"
    [status_perf_off]="⚡ Performance : OFF ⚪\n"
    [status_operator_fmt]="📡 Opérateur : %s\n"
    [status_signal_fmt]="📶 Signal : RSSI %s (%s)\n"
    [status_public_ip_fmt]="🌐 IP publique : %s"

    [perf_status_on]="⚡ Mode Performance : ACTIVÉ 🟢
Pour désactiver : /performance off"
    [perf_status_off]="⚡ Mode Performance : DÉSACTIVÉ ⚪
Pour activer : /performance on"
    [perf_no_password]="❌ Mot de passe ZTE non défini. D'abord : /zte_setpw <pwd>"
    [perf_login_failed]="❌ Échec de connexion ZTE. Mauvais mot de passe ? Mettez à jour avec /zte_setpw."
    [perf_login_failed_short]="❌ Échec de connexion ZTE."
    [perf_set_failed_fmt]="❌ Échec : %s"
    [perf_enabled_reboot]="⚡ Mode Performance ACTIVÉ 🟢
Redémarrez l'appareil pour appliquer."
    [perf_disabled_reboot]="⚡ Mode Performance DÉSACTIVÉ ⚪
Redémarrez l'appareil pour appliquer."
    [perf_usage]="Usage : /performance [on|off|status]"

    [zte_pw_set_fmt]="Mot de passe ZTE défini (longueur : %d octets).
Pour changer : /zte_setpw <nouveau_pwd>"
    [zte_pw_usage]="Usage : /zte_setpw <pwd>
(Mot de passe admin web ZTE — pour /performance etc.)"
    [zte_pw_saved_fmt]="✓ Mot de passe ZTE sauvegardé (%d octets).
Tester : /performance"
    [iptal_imei]="  ✓ Requête IMEI"
    [iptal_upload]="  ✓ Upload en attente"
    [iptal_speedtest]="  ✓ Boucle de speedtest"
    [iptal_none]="Rien à annuler"
    [iptal_done_fmt]="🛑 Annulé :%s"
    [reboot_starting]="🔁 Redémarrage en cours…"
    [reboot_expired]="⚠️ Expiré. Exécutez /reboot à nouveau."
    [reboot_confirm]="⚠️ Confirmez : tapez \"/reboot YES\" dans les 60 s."
    [version_fmt]="🤖 Bot %s
📱 %s
🏷  %s
🤖 Android %s (SDK %s)
🐧 %s"

    [common_not_exists_fmt]="❌ N'existe pas : %s"
    [btn_cancel]="❌ Annuler"
    [btn_reboot_now]="🔁 Redémarrer Maintenant"

    [csq_excellent]="🟢 Excellent"
    [csq_good]="🟢 Bon"
    [csq_moderate]="🟡 Modéré"
    [csq_weak]="🟠 Faible"
    [csq_very_weak]="🔴 Très faible"
    [csq_unknown]="🔴 Inconnu"

    [alert_temp_fmt]="🌡 ALERTE : température CPU élevée — %d°C
(Seuil %d°C, pas de ré-alerte pendant %d s)"
    [alert_mem_fmt]="💾 ALERTE : RAM très faible — %d%% disponible
(%d MB)"
    [alert_tunnel]="🔌 ALERTE : le tunnel Cloudflared ne tourne pas (pas de processus)"
    [alert_sms_forward_fmt]="📨 SMS entrant — %s
👤 %s

%s"

    [chat_greeting_fmt]="%s, me voici 👋"
    [chat_naber_fmt]="%s ! Mon statut :

%s"
    [chat_time_fmt]="🕐 %s"
    [chat_imisin_fmt]="Je vais bien 🙂 (temp %s, uptime %s)"
    [chat_thanks]="🤖 De rien 👍"
    [chat_morning_fmt]="Bonjour ! ☀️ %s depuis le démarrage"
    [chat_night]="À toi aussi 🌙 je reste éveillé"

    [update_header]="🔍 Vérification des mises à jour des modules"
    [update_all_current]="Tous les modules sont à jour."
    [update_none_defined]="Aucun module n'a updateJson défini."
)
