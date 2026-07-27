# FM350-GL Architecture (v1.1)

RU: Каноничная модель проекта для воспроизводимой настройки с нуля.
EN: Canonical project model for reproducible zero-to-online setup.

## 1. Canonical Profiles

- Primary profile: `wan_fm350_atc` (ATC-managed data session)
- Fallback profile: `wan_modem` (DHCP on `eth2`)

RU: По умолчанию используйте ATC-профиль. DHCP-профиль включается только как fallback-ветка.
EN: Use ATC as default. Enable DHCP only as an explicit fallback branch.

## 2. Interface Naming Rules

- Logical interface (ATC): `wan_fm350_atc`
- Logical interface (fallback): `wan_modem`
- USB network device for fallback: `eth2` (if present in your current USB mode)
- WWAN naming may vary by mode/driver and is not used as canonical fallback target.

RU: В документации используем именно эти имена, чтобы избежать расхождений.
EN: These names are mandatory in docs to avoid drift.

## 3. PDP Policy (Critical)

- Required for ATC flow: `pdptype='IP'`
- APN example: `internet.beeline.ru`

RU: Если `pdptype` не задан, возможен `SESSION_FAILED` из-за пустого типа PDP при `CGDCONT`.
EN: Missing `pdptype` can cause `SESSION_FAILED` due to empty PDP type in `CGDCONT`.

## 4. AT Port Drift Policy

- Do not assume static AT port index.
- Re-check active port after reconnect/reboot:
  - `ls -la /dev/ttyUSB*`
  - `dmesg | tail -30`

RU: При смене ttyUSB-порта сначала подтверждайте рабочий порт, затем выполняйте AT-шаги.
EN: Always re-identify the active AT port before running AT commands.

## 5. Decision Gates (ATC -> DHCP Fallback)

Switch from ATC path to DHCP fallback only if at least one condition is true:

1. Repeated ATC bring-up attempts end with `SESSION_FAILED` after PDP checks.
2. AT port is unstable/unavailable after controlled retry window.
3. You need temporary internet recovery while AT diagnostics are in progress.

Return to ATC path after root cause is fixed.

## 6. Evidence Artifacts Per Stage

Collect and attach at each checkpoint:

1. `uci show network | grep -E 'wan_fm350_atc|wan_modem'`
2. `ubus call network.interface.wan_fm350_atc status` (or fallback interface)
3. `ip addr show eth2`
4. `ip route`
5. Relevant `logread` and `dmesg` snippets

RU: Артефакты обязательны для воспроизводимости и сравнения экспериментов.
EN: Artifacts are mandatory for reproducibility and experiment comparison.
