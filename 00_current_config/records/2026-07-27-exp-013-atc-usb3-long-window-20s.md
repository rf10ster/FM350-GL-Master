# Experiment Record: EXP-013 ATC ttyUSB3 Long Window (20s)

## Metadata

- Experiment ID: EXP-013
- Date/time: 2026-07-27 16:11 UTC
- Operator: remote run from macOS via SSH one-liner
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon
- Target AT port: `/dev/ttyUSB3`

## Objective

- Extend bounded ATC capture window from 8s to 20s.
- Verify whether longer window yields deeper ATC failure signatures while keeping safe-mode rollback.

## Procedure

1. Set profile:
   - `device='/dev/ttyUSB3'`
   - `apn='internet'`
   - `pdptype='IP'`
2. Presence pre-check passed (`ttyUSB3 + eth2`, step 1).
3. Ran `sh /tmp/atc_loop_breaker.sh enable` and waited 20s.
4. Captured status and critical log tail.
5. Returned to safe-mode via `disable` + `status`.

## Results

### During 20s window

- Interface status remained:
  - `up=false`
  - `pending=true`
  - `autostart=true`
- No IPv4 address on `eth2`.
- Critical tail showed repeated setup cycle markers:
  - `Interface 'wan_fm350_atc' is setting up now`
  - `Initiate modem with interface eth2`
  - `wan_fm350_atc is disconnected`
  - `Interface 'wan_fm350_atc' is now down`
- In this sample, tail did not include deeper AT-command lines (`Could not write`, `AT+EIAAPN`) despite longer wait.

### After safe-mode rollback

- `network.wan_fm350_atc.auto='0'`
- Controlled state restored:
  - `up=false`
  - `pending=false`
  - `autostart=false`

## Interpretation

- 20s window confirms repeatable setup -> disconnect lifecycle on ttyUSB3.
- Missing deep AT-command lines in this capture suggests tail contamination/timing effects and need for marker-based log slicing.

## Next Action

1. Use marker-tagged logging to isolate only lines generated after the start of each run.
2. Keep M2 rollback mandatory after each attempt.
