# Experiment Record: EXP-016 ATC ttyUSB3 Follow Capture (20s)

## Metadata

- Experiment ID: EXP-016
- Date/time: 2026-07-27 16:17 UTC
- Operator: remote run from macOS via SSH one-liner
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon
- Target AT port: /dev/ttyUSB3

## Objective

- Replace unreliable static line-delta extraction with bounded live stream capture via `logread -f`.
- Verify whether critical ATC signatures appear within a 20s bounded attempt.

## Procedure

1. Applied profile:
   - `device='/dev/ttyUSB3'`
   - `apn='internet'`
   - `pdptype='IP'`
2. Presence pre-check passed (`presence=ok step=1`).
3. Started `logread -f` capture to `/tmp/exp016_logread_follow.log`.
4. Ran `sh /tmp/atc_loop_breaker.sh enable`, waited 20s.
5. Stopped follower and analyzed captured file.
6. Returned to safe-mode (`disable` + `status`).

## Results

- During attempt:
  - `up=false`
  - `pending=true`
  - `autostart=true`
- No IPv4 on `eth2`.
- Follow-capture artifact:
  - `/tmp/exp016_logread_follow.log`
  - `57` lines captured.
- Critical signatures found:
  - `Interface 'wan_fm350_atc' is setting up now`
  - `Initiate modem with interface eth2`
- Not observed in this 20s window:
  - `is disconnected`
  - `Could not write to COM device`
  - `Error running AT-command`
  - `AT+EIAAPN`

## Safe Rollback Validation

- After rollback:
  - `network.wan_fm350_atc.auto='0'`
  - `up=false`
  - `pending=false`
  - `autostart=false`

## Interpretation

- Live capture method is valid and produces non-empty artifacts.
- 20s window can still end before first disconnect/AT-error phase for this run.

## Next Action

1. Increase bounded window (45-60s) or terminate capture after first `is disconnected` marker.
2. Keep mandatory M2 rollback after capture.
