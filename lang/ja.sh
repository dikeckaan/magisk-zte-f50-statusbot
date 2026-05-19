# statusbot 日本語 — community translation seeded by upstream
# Sourced AFTER en.sh; keys here override English. Missing keys fall back.

declare -gA MSG=(
    [lang_current_fmt]="現在の言語: %s"
    [lang_available_header]="利用可能な言語:"
    [lang_set_fmt]="言語を %s に変更しました。Bot は 3 秒後に再起動します。"
    [lang_invalid_fmt]="未知の言語コード: %s。/lang でリスト確認。"
    [lang_usage]="使い方: /lang [コード]
引数なし: 現在 + 利用可能な言語を表示。
コード指定: 切り替えて Bot を再起動。"

    [greet_morning]="おはようございます"
    [greet_noon]="こんにちは"
    [greet_evening]="こんばんは"
    [greet_night]="おやすみなさい"
    [boot_greeting_fmt]="%s、起動しました 🤖
%s — uptime: %s
/help でコマンド一覧。"

    [help_full_fmt]="ZTE F50 Bot — コマンド一覧

📊 ステータス
/status — 全体の概要
/uptime — 稼働時間
/load — CPU 負荷（詳細）
/mem — RAM
/disk — ディスク
/temp — 温度（CPU）
/ps — トップ 10 プロセス（CPU）

📡 セルラー
/signal — 信号品質 (RSSI, RSRP, RSRQ)
/cellinfo — オペレータ + IMEI + ICCID + 番号
/imei — IMEI（スロットごと）
/imei_sorgula [imei] — IMEI 解析 + e-Devlet 照会
/imei_degis <imei> — IMEI 変更（確認後リブート）
/operator — オペレータのみ
/qos — QoS / バンド詳細
/sms_list [N] — 直近 N 件 SMS（デフォルト 10）
/sms_count — 受信箱合計
/sms_send <num> <text> — AT で SMS 送信
/at <cmd> — 生の AT コマンド

🌐 ネットワーク
/ip — 公開 + ローカル IP
/traffic — 起動以来 RX/TX
/ping <host>
/speedtest [cf|ookla|fast] [size] — 速度テスト
/clients — 接続済みクライアント (ARP)
/wifi — ホットスポット SSID + パスワード + クライアント
/tunnel — Cloudflared 状態

🔧 システム
/modules — Magisk モジュール
/version
/reboot — 再起動（確認あり）
/komut <cmd> — シェルコマンド（キャンセル可）
/file <パス> — デバイスからファイル取得
/upload <ターゲット> — デバイスへファイル送信
/screenshot — スクリーンショット
/ramclean [pkg…] — メモリクリーン
/performance [on|off] — ZTE Performance モード（再起動必要）
/perf_balanced [mhz] — 8 コア + 周波数キャップ（推奨 1800）
/perf_help — モード比較ガイド
/minimal_mode [on|persist|off] — サービス凍結（~640 MB）
/zte_setpw <pwd> — ZTE 管理者パスワード設定
/lang [code] — Bot 言語切替

🗂 ファイルシステム
/ls <パス>
/cat <ファイル> — 内容（4 KB）
/df — ディスク使用量
/du <dir> — サブディレクトリサイズ
/log [N] — ログの最後 N 行
/dump_sms — 受信箱完全ダンプ

🌐 ネットワーク（追加）
/connections — 確立済み TCP
/listening — リスニングポート
/dhcp — DHCP リーステーブル
/dns — DNS 設定

⚡ 電源 / カーネル
/cpu_freq — CPU 周波数
/cpu_governor [name] — Governor 表示/変更
/wakelock — アクティブなウェイクロック

📦 アプリ
/installed [3rd|disabled|system|all]
/freeze <pkg> — パッケージ凍結
/unfreeze <pkg> — パッケージ解凍

⏰ スケジュール
/alarm HH:MM <msg> — 1 回限り
/schedule <sec> <cmd> — 繰り返し
/schedule list / clear / cancel <idx>
/heartbeat <時間> — 定期的な生存通知
/quiet_hours <から> <まで> — 静音時間帯

🔒 セキュリティ
/who — アクティブな SSH/ADB セッション
/last_boot — 起動履歴
/bot_stats — Bot 内部統計
/restart_bot — Bot 再起動
/update [all|<id>] — GitHub からモジュール更新

🌍 Tailscale（オプションモジュール）
/tailscale auth <key> — auth-key 保存
/tailscale on / off — 開始/停止
/tailscale status — 状態 + RAM
/tailscale ip / peers / log / logout

🔔 自動（バックグラウンド）:
• 受信 SMS を転送
• 温度 > %d°C、RAM < %d%%、tunnel down 時にアラート
• Heartbeat（設定済み）とスケジュール
• Quiet hours 中はアラート抑制

💬 チャットトリガー
selam, merhaba, sa — 挨拶
naber — 状態 + 挨拶
saat — デバイスの時刻
iyi misin — 状態確認"

    [uptime_days_fmt]="%d 日 %02d 時 %02d 分"
    [uptime_hours_fmt]="%d 時 %02d 分"
    [uptime_short_fmt]="%d 分 %02d 秒"
    [disk_fmt]="%s / %s (%s 使用中)"

    [load_status_calm]="🟢 平穏 (%d%%)"
    [load_status_active]="🟡 活発 (%d%%)"
    [load_status_full]="🟠 満杯 (%d%%)"
    [load_status_busy]="🔴 多忙 (%d%%)"
    [load_full_fmt]="📊 CPU 負荷 (%d コア)

現在 (1 分):     %s
直近 5 分:       %s
直近 15 分:      %s

状態: %s

ガイド:
  %d.0 = 全 CPU フル稼働
  < %d.0 = 余裕あり
  > %d.0 = キュー発生、遅延の可能性"

    [status_model_fmt]="📱 %s\n"
    [status_uptime_fmt]="⏱  Uptime: %s\n"
    [status_ram_fmt]="💾 RAM: %s\n"
    [status_disk_fmt]="💿 ディスク: %s\n"
    [status_temp_fmt]="🌡  温度: %s\n"
    [status_perf_on]="⚡ Performance: ON 🟢\n"
    [status_perf_off]="⚡ Performance: OFF ⚪\n"
    [status_operator_fmt]="📡 オペレータ: %s\n"
    [status_signal_fmt]="📶 信号: RSSI %s (%s)\n"
    [status_public_ip_fmt]="🌐 公開 IP: %s"

    [perf_status_on]="⚡ Performance モード: ON 🟢
OFF にする: /performance off"
    [perf_status_off]="⚡ Performance モード: OFF ⚪
ON にする: /performance on"
    [perf_no_password]="❌ ZTE パスワード未設定。最初に: /zte_setpw <pwd>"
    [perf_login_failed]="❌ ZTE ログイン失敗。パスワードが違うかも。/zte_setpw で更新。"
    [perf_login_failed_short]="❌ ZTE ログイン失敗。"
    [perf_set_failed_fmt]="❌ 設定失敗: %s"
    [perf_enabled_reboot]="⚡ Performance モードを有効化 🟢
変更を適用するには再起動してください。"
    [perf_disabled_reboot]="⚡ Performance モードを無効化 ⚪
変更を適用するには再起動してください。"
    [perf_usage]="使い方: /performance [on|off|status]"

    [zte_pw_set_fmt]="ZTE パスワード設定済み (長さ: %d バイト)。
変更: /zte_setpw <新しいpwd>"
    [zte_pw_usage]="使い方: /zte_setpw <pwd>
(ZTE Web 管理パスワード — /performance 等に使用)"
    [zte_pw_saved_fmt]="✓ ZTE パスワード保存 (%d バイト)。
テスト: /performance"
    [iptal_imei]="  ✓ IMEI 照会"
    [iptal_upload]="  ✓ 保留中の upload"
    [iptal_speedtest]="  ✓ Speedtest ループ"
    [iptal_none]="保留中のキャンセル対象なし"
    [iptal_done_fmt]="🛑 キャンセル:%s"
    [reboot_starting]="🔁 再起動を開始…"
    [reboot_expired]="⚠️ タイムアウト。最初に /reboot をやり直してください。"
    [reboot_confirm]="⚠️ 確認: 60 秒以内に \"/reboot YES\" を入力。"
    [version_fmt]="🤖 Bot %s
📱 %s
🏷  %s
🤖 Android %s (SDK %s)
🐧 %s"

    [common_not_exists_fmt]="❌ 存在しません: %s"
    [btn_cancel]="❌ キャンセル"
    [btn_reboot_now]="🔁 今すぐ再起動"

    [csq_excellent]="🟢 優秀"
    [csq_good]="🟢 良好"
    [csq_moderate]="🟡 普通"
    [csq_weak]="🟠 弱い"
    [csq_very_weak]="🔴 非常に弱い"
    [csq_unknown]="🔴 不明"

    [alert_temp_fmt]="🌡 警告: CPU 温度高 — %d°C
(閾値 %d°C, %d 秒間再警告なし)"
    [alert_mem_fmt]="💾 警告: RAM 極小 — %d%% 利用可
(%d MB)"
    [alert_tunnel]="🔌 警告: Cloudflared tunnel 停止中（プロセスなし）"
    [alert_sms_forward_fmt]="📨 受信 SMS — %s
👤 %s

%s"

    [chat_greeting_fmt]="%s、ここにいます 👋"
    [chat_naber_fmt]="%s! 私の状態:

%s"
    [chat_time_fmt]="🕐 %s"
    [chat_imisin_fmt]="元気です 🙂 (temp %s, uptime %s)"
    [chat_thanks]="🤖 どういたしまして 👍"
    [chat_morning_fmt]="おはようございます！☀️ 起動から %s"
    [chat_night]="あなたも 🌙 私は起きています"

    [update_header]="🔍 モジュール更新チェック"
    [update_all_current]="すべてのモジュールは最新です。"
    [update_none_defined]="updateJson 未定義のモジュールがあります。"
)
