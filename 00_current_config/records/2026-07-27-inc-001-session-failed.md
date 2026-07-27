# Incident Report: INC-001 SESSION_FAILED on ATC

## Header

- Incident ID: INC-001
- Date/time (local): 2026-07-27
- Author: local session
- Device/router: FM350-GL + GL.iNet MT3000 (OpenWrt 24.10.7)
- Active profile: wan_fm350_atc

## Symptom

- Short summary: ATC interface could not obtain working session and failed with SESSION_FAILED.
- First observed at: during ATC bring-up cycle after USB mode experiments.
- Impact: no stable modem WAN route through ATC path.

## Recent Changes Before Incident

1. Configuration changes: multiple bring-up attempts; APN configured but pdptype missing.
2. USB reconnect/reboot events: yes, leading to ttyUSB index drift.
3. Firmware or script changes: no firmware change confirmed during this incident.

## Evidence Block

- ttyUSB drift observed between /dev/ttyUSB1 and /dev/ttyUSB3.
- /dev/ttyUSB1 did not respond in tested cycle; /dev/ttyUSB3 responded with AT output.
- GTUSBMODE effective values on this firmware path observed as 40/41 with stable operation at 41.
- CGDCONT path in ATC flow was formed with empty PDP type before fix.
- CGACT step failed until PDP type was set explicitly.
- Manual correction succeeded:
  - AT+CGDCONT=1,"IP","internet.beeline.ru"
  - AT+CGACT=1,1
  - Result: +CGEV: ME PDN ACT 1 and OK

## Decision Tree Path

- Followed branch: ATC bring-up fails with SESSION_FAILED.
- Checkpoint results:
  1. Interface exists: pass
  2. AT command response on initial port: fail
  3. Alternate AT port response: pass
  4. PDP policy check: fail (missing pdptype)
  5. Corrective PDP set and activation retry: pass

## Root Cause

- Confirmed cause: missing pdptype in UCI profile resulted in invalid PDP context initialization for this ATC cycle.
- Confidence level: high

## Resolution

- Actions taken:
  1. Re-identified active AT port.
  2. Manually set PDP context with explicit type IP.
  3. Activated PDP context successfully.
- Recovery time: within same troubleshooting session after corrective AT commands.
- Final status: session activation recovered for current cycle; persistent config update still required for long-term stability.

## Follow-up

1. Preventive changes:
   - set and persist option pdptype='IP' in wan_fm350_atc profile.
2. Docs to update:
   - ARCHITECTURE and setup guides already updated with PDP policy and AT port drift handling.
3. Scripts to update:
   - dynamic ttyUSB detection already implemented in package 3.
