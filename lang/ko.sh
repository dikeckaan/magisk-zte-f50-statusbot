# statusbot 한국어 — community translation seeded by upstream
# Sourced AFTER en.sh; keys here override English. Missing keys fall back.

declare -gA MSG=(
    [lang_current_fmt]="현재 언어: %s"
    [lang_available_header]="사용 가능한 언어:"
    [lang_set_fmt]="언어가 %s로 변경되었습니다. 봇이 3초 후 재시작됩니다."
    [lang_invalid_fmt]="알 수 없는 언어 코드: %s. /lang으로 목록 확인."
    [lang_usage]="사용법: /lang [코드]
인자 없음: 현재 + 사용 가능한 언어 표시.
코드 지정: 전환 후 봇 재시작."

    [greet_morning]="좋은 아침"
    [greet_noon]="좋은 오후"
    [greet_evening]="좋은 저녁"
    [greet_night]="안녕히 주무세요"
    [boot_greeting_fmt]="%s, 가동 중 🤖
%s — uptime: %s
명령어 보기: /help"

    [help_full_fmt]="ZTE F50 봇 — 명령어

📊 상태
/status — 전체 개요
/uptime — 가동 시간
/load — CPU 부하 (상세)
/mem — RAM
/disk — 디스크
/temp — 온도 (CPU)
/ps — 상위 10 프로세스 (CPU)

📡 셀룰러
/signal — 신호 품질 (RSSI, RSRP, RSRQ)
/cellinfo — 통신사 + IMEI + ICCID + 번호
/imei — IMEI(들)
/imei_sorgula [imei] — IMEI 분석 + e-Devlet 조회
/imei_degis <imei> — IMEI 변경 (확인 후 재부팅)
/operator — 통신사만
/qos — QoS / 대역 정보
/sms_list [N] — 최근 N SMS (기본 10)
/sms_count — 받은편지함 총 수
/sms_send <num> <text> — AT 통해 SMS 전송
/at <cmd> — 원시 AT 명령

🌐 네트워크
/ip — 공용 + 로컬 IP
/traffic — 부팅 이후 RX/TX
/ping <host>
/speedtest [cf|ookla|fast] [size] — 속도 테스트
/clients — 연결된 클라이언트 (ARP)
/wifi — 핫스팟 SSID + 비밀번호 + 클라이언트
/tunnel — Cloudflared 상태

🔧 시스템
/modules — Magisk 모듈
/version
/reboot — 재부팅 (확인)
/komut <cmd> — 셸 명령 (취소 가능)
/file <경로> — 기기에서 파일 다운로드
/upload <대상> — 기기로 파일 업로드
/screenshot — 스크린샷
/ramclean [pkg…] — 메모리 정리
/performance [on|off] — ZTE Performance 모드 (재부팅 필요)
/perf_balanced [mhz] — 8 코어 + 주파수 캡 (권장 1800)
/perf_help — 모드 비교 가이드
/minimal_mode [on|persist|off] — 서비스 동결 (~640 MB)
/zte_setpw <pwd> — ZTE 관리자 비밀번호 설정
/lang [code] — 봇 언어 변경

🗂 파일 시스템
/ls <경로>
/cat <파일> — 내용 (4 KB)
/df — 디스크 사용량
/du <dir> — 하위 디렉토리 크기
/log [N] — 봇 로그 마지막 N 줄
/dump_sms — 받은편지함 전체 덤프

🌐 네트워크 (추가)
/connections — 활성 TCP
/listening — 리스닝 포트
/dhcp — DHCP 임대 테이블
/dns — DNS 구성

⚡ 전원 / 커널
/cpu_freq — CPU 주파수
/cpu_governor [name] — Governor 표시/변경
/wakelock — 활성 웨이크락

📦 앱
/installed [3rd|disabled|system|all]
/freeze <pkg> — 패키지 동결
/unfreeze <pkg> — 패키지 해제

⏰ 스케줄
/alarm HH:MM <msg> — 1회
/schedule <sec> <cmd> — 반복
/schedule list / clear / cancel <idx>
/heartbeat <시간> — 주기적 핑
/quiet_hours <부터> <까지> — 조용한 시간

🔒 보안
/who — 활성 SSH/ADB 세션
/last_boot — 부팅 기록
/bot_stats — 봇 내부 통계
/restart_bot — 봇 재시작
/update [all|<id>] — GitHub에서 모듈 업데이트

🌍 Tailscale (선택 모듈)
/tailscale auth <key> — auth-key 저장
/tailscale on / off — 시작/중지
/tailscale status — 상태 + RAM
/tailscale ip / peers / log / logout

🔔 자동 (백그라운드):
• 수신 SMS 전달
• 온도 > %d°C, RAM < %d%%, tunnel down 시 경고
• Heartbeat (설정 시) 및 스케줄
• Quiet hours는 경고 억제

💬 채팅 트리거
selam, merhaba, sa — 인사
naber — 상태 + 인사
saat — 기기 시간
iyi misin — 상태 확인"

    [uptime_days_fmt]="%d일 %02d시 %02d분"
    [uptime_hours_fmt]="%d시 %02d분"
    [uptime_short_fmt]="%d분 %02d초"
    [disk_fmt]="%s / %s (%s 사용)"

    [load_status_calm]="🟢 한가함 (%d%%)"
    [load_status_active]="🟡 활성 (%d%%)"
    [load_status_full]="🟠 가득참 (%d%%)"
    [load_status_busy]="🔴 바쁨 (%d%%)"
    [load_full_fmt]="📊 CPU 부하 (%d 코어)

지금 (1분):       %s
최근 5분:         %s
최근 15분:        %s

상태: %s

가이드:
  %d.0 = 모든 CPU 풀가동
  < %d.0 = 여유 있음
  > %d.0 = 큐 발생, 지연 가능"

    [status_model_fmt]="📱 %s\n"
    [status_uptime_fmt]="⏱  Uptime: %s\n"
    [status_ram_fmt]="💾 RAM: %s\n"
    [status_disk_fmt]="💿 디스크: %s\n"
    [status_temp_fmt]="🌡  온도: %s\n"
    [status_perf_on]="⚡ Performance: ON 🟢\n"
    [status_perf_off]="⚡ Performance: OFF ⚪\n"
    [status_operator_fmt]="📡 통신사: %s\n"
    [status_signal_fmt]="📶 신호: RSSI %s (%s)\n"
    [status_public_ip_fmt]="🌐 공용 IP: %s"

    [perf_status_on]="⚡ Performance 모드: ON 🟢
끄기: /performance off"
    [perf_status_off]="⚡ Performance 모드: OFF ⚪
켜기: /performance on"
    [perf_no_password]="❌ ZTE 비밀번호 미설정. 먼저: /zte_setpw <pwd>"
    [perf_login_failed]="❌ ZTE 로그인 실패. 비밀번호가 틀렸을 수 있음. /zte_setpw로 업데이트."
    [perf_login_failed_short]="❌ ZTE 로그인 실패."
    [perf_set_failed_fmt]="❌ 설정 실패: %s"
    [perf_enabled_reboot]="⚡ Performance 모드 활성화 🟢
변경 적용을 위해 재부팅하세요."
    [perf_disabled_reboot]="⚡ Performance 모드 비활성화 ⚪
변경 적용을 위해 재부팅하세요."
    [perf_usage]="사용법: /performance [on|off|status]"

    [zte_pw_set_fmt]="ZTE 비밀번호 설정됨 (길이: %d 바이트).
변경: /zte_setpw <새_pwd>"
    [zte_pw_usage]="사용법: /zte_setpw <pwd>
(ZTE 웹 관리 비밀번호 — /performance 등에 사용)"
    [zte_pw_saved_fmt]="✓ ZTE 비밀번호 저장 (%d 바이트).
테스트: /performance"
    [iptal_imei]="  ✓ IMEI 조회"
    [iptal_upload]="  ✓ 대기 중인 업로드"
    [iptal_speedtest]="  ✓ Speedtest 루프"
    [iptal_none]="취소할 대기 항목 없음"
    [iptal_done_fmt]="🛑 취소됨:%s"
    [reboot_starting]="🔁 재부팅 시작…"
    [reboot_expired]="⚠️ 시간 초과. /reboot을 다시 실행하세요."
    [reboot_confirm]="⚠️ 확인: 60초 내에 \"/reboot YES\" 입력."
    [version_fmt]="🤖 Bot %s
📱 %s
🏷  %s
🤖 Android %s (SDK %s)
🐧 %s"

    [common_not_exists_fmt]="❌ 존재하지 않음: %s"
    [btn_cancel]="❌ 취소"
    [btn_reboot_now]="🔁 지금 재부팅"

    [csq_excellent]="🟢 우수"
    [csq_good]="🟢 좋음"
    [csq_moderate]="🟡 보통"
    [csq_weak]="🟠 약함"
    [csq_very_weak]="🔴 매우 약함"
    [csq_unknown]="🔴 알 수 없음"

    [alert_temp_fmt]="🌡 경고: CPU 온도 높음 — %d°C
(임계값 %d°C, %d초 동안 재경고 없음)"
    [alert_mem_fmt]="💾 경고: RAM 매우 낮음 — %d%% 사용 가능
(%d MB)"
    [alert_tunnel]="🔌 경고: Cloudflared tunnel 미실행 (프로세스 없음)"
    [alert_sms_forward_fmt]="📨 수신 SMS — %s
👤 %s

%s"

    [chat_greeting_fmt]="%s, 여기 있어요 👋"
    [chat_naber_fmt]="%s! 내 상태:

%s"
    [chat_time_fmt]="🕐 %s"
    [chat_imisin_fmt]="잘 지내요 🙂 (temp %s, uptime %s)"
    [chat_thanks]="🤖 천만에요 👍"
    [chat_morning_fmt]="좋은 아침! ☀️ 부팅 이후 %s"
    [chat_night]="당신도 🌙 저는 깨어있겠습니다"

    [update_header]="🔍 모듈 업데이트 확인"
    [update_all_current]="모든 모듈이 최신 상태입니다."
    [update_none_defined]="updateJson이 정의된 모듈이 없습니다."
)
