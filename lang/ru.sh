# statusbot Русский — community translation seeded by upstream
# Sourced AFTER en.sh; keys here override English. Missing keys fall back.

declare -gA MSG=(
    [lang_current_fmt]="Текущий язык: %s"
    [lang_available_header]="Доступные языки:"
    [lang_set_fmt]="Язык изменён на %s. Бот перезапустится через 3 с."
    [lang_invalid_fmt]="Неизвестный код языка: %s. Смотри /lang для списка."
    [lang_usage]="Использование: /lang [код]
Без аргумента: текущий + доступные языки.
С кодом: меняет и перезапускает бота."

    [greet_morning]="Доброе утро"
    [greet_noon]="Добрый день"
    [greet_evening]="Добрый вечер"
    [greet_night]="Спокойной ночи"
    [boot_greeting_fmt]="%s, я в сети 🤖
%s — uptime: %s
Введи /help для команд."

    [help_full_fmt]="ZTE F50 Bot — Команды

📊 Статус
/status — полный обзор
/uptime — время работы
/load — нагрузка CPU
/mem — RAM
/disk — диск
/temp — температура (CPU)
/ps — топ 10 процессов (CPU)

📡 Сотовая связь
/signal — качество сигнала (RSSI, RSRP, RSRQ)
/cellinfo — оператор + IMEI + ICCID + номер
/imei — IMEI(ы)
/imei_sorgula [imei] — анализ IMEI + e-Devlet
/imei_degis <imei> — изменить IMEI (с подтверждением, перезагрузка)
/operator — только оператор
/qos — детали QoS / диапазона
/sms_list [N] — последние N SMS (по умолч. 10)
/sms_count — всего во входящих
/sms_send <num> <text> — отправить SMS через AT
/at <cmd> — выполнить AT команду

🌐 Сеть
/ip — публичные + локальные IP
/traffic — RX/TX с момента загрузки
/ping <host>
/speedtest [cf|ookla|fast] [size] — тест скорости
/clients — подключённые клиенты (ARP)
/wifi — hotspot SSID + пароль + клиенты
/tunnel — статус Cloudflared

🔧 Система
/modules — модули Magisk
/version
/reboot — перезагрузка (с подтверждением)
/komut <cmd> — shell команда (можно отменить)
/file <путь> — скачать файл с устройства
/upload <цель> — загрузить файл на устройство
/screenshot — снимок экрана
/ramclean [pkg…] — очистка памяти
/performance [on|off] — Режим ZTE Performance (нужна перезагрузка)
/perf_balanced [mhz] — 8-ядер + cap частоты (реком., 1800)
/perf_help — руководство сравнения
/minimal_mode [on|persist|off] — заморозить сервисы (~640 MB)
/zte_setpw <pwd> — задать пароль ZTE admin
/lang [code] — сменить язык бота

🗂 Файловая система
/ls <путь>
/cat <файл> — содержимое (4 KB)
/df — использование диска
/du <dir> — размеры подкаталогов
/log [N] — последние N строк лога
/dump_sms — полный дамп SMS

🌐 Сеть (доп.)
/connections — активные TCP
/listening — слушающие порты
/dhcp — таблица DHCP
/dns — конфигурация DNS

⚡ Питание / Ядро
/cpu_freq — частоты CPU
/cpu_governor [name] — показать/сменить governor
/wakelock — активные wakelock'и

📦 Приложения
/installed [3rd|disabled|system|all]
/freeze <pkg> — заморозить пакет
/unfreeze <pkg> — разморозить пакет

⏰ Планирование
/alarm HH:MM <msg> — один раз
/schedule <sec> <cmd> — повторяющийся
/schedule list / clear / cancel <idx>
/heartbeat <часы> — периодический пинг
/quiet_hours <от> <до> — тихие часы

🔒 Безопасность
/who — активные SSH/ADB сессии
/last_boot — история загрузок
/bot_stats — внутренняя статистика
/restart_bot — перезапуск бота
/update [all|<id>] — обновить модули с GitHub

🌍 Tailscale (опциональный модуль)
/tailscale auth <key> — сохранить auth-key
/tailscale on / off — запустить/остановить
/tailscale status — статус + RAM
/tailscale ip / peers / log / logout

🔔 Автоматически (фоном):
• Входящие SMS пересылаются
• Уведомления при temp > %d°C, RAM < %d%%, tunnel down
• Heartbeat (если настроен) и расписания
• Тихие часы заглушают уведомления

💬 Чат-триггеры
selam, merhaba, sa — приветствие
naber — статус + приветствие
saat — время устройства
iyi misin — проверка статуса"

    [uptime_days_fmt]="%d д %02d ч %02d м"
    [uptime_hours_fmt]="%d ч %02d м"
    [uptime_short_fmt]="%d м %02d с"
    [disk_fmt]="%s / %s (%s занято)"

    [load_status_calm]="🟢 спокойно (%d%%)"
    [load_status_active]="🟡 активно (%d%%)"
    [load_status_full]="🟠 заполнено (%d%%)"
    [load_status_busy]="🔴 занято (%d%%)"
    [load_full_fmt]="📊 Нагрузка CPU (%d ядер)

Сейчас (1 мин):    %s
Последние 5 мин:   %s
Последние 15 мин:  %s

Статус: %s

Подсказка:
  %d.0 = все CPU полностью загружены
  < %d.0 = есть резерв
  > %d.0 = очередь, возможны задержки"

    [status_model_fmt]="📱 %s\n"
    [status_uptime_fmt]="⏱  Uptime: %s\n"
    [status_ram_fmt]="💾 RAM: %s\n"
    [status_disk_fmt]="💿 Диск: %s\n"
    [status_temp_fmt]="🌡  Температура: %s\n"
    [status_perf_on]="⚡ Performance: ВКЛ 🟢\n"
    [status_perf_off]="⚡ Performance: ВЫКЛ ⚪\n"
    [status_operator_fmt]="📡 Оператор: %s\n"
    [status_signal_fmt]="📶 Сигнал: RSSI %s (%s)\n"
    [status_public_ip_fmt]="🌐 Публичный IP: %s"

    [perf_status_on]="⚡ Режим Performance: ВКЛ 🟢
Чтобы выключить: /performance off"
    [perf_status_off]="⚡ Режим Performance: ВЫКЛ ⚪
Чтобы включить: /performance on"
    [perf_no_password]="❌ Пароль ZTE не задан. Сначала: /zte_setpw <pwd>"
    [perf_login_failed]="❌ Вход в ZTE не удался. Неверный пароль? Обнови через /zte_setpw."
    [perf_login_failed_short]="❌ Вход в ZTE не удался."
    [perf_set_failed_fmt]="❌ Не удалось: %s"
    [perf_enabled_reboot]="⚡ Режим Performance ВКЛЮЧЕН 🟢
Перезагрузи устройство, чтобы применить."
    [perf_disabled_reboot]="⚡ Режим Performance ВЫКЛЮЧЕН ⚪
Перезагрузи устройство, чтобы применить."
    [perf_usage]="Использование: /performance [on|off|status]"

    [zte_pw_set_fmt]="Пароль ZTE задан (длина: %d байт).
Чтобы изменить: /zte_setpw <новый_pwd>"
    [zte_pw_usage]="Использование: /zte_setpw <pwd>
(Пароль веб-админки ZTE — для /performance и т.п.)"
    [zte_pw_saved_fmt]="✓ Пароль ZTE сохранён (%d байт).
Проверить: /performance"
    [iptal_imei]="  ✓ Запрос IMEI"
    [iptal_upload]="  ✓ Ожидающая загрузка"
    [iptal_speedtest]="  ✓ Цикл speedtest"
    [iptal_none]="Нечего отменять"
    [iptal_done_fmt]="🛑 Отменено:%s"
    [reboot_starting]="🔁 Перезагрузка начата…"
    [reboot_expired]="⚠️ Тайм-аут. Сначала введи /reboot заново."
    [reboot_confirm]="⚠️ Подтверди: введи \"/reboot YES\" в течение 60 с."
    [version_fmt]="🤖 Bot %s
📱 %s
🏷  %s
🤖 Android %s (SDK %s)
🐧 %s"

    [common_not_exists_fmt]="❌ Не существует: %s"
    [btn_cancel]="❌ Отмена"
    [btn_reboot_now]="🔁 Перезагрузить Сейчас"

    [csq_excellent]="🟢 Отличный"
    [csq_good]="🟢 Хороший"
    [csq_moderate]="🟡 Средний"
    [csq_weak]="🟠 Слабый"
    [csq_very_weak]="🔴 Очень слабый"
    [csq_unknown]="🔴 Неизвестно"

    [alert_temp_fmt]="🌡 ВНИМАНИЕ: температура CPU высокая — %d°C
(Порог %d°C, без повторного оповещения %d с)"
    [alert_mem_fmt]="💾 ВНИМАНИЕ: RAM очень мало — %d%% доступно
(%d MB)"
    [alert_tunnel]="🔌 ВНИМАНИЕ: Cloudflared tunnel не работает (нет процесса)"
    [alert_sms_forward_fmt]="📨 Входящее SMS — %s
👤 %s

%s"

    [chat_greeting_fmt]="%s, я здесь 👋"
    [chat_naber_fmt]="%s! Мой статус:

%s"
    [chat_time_fmt]="🕐 %s"
    [chat_imisin_fmt]="Я в порядке 🙂 (temp %s, uptime %s)"
    [chat_thanks]="🤖 Пожалуйста 👍"
    [chat_morning_fmt]="Доброе утро! ☀️ %s с момента загрузки"
    [chat_night]="И тебе 🌙 я остаюсь на связи"

    [update_header]="🔍 Проверка обновлений модулей"
    [update_all_current]="Все модули актуальны."
    [update_none_defined]="Ни у одного модуля не задан updateJson."
)
