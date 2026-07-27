# Experiment Record: EXP-017 ATC ttyUSB3 Follow Capture Until Disconnect Marker

## Metadata

- Experiment ID: EXP-017
- Date/time: 2026-07-27 16:18 UTC
- Operator: remote run from macOS via SSH one-liner
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon
- Target AT port: /dev/ttyUSB3

## Objective

- Capture live ATC log stream until disconnect marker (or timeout window).
- Validate whether marker-based follow capture yields deeper failure signature than fixed 20s snapshot.

## Procedure

1. Applied profile:
   - `device='/dev/ttyUSB3'`
   - `apn='internet'`
   - `pdptype='IP'`
2. Presence pre-check passed (`presence=ok step=1`).
3. Started `logread -f` to `/tmp/exp017_follow_until_disconnect.log`.
4. Enabled ATC and polled for `is disconnected` marker.
5. Stopped capture, collected status and key lines.
6. Returned to safe-mode (`disable` + `status`).

## Results

- Runtime status during capture:
  - `up=false`
  - `pending=true`
  - `autostart=true`
- No IPv4 on `eth2`.
- Follow capture size:
  - `27` lines (`/tmp/exp017_follow_until_disconnect.log`)
- Key lines captured:
  - `Interface 'wan_fm350_atc' is setting up now`
  - `Initiate modem with interface eth2`
  - `sh: running: unknown operand`
- Disconnect marker was not captured in this window.

## Safe Rollback Validation

- After rollback:
  - `network.wan_fm350_atc.auto='0'`
  - `up=false`
  - `pending=false`
  - `autostart=false`

## Interpretation

- Marker-based follow capture successfully captured a new script-level error signature:
  - `sh: running: unknown operand`
- This strengthens hypothesis of ATC proto/script logic incompatibility, not only link or timing issue.

## Next Action

1. Inspect ATC proto scripts on router for shell tests that can emit `unknown operand`.
2. Correlate captured process ID (`wan_fm350_atc (32215)`) with script branch around modem-init state checks.
