# statusbot Español — community translation seeded by upstream
# Sourced AFTER en.sh; keys here override English. Missing keys fall back.

declare -gA MSG=(
    # ─── /lang ────────────────────────────────────────────────────────
    [lang_current_fmt]="Idioma actual: %s"
    [lang_available_header]="Idiomas disponibles:"
    [lang_set_fmt]="Idioma cambiado a %s. El bot se reiniciará en 3 s."
    [lang_invalid_fmt]="Código de idioma desconocido: %s. Ver /lang para la lista."
    [lang_usage]="Uso: /lang [código]
Sin argumento muestra el idioma actual + disponibles.
Con un código cambia y reinicia el bot."

    # ─── greetings ────────────────────────────────────────────────────
    [greet_morning]="Buenos días"
    [greet_noon]="Buenas tardes"
    [greet_evening]="Buenas tardes"
    [greet_night]="Buenas noches"
    [boot_greeting_fmt]="%s, estoy en línea 🤖
%s — uptime: %s
Escribe /help para los comandos."

    # ─── /help ────────────────────────────────────────────────────────
    [help_full_fmt]="Bot ZTE F50 — Comandos

📊 Estado
/status — resumen completo
/uptime — tiempo de actividad
/load — carga de CPU (detallada)
/mem — RAM
/disk — Disco
/temp — Temperatura (CPU)
/ps — Top 10 procesos (CPU)

📡 Celular
/signal — calidad de señal (RSSI, RSRP, RSRQ)
/cellinfo — operador + IMEI + ICCID + número
/imei — IMEI(s)
/imei_sorgula [imei] — análisis IMEI + consulta e-Devlet
/imei_degis <imei> — cambiar IMEI (confirmado, reinicia)
/operator — solo operador
/qos — detalles QoS / banda
/sms_list [N] — últimos N SMS (por defecto 10)
/sms_count — total inbox
/sms_send <num> <texto> — enviar SMS por AT
/at <cmd> — comando AT crudo

🌐 Red
/ip — IPs públicas + locales
/traffic — RX/TX desde el arranque
/ping <host>
/speedtest [cf|ookla|fast] [size] — test de velocidad
/clients — clientes conectados (ARP)
/wifi — hotspot SSID + contraseña + clientes
/tunnel — estado Cloudflared

🔧 Sistema
/modules — módulos Magisk
/version
/reboot — reiniciar (confirmación)
/komut <cmd> — comando shell (cancelable)
/file <ruta> — descargar archivo del dispositivo
/upload <destino> — subir archivo al dispositivo
/screenshot — captura de pantalla
/ramclean [pkg…] — limpieza de memoria
/performance [on|off] — Modo Performance ZTE (necesita reinicio)
/perf_balanced [mhz] — 8-core + cap de frecuencia (recomendado, 1800)
/perf_help — guía de comparación
/minimal_mode [on|persist|off] — congelar servicios (~640 MB)
/zte_setpw <pwd> — establecer contraseña admin ZTE
/lang [code] — cambiar idioma del bot

🗂 Sistema de archivos
/ls <ruta> — listado de directorio
/cat <archivo> — contenido (4 KB)
/df — uso de disco
/du <dir> — tamaños de subdirectorios
/log [N] — últimas N líneas del log
/dump_sms — volcado completo del inbox SMS

🌐 Red (extras)
/connections — TCP establecidas
/listening — puertos en escucha
/dhcp — tabla DHCP
/dns — configuración DNS

⚡ Energía / Kernel
/cpu_freq — frecuencias CPU
/cpu_governor [name] — ver/cambiar governor
/wakelock — wakelocks activos

📦 Aplicaciones
/installed [3rd|disabled|system|all]
/freeze <pkg> — congelar paquete
/unfreeze <pkg> — descongelar paquete

⏰ Programación
/alarm HH:MM <msg> — una vez
/schedule <sec> <cmd> — recurrente
/schedule list / clear / cancel <idx>
/heartbeat <horas> — ping periódico
/quiet_hours <de> <a> — silenciar alarmas

🔒 Seguridad / auditoría
/who — sesiones SSH/ADB activas
/last_boot — historial de arranque
/bot_stats — estadísticas internas
/restart_bot — reiniciar el bot
/update [all|<id>] — actualizar módulos desde GitHub

🌍 Tailscale (módulo opcional)
/tailscale auth <key> — guardar clave auth
/tailscale on / off — iniciar/detener
/tailscale status — estado + RAM
/tailscale ip / peers / log / logout

🔔 Automático (en segundo plano):
• SMS entrante reenviado a ti
• Alertas cuando temp > %d°C, RAM < %d%%, túnel caído
• Heartbeat (si configurado) y schedules
• Quiet hours silencia alertas

💬 Disparadores chat
selam, merhaba, sa — saludo
naber — estado + saludo
saat — hora del dispositivo
iyi misin — comprobación de estado"

    # ─── fmt_uptime ──────────────────────────────────────────────────
    [uptime_days_fmt]="%d d %02d h %02d m"
    [uptime_hours_fmt]="%d h %02d m"
    [uptime_short_fmt]="%d m %02d s"
    [disk_fmt]="%s / %s (%s usado)"

    # ─── fmt_load ────────────────────────────────────────────────────
    [load_status_calm]="🟢 tranquilo (%d%%)"
    [load_status_active]="🟡 activo (%d%%)"
    [load_status_full]="🟠 lleno (%d%%)"
    [load_status_busy]="🔴 ocupado (%d%%)"
    [load_full_fmt]="📊 Carga de CPU (%d núcleos)

Ahora (1 min):     %s
Últimos 5 min:     %s
Últimos 15 min:    %s

Estado: %s

Guía:
  %d.0 = todas las CPU al máximo
  < %d.0 = capacidad disponible
  > %d.0 = cola, posible lentitud"

    # ─── /status ─────────────────────────────────────────────────────
    [status_model_fmt]="📱 %s\n"
    [status_uptime_fmt]="⏱  Uptime: %s\n"
    [status_ram_fmt]="💾 RAM: %s\n"
    [status_disk_fmt]="💿 Disco: %s\n"
    [status_temp_fmt]="🌡  Temperatura: %s\n"
    [status_perf_on]="⚡ Performance: ON 🟢\n"
    [status_perf_off]="⚡ Performance: OFF ⚪\n"
    [status_operator_fmt]="📡 Operador: %s\n"
    [status_signal_fmt]="📶 Señal: RSSI %s (%s)\n"
    [status_public_ip_fmt]="🌐 IP Pública: %s"

    # ─── /performance ─────────────────────────────────────────────────
    [perf_status_on]="⚡ Modo Performance: ENCENDIDO 🟢
Para apagar: /performance off"
    [perf_status_off]="⚡ Modo Performance: APAGADO ⚪
Para encender: /performance on"
    [perf_status_unread_fmt]="⚠️ No se pudo leer el estado: %s"
    [perf_no_password]="❌ Contraseña ZTE no definida. Primero: /zte_setpw <pwd>"
    [perf_login_failed]="❌ Login ZTE fallido. ¿Contraseña incorrecta? Actualiza con /zte_setpw."
    [perf_login_failed_short]="❌ Login ZTE fallido."
    [perf_set_failed_fmt]="❌ Set fallido: %s"
    [perf_enabled_reboot]="⚡ Modo Performance ACTIVADO 🟢
Reinicia el dispositivo para aplicar el cambio."
    [perf_disabled_reboot]="⚡ Modo Performance DESACTIVADO ⚪
Reinicia el dispositivo para aplicar el cambio."
    [perf_usage]="Uso: /performance [on|off|status]"

    # ─── /zte_setpw / /iptal / /reboot / /version ────────────────────
    [zte_pw_set_fmt]="Contraseña ZTE definida (longitud: %d bytes).
Para cambiar: /zte_setpw <nueva_pwd>"
    [zte_pw_usage]="Uso: /zte_setpw <pwd>
(Contraseña del panel admin web ZTE — para /performance y similares)"
    [zte_pw_saved_fmt]="✓ Contraseña ZTE guardada (%d bytes).
Probar: /performance"
    [iptal_imei]="  ✓ Consulta IMEI"
    [iptal_upload]="  ✓ Upload pendiente"
    [iptal_speedtest]="  ✓ Loop de speedtest"
    [iptal_none]="Nada pendiente que cancelar"
    [iptal_done_fmt]="🛑 Cancelado:%s"
    [reboot_starting]="🔁 Reinicio iniciado…"
    [reboot_expired]="⚠️ Tiempo agotado. Primero ejecuta /reboot de nuevo."
    [reboot_confirm]="⚠️ Confirma: escribe \"/reboot YES\" dentro de 60 s."
    [version_fmt]="🤖 Bot %s
📱 %s
🏷  %s
🤖 Android %s (SDK %s)
🐧 %s"

    # Generic short strings used by many commands
    [common_not_exists_fmt]="❌ No existe: %s"
    [btn_cancel]="❌ Cancelar"
    [btn_reboot_now]="🔁 Reiniciar Ahora"

    # ─── csq_label ───────────────────────────────────────────────────
    [csq_excellent]="🟢 Excelente"
    [csq_good]="🟢 Buena"
    [csq_moderate]="🟡 Moderada"
    [csq_weak]="🟠 Débil"
    [csq_very_weak]="🔴 Muy débil"
    [csq_unknown]="🔴 Desconocida"

    # ─── alerts ──────────────────────────────────────────────────────
    [alert_temp_fmt]="🌡 AVISO: Temperatura CPU alta — %d°C
(Umbral %d°C, sin re-aviso por %d s)"
    [alert_mem_fmt]="💾 AVISO: RAM muy baja — %d%% disponible
(%d MB)"
    [alert_tunnel]="🔌 AVISO: el túnel Cloudflared no está activo (sin proceso)"
    [alert_sms_forward_fmt]="📨 SMS entrante — %s
👤 %s

%s"

    # ─── chat triggers ───────────────────────────────────────────────
    [chat_greeting_fmt]="%s, aquí estoy 👋"
    [chat_naber_fmt]="%s! Mi estado:

%s"
    [chat_time_fmt]="🕐 %s"
    [chat_imisin_fmt]="Estoy bien 🙂 (temp %s, uptime %s)"
    [chat_thanks]="🤖 De nada 👍"
    [chat_morning_fmt]="¡Buenos días! ☀️ %s desde el arranque"
    [chat_night]="Tú también 🌙 me quedo despierto"

    # ─── /update ──────────────────────────────────────────────────────
    [update_header]="🔍 Comprobando actualizaciones de módulos"
    [update_remote_unread_fmt]="  %s: %s  ⚠ remoto inaccesible"
    [update_parse_fail_fmt]="  %s: %s  ⚠ error de JSON"
    [update_outdated_fmt]="  📦 %s: %s → %s (vCode %d→%d) ⬆"
    [update_uptodate_fmt]="  ✓ %s: %s (al día)"
    [update_none_defined]="Ningún módulo tiene updateJson definido."
    [update_all_current]="Todos los módulos están al día."
    [update_count_outdated_fmt]="%d módulo(s) actualizables.
Actualizar todos: /update all
Uno a uno: /update <module-id>"
    [update_all_start]="📥 Comprobando e instalando todas las actualizaciones…"
    [update_no_zipurl_fmt]="  %s: zipUrl ausente, omitido"
    [update_downloading_fmt]="  ⬇ Descargando %s %s…"
    [update_installed_fmt]="  ✅ %s → %s"
    [update_install_failed_fmt]="  ❌ %s instalación fallida"
    [update_download_failed_fmt]="  ❌ %s descarga fallida"
    [update_summary_fmt]="📊 Resumen: %d revisados, %d actualizados, %d fallidos"
    [update_reboot_hint]="
Si cambiaron binarios, reinicia para aplicar.
Si statusbot se actualizó, se reinicia en ~10 s (supervisor)."
    [update_module_not_found_fmt]="❌ Módulo no encontrado: %s
Para la lista: /update"
    [update_no_updatejson_fmt]="❌ %s no tiene updateJson definido"
    [update_remote_unread_long_fmt]="❌ Remoto inaccesible: %s"
    [update_already_current_fmt]="✓ %s ya está al día (%s)"
    [update_download_failed]="❌ Descarga fallida"
    [update_self_installed_fmt]="✅ statusbot %s instalado, reinicia en 5 s…"
    [update_other_installed_fmt]="✅ %s %s instalado
Si cambió un binario, se recomienda reiniciar."
    [update_install_failed_long_fmt]="❌ Instalación fallida:
%s"

    # NOTE: keys not translated here fall back to en.sh. The bot is fully
    # functional with this subset; community PRs welcome to extend coverage.
)
