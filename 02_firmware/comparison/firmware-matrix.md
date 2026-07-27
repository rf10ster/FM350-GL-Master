# Firmware Comparison Matrix (RU/EN)

RU: Рабочая матрица для сравнения версий прошивки FM350-GL и влияния на сетевой профиль.
EN: Working matrix for comparing FM350-GL firmware versions and profile behavior.

## Usage

1. Add one row per tested firmware build.
2. Link each row to an experiment record.
3. Mark risk level before moving to production usage.

## Matrix

| Firmware ID | Source | Date tested | USB mode(s) | ATC status | DHCP fallback status | Known issues | Rollback artifact | Verdict |
|---|---|---|---|---|---|---|---|---|
| unknown-current | in-device baseline | 2026-07-27 | 40/41 (observed), active 41 | recovered after PDP policy fix | pending | missing pdptype caused SESSION_FAILED in ATC cycle | not yet archived | conditional pass |
| candidate-A | official/custom | YYYY-MM-DD | fill | pass/fail | pass/fail | fill | link | continue/stop |
| candidate-B | official/custom | YYYY-MM-DD | fill | pass/fail | pass/fail | fill | link | continue/stop |

Related records:

- `00_current_config/records/2026-07-27-exp-001-atc-stabilization.md`
- `00_current_config/records/2026-07-27-inc-001-session-failed.md`

## Required Fields per Entry

- `AT+CGMR` output
- active APN and PDP type
- active AT port candidate during test
- `ip addr show eth2` result
- `ip route` result
- ping result to 8.8.8.8

## Risk Labels

- low: no regression, both ATC and fallback verified
- medium: one non-blocking regression with workaround
- high: unstable session, route loss, or repeated `SESSION_FAILED`

## Promotion Rule

Promote firmware to "stable" only after:

1. 3 successful cold-boot cycles
2. 24h soak without route/session loss
3. rollback rehearsal success
