# statusbot 简体中文 — community translation seeded by upstream
# Sourced AFTER en.sh; keys here override English. Missing keys fall back.

declare -gA MSG=(
    [lang_current_fmt]="当前语言：%s"
    [lang_available_header]="可用语言："
    [lang_set_fmt]="语言已切换为 %s。机器人将在 3 秒后重启。"
    [lang_invalid_fmt]="未知语言代码：%s。查看 /lang 获取列表。"
    [lang_usage]="用法：/lang [代码]
不带参数：显示当前 + 可用语言。
带代码：切换语言并重启机器人。"

    [greet_morning]="早上好"
    [greet_noon]="下午好"
    [greet_evening]="晚上好"
    [greet_night]="晚安"
    [boot_greeting_fmt]="%s，我在线 🤖
%s — uptime: %s
输入 /help 查看命令。"

    [help_full_fmt]="ZTE F50 机器人 — 命令列表

📊 状态
/status — 完整概览
/uptime — 运行时间
/load — CPU 负载（详细）
/mem — 内存
/disk — 磁盘
/temp — 温度（CPU）
/ps — 前 10 个进程（CPU）

📡 蜂窝网络
/signal — 信号质量（RSSI, RSRP, RSRQ）
/cellinfo — 运营商 + IMEI + ICCID + 号码
/imei — IMEI（每个卡槽）
/imei_sorgula [imei] — IMEI 分析 + e-Devlet 查询
/imei_degis <imei> — 修改 IMEI（确认后重启）
/operator — 仅运营商
/qos — QoS / 频段详情
/sms_list [N] — 最近 N 条短信（默认 10）
/sms_count — 收件箱总数
/sms_send <num> <text> — 通过 AT 发送短信
/at <cmd> — 执行原始 AT 命令

🌐 网络
/ip — 公网 + 本地 IP
/traffic — 启动以来 RX/TX
/ping <host>
/speedtest [cf|ookla|fast] [size] — 速度测试
/clients — 已连接客户端（ARP）
/wifi — 热点 SSID + 密码 + 客户端
/tunnel — Cloudflared 状态

🔧 系统
/modules — Magisk 模块
/version
/reboot — 重启（需确认）
/komut <cmd> — Shell 命令（可取消）
/file <path> — 从设备下载文件
/upload <target> — 上传文件到设备
/screenshot — 屏幕截图
/ramclean [pkg…] — 内存清理
/performance [on|off] — ZTE 性能模式（需重启）
/perf_balanced [mhz] — 8 核 + 频率限制（推荐 1800）
/perf_help — 模式对比指南
/minimal_mode [on|persist|off] — 冻结服务（约 640 MB）
/zte_setpw <pwd> — 设置 ZTE 管理员密码
/lang [code] — 切换机器人语言

🗂 文件系统
/ls <path>
/cat <file> — 内容（4 KB）
/df — 磁盘使用
/du <dir> — 子目录大小
/log [N] — 最后 N 行日志
/dump_sms — 完整收件箱导出

🌐 网络（扩展）
/connections — 活动 TCP 连接
/listening — 监听端口
/dhcp — DHCP 租约表
/dns — DNS 配置

⚡ 电源 / 内核
/cpu_freq — CPU 频率
/cpu_governor [name] — 显示/修改 governor
/wakelock — 活动唤醒锁

📦 应用
/installed [3rd|disabled|system|all]
/freeze <pkg> — 冻结应用
/unfreeze <pkg> — 解冻应用

⏰ 调度
/alarm HH:MM <msg> — 单次
/schedule <sec> <cmd> — 循环
/schedule list / clear / cancel <idx>
/heartbeat <小时> — 周期性心跳
/quiet_hours <从> <到> — 静默时段

🔒 安全
/who — 活动 SSH/ADB 会话
/last_boot — 启动历史
/bot_stats — 机器人内部统计
/restart_bot — 重启机器人
/update [all|<id>] — 从 GitHub 更新模块

🌍 Tailscale（可选模块）
/tailscale auth <key> — 保存认证密钥
/tailscale on / off — 启动/停止
/tailscale status — 状态 + RAM
/tailscale ip / peers / log / logout

🔔 自动（后台）：
• 入站短信转发
• 温度 > %d°C、内存 < %d%%、隧道断开时告警
• Heartbeat（若配置）和定时任务
• 静默时段抑制告警

💬 聊天触发器
selam, merhaba, sa — 问候
naber — 状态 + 问候
saat — 设备时间
iyi misin — 状态检查"

    [uptime_days_fmt]="%d 天 %02d 时 %02d 分"
    [uptime_hours_fmt]="%d 时 %02d 分"
    [uptime_short_fmt]="%d 分 %02d 秒"
    [disk_fmt]="%s / %s (%s 已用)"

    [load_status_calm]="🟢 空闲 (%d%%)"
    [load_status_active]="🟡 活跃 (%d%%)"
    [load_status_full]="🟠 繁忙 (%d%%)"
    [load_status_busy]="🔴 满载 (%d%%)"
    [load_full_fmt]="📊 CPU 负载 (%d 核)

现在 (1 分):    %s
最近 5 分:     %s
最近 15 分:    %s

状态: %s

指南:
  %d.0 = 所有 CPU 满载
  < %d.0 = 有余量
  > %d.0 = 队列，可能延迟"

    [status_model_fmt]="📱 %s\n"
    [status_uptime_fmt]="⏱  Uptime: %s\n"
    [status_ram_fmt]="💾 RAM: %s\n"
    [status_disk_fmt]="💿 磁盘: %s\n"
    [status_temp_fmt]="🌡  温度: %s\n"
    [status_perf_on]="⚡ Performance: 开 🟢\n"
    [status_perf_off]="⚡ Performance: 关 ⚪\n"
    [status_operator_fmt]="📡 运营商: %s\n"
    [status_signal_fmt]="📶 信号: RSSI %s (%s)\n"
    [status_public_ip_fmt]="🌐 公网 IP: %s"

    [perf_status_on]="⚡ 性能模式: 开 🟢
关闭: /performance off"
    [perf_status_off]="⚡ 性能模式: 关 ⚪
开启: /performance on"
    [perf_no_password]="❌ ZTE 密码未设置。请先: /zte_setpw <pwd>"
    [perf_login_failed]="❌ ZTE 登录失败。密码错误？用 /zte_setpw 更新。"
    [perf_login_failed_short]="❌ ZTE 登录失败。"
    [perf_set_failed_fmt]="❌ 设置失败: %s"
    [perf_enabled_reboot]="⚡ 性能模式已开启 🟢
请重启设备以应用更改。"
    [perf_disabled_reboot]="⚡ 性能模式已关闭 ⚪
请重启设备以应用更改。"
    [perf_usage]="用法: /performance [on|off|status]"

    [zte_pw_set_fmt]="ZTE 密码已设置 (长度: %d 字节)。
修改: /zte_setpw <新密码>"
    [zte_pw_usage]="用法: /zte_setpw <pwd>
(ZTE Web 管理员密码 — 用于 /performance 等)"
    [zte_pw_saved_fmt]="✓ ZTE 密码已保存 (%d 字节)。
测试: /performance"
    [iptal_imei]="  ✓ IMEI 查询"
    [iptal_upload]="  ✓ 待处理上传"
    [iptal_speedtest]="  ✓ Speedtest 循环"
    [iptal_none]="没有可取消的待处理项"
    [iptal_done_fmt]="🛑 已取消:%s"
    [reboot_starting]="🔁 正在重启…"
    [reboot_expired]="⚠️ 超时。请先重新执行 /reboot。"
    [reboot_confirm]="⚠️ 确认: 60 秒内输入 \"/reboot YES\"。"
    [version_fmt]="🤖 Bot %s
📱 %s
🏷  %s
🤖 Android %s (SDK %s)
🐧 %s"

    [common_not_exists_fmt]="❌ 不存在: %s"
    [btn_cancel]="❌ 取消"
    [btn_reboot_now]="🔁 立即重启"

    [csq_excellent]="🟢 极佳"
    [csq_good]="🟢 良好"
    [csq_moderate]="🟡 一般"
    [csq_weak]="🟠 弱"
    [csq_very_weak]="🔴 极弱"
    [csq_unknown]="🔴 未知"

    [alert_temp_fmt]="🌡 警告: CPU 温度过高 — %d°C
(阈值 %d°C, %d 秒内不再警告)"
    [alert_mem_fmt]="💾 警告: RAM 极低 — %d%% 可用
(%d MB)"
    [alert_tunnel]="🔌 警告: Cloudflared 隧道未运行（无进程）"
    [alert_sms_forward_fmt]="📨 收到短信 — %s
👤 %s

%s"

    [chat_greeting_fmt]="%s，我在这里 👋"
    [chat_naber_fmt]="%s! 我的状态:

%s"
    [chat_time_fmt]="🕐 %s"
    [chat_imisin_fmt]="我很好 🙂 (温度 %s, uptime %s)"
    [chat_thanks]="🤖 不客气 👍"
    [chat_morning_fmt]="早上好！☀️ 已运行 %s"
    [chat_night]="你也是 🌙 我保持唤醒"

    [update_header]="🔍 检查模块更新"
    [update_all_current]="所有模块都是最新的。"
    [update_none_defined]="没有模块定义了 updateJson。"
)
