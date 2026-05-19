# statusbot Português — community translation seeded by upstream
# Sourced AFTER en.sh; keys here override English. Missing keys fall back.

declare -gA MSG=(
    [lang_current_fmt]="Idioma atual: %s"
    [lang_available_header]="Idiomas disponíveis:"
    [lang_set_fmt]="Idioma alterado para %s. O bot reiniciará em 3 s."
    [lang_invalid_fmt]="Código de idioma desconhecido: %s. Ver /lang para a lista."
    [lang_usage]="Uso: /lang [código]
Sem argumento: idioma atual + disponíveis.
Com código: muda e reinicia o bot."

    [greet_morning]="Bom dia"
    [greet_noon]="Boa tarde"
    [greet_evening]="Boa noite"
    [greet_night]="Boa noite"
    [boot_greeting_fmt]="%s, estou online 🤖
%s — uptime: %s
Digite /help para os comandos."

    [help_full_fmt]="Bot ZTE F50 — Comandos

📊 Status
/status — visão geral completa
/uptime — tempo ativo
/load — carga CPU (detalhada)
/mem — RAM
/disk — disco
/temp — temperatura (CPU)
/ps — top 10 processos (CPU)

📡 Celular
/signal — qualidade do sinal (RSSI, RSRP, RSRQ)
/cellinfo — operadora + IMEI + ICCID + número
/imei — IMEI(s)
/imei_sorgula [imei] — análise IMEI + consulta e-Devlet
/imei_degis <imei> — alterar IMEI (confirmado, reinicia)
/operator — apenas operadora
/qos — detalhes QoS / banda
/sms_list [N] — últimas N SMS (padrão 10)
/sms_count — total da caixa de entrada
/sms_send <num> <texto> — enviar SMS via AT
/at <cmd> — comando AT bruto

🌐 Rede
/ip — IPs públicos + locais
/traffic — RX/TX desde o boot
/ping <host>
/speedtest [cf|ookla|fast] [size] — teste de velocidade
/clients — clientes conectados (ARP)
/wifi — hotspot SSID + senha + clientes
/tunnel — status Cloudflared

🔧 Sistema
/modules — módulos Magisk
/version
/reboot — reiniciar (confirmação)
/komut <cmd> — comando shell (cancelável)
/file <caminho> — baixar arquivo do dispositivo
/upload <destino> — enviar arquivo ao dispositivo
/screenshot — captura de tela
/ramclean [pkg…] — limpeza de memória
/performance [on|off] — Modo Performance ZTE (precisa reiniciar)
/perf_balanced [mhz] — 8-núcleos + cap freq (recomendado, 1800)
/perf_help — guia comparativo
/minimal_mode [on|persist|off] — congelar serviços (~640 MB)
/zte_setpw <pwd> — definir senha admin ZTE
/lang [code] — mudar idioma do bot

🗂 Sistema de arquivos
/ls <caminho>
/cat <arquivo> — conteúdo (4 KB)
/df — uso de disco
/du <dir> — tamanhos de subdiretórios
/log [N] — N últimas linhas do log
/dump_sms — dump completo do inbox

🌐 Rede (extras)
/connections — TCP estabelecidas
/listening — portas em escuta
/dhcp — tabela DHCP
/dns — configuração DNS

⚡ Energia / Kernel
/cpu_freq — frequências CPU
/cpu_governor [name] — ver/mudar governor
/wakelock — wakelocks ativos

📦 Apps
/installed [3rd|disabled|system|all]
/freeze <pkg> — congelar pacote
/unfreeze <pkg> — descongelar pacote

⏰ Agendamento
/alarm HH:MM <msg> — uma vez
/schedule <sec> <cmd> — recorrente
/schedule list / clear / cancel <idx>
/heartbeat <horas> — ping periódico
/quiet_hours <de> <até> — horas silenciosas

🔒 Segurança
/who — sessões SSH/ADB ativas
/last_boot — histórico de boot
/bot_stats — stats internas
/restart_bot — reiniciar o bot
/update [all|<id>] — atualizar módulos do GitHub

🌍 Tailscale (módulo opcional)
/tailscale auth <key> — salvar auth-key
/tailscale on / off — iniciar/parar
/tailscale status — status + RAM
/tailscale ip / peers / log / logout

🔔 Automático (segundo plano):
• SMS recebido encaminhado
• Alertas se temp > %d°C, RAM < %d%%, tunnel down
• Heartbeat (se configurado) e agendamentos
• Quiet hours silenciam alertas

💬 Disparadores chat
selam, merhaba, sa — saudação
naber — status + saudação
saat — hora do dispositivo
iyi misin — verificação de status"

    [uptime_days_fmt]="%d d %02d h %02d m"
    [uptime_hours_fmt]="%d h %02d m"
    [uptime_short_fmt]="%d m %02d s"
    [disk_fmt]="%s / %s (%s usado)"

    [load_status_calm]="🟢 calmo (%d%%)"
    [load_status_active]="🟡 ativo (%d%%)"
    [load_status_full]="🟠 cheio (%d%%)"
    [load_status_busy]="🔴 ocupado (%d%%)"
    [load_full_fmt]="📊 Carga CPU (%d núcleos)

Agora (1 min):     %s
Últimos 5 min:     %s
Últimos 15 min:    %s

Status: %s

Guia:
  %d.0 = todas as CPUs no máximo
  < %d.0 = capacidade disponível
  > %d.0 = fila, possível lentidão"

    [status_model_fmt]="📱 %s\n"
    [status_uptime_fmt]="⏱  Uptime: %s\n"
    [status_ram_fmt]="💾 RAM: %s\n"
    [status_disk_fmt]="💿 Disco: %s\n"
    [status_temp_fmt]="🌡  Temperatura: %s\n"
    [status_perf_on]="⚡ Performance: ON 🟢\n"
    [status_perf_off]="⚡ Performance: OFF ⚪\n"
    [status_operator_fmt]="📡 Operadora: %s\n"
    [status_signal_fmt]="📶 Sinal: RSSI %s (%s)\n"
    [status_public_ip_fmt]="🌐 IP Pública: %s"

    [perf_status_on]="⚡ Modo Performance: ATIVO 🟢
Para desativar: /performance off"
    [perf_status_off]="⚡ Modo Performance: INATIVO ⚪
Para ativar: /performance on"
    [perf_no_password]="❌ Senha ZTE não definida. Primeiro: /zte_setpw <pwd>"
    [perf_login_failed]="❌ Login ZTE falhou. Senha errada? Atualize com /zte_setpw."
    [perf_login_failed_short]="❌ Login ZTE falhou."
    [perf_set_failed_fmt]="❌ Falhou: %s"
    [perf_enabled_reboot]="⚡ Modo Performance ATIVADO 🟢
Reinicie o dispositivo para aplicar."
    [perf_disabled_reboot]="⚡ Modo Performance DESATIVADO ⚪
Reinicie o dispositivo para aplicar."
    [perf_usage]="Uso: /performance [on|off|status]"

    [zte_pw_set_fmt]="Senha ZTE definida (tamanho: %d bytes).
Para alterar: /zte_setpw <nova_pwd>"
    [zte_pw_usage]="Uso: /zte_setpw <pwd>
(Senha admin web ZTE — para /performance etc.)"
    [zte_pw_saved_fmt]="✓ Senha ZTE salva (%d bytes).
Testar: /performance"
    [iptal_imei]="  ✓ Consulta IMEI"
    [iptal_upload]="  ✓ Upload pendente"
    [iptal_speedtest]="  ✓ Loop de speedtest"
    [iptal_none]="Nada pendente para cancelar"
    [iptal_done_fmt]="🛑 Cancelado:%s"
    [reboot_starting]="🔁 Reinicialização iniciando…"
    [reboot_expired]="⚠️ Expirado. Execute /reboot novamente."
    [reboot_confirm]="⚠️ Confirme: digite \"/reboot YES\" em 60 s."
    [version_fmt]="🤖 Bot %s
📱 %s
🏷  %s
🤖 Android %s (SDK %s)
🐧 %s"

    [common_not_exists_fmt]="❌ Não existe: %s"
    [btn_cancel]="❌ Cancelar"
    [btn_reboot_now]="🔁 Reiniciar Agora"

    [csq_excellent]="🟢 Excelente"
    [csq_good]="🟢 Bom"
    [csq_moderate]="🟡 Moderado"
    [csq_weak]="🟠 Fraco"
    [csq_very_weak]="🔴 Muito fraco"
    [csq_unknown]="🔴 Desconhecido"

    [alert_temp_fmt]="🌡 AVISO: temperatura CPU alta — %d°C
(Limiar %d°C, sem re-aviso por %d s)"
    [alert_mem_fmt]="💾 AVISO: RAM muito baixa — %d%% disponível
(%d MB)"
    [alert_tunnel]="🔌 AVISO: tunnel Cloudflared não está rodando (sem processo)"
    [alert_sms_forward_fmt]="📨 SMS recebido — %s
👤 %s

%s"

    [chat_greeting_fmt]="%s, aqui estou 👋"
    [chat_naber_fmt]="%s! Meu status:

%s"
    [chat_time_fmt]="🕐 %s"
    [chat_imisin_fmt]="Estou bem 🙂 (temp %s, uptime %s)"
    [chat_thanks]="🤖 De nada 👍"
    [chat_morning_fmt]="Bom dia! ☀️ %s desde o boot"
    [chat_night]="Pra você também 🌙 fico acordado"

    [update_header]="🔍 Verificação de atualizações de módulos"
    [update_all_current]="Todos os módulos estão atualizados."
    [update_none_defined]="Nenhum módulo tem updateJson definido."
)
