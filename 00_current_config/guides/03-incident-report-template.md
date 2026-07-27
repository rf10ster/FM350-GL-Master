# 03 Incident Report Template (RU/EN)

RU: Шаблон отчета по инциденту для повторяемой диагностики.
EN: Incident report template for reproducible diagnostics.

## Header

- Incident ID:
- Date/time (local):
- Author:
- Device/router:
- Active profile (`wan_fm350_atc` or `wan_modem`):

## Symptom

- Short summary:
- First observed at:
- Impact:

## Recent Changes Before Incident

1. Configuration changes:
2. USB reconnect/reboot events:
3. Firmware or script changes:

## Evidence Block (Mandatory)

Paste outputs for:

1. `uci show network | grep -E 'wan_fm350_atc|wan_modem'`
2. `ubus call network.interface.wan_fm350_atc status` (or fallback)
3. `ip addr show eth2`
4. `ip route`
5. `ls -la /dev/ttyUSB*`
6. `dmesg | tail -30`
7. relevant `logread` lines
8. AT command outputs used during diagnosis

## Decision Tree Path

- Which branch from `04_knowledge_base/troubleshooting/decision-tree.md` was followed:
- Result at each checkpoint:

## Root Cause

- Confirmed cause:
- Confidence level (low/medium/high):

## Resolution

- Actions taken:
- Recovery time:
- Final status:

## Follow-up

1. Preventive changes:
2. Docs to update:
3. Scripts to update:
