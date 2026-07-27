# Experiment Record: EXP-012 Paired Bounded Test ttyUSB1 vs ttyUSB3

## Metadata

- Experiment ID: EXP-012
- Date/time: 2026-07-27 16:09 UTC
- Operator: remote run from macOS via SSH one-liner
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Perform paired bounded one-shot attempts on `ttyUSB1` and `ttyUSB3` in one run.
- Enforce pre-check for `ttyUSBx + eth2` presence before each `enable`.
- Return to safe-mode after each attempt.

## Procedure

1. For each device in `/dev/ttyUSB1`, `/dev/ttyUSB3`:
   - apply UCI (`device`, `apn=internet`, `pdptype=IP`),
   - verify presence (`tty` + `eth2`),
   - run `sh /tmp/atc_loop_breaker.sh enable`, wait 8s,
   - capture `ubus`, `ip`, filtered logs,
   - run `disable` and `status`.

## Results

### ttyUSB1

- Presence pre-check passed immediately: `presence=ok step=1`.
- ATC state during window:
  - `up=false`, `pending=true`, `autostart=true`.
- Log window captured setup start:
  - `Interface 'wan_fm350_atc' is setting up now`
  - `Initiate modem with interface eth2`
- No IPv4 obtained.
- After `disable`: stable safe-mode (`auto=0`, `pending=false`, `autostart=false`).

### ttyUSB3

- Presence pre-check passed immediately: `presence=ok step=1`.
- ATC state transitioned within window:
  - initial `pending=false` right after enable snapshot,
  - then `pending=true` in follow-up status.
- Log window captured:
  - `Initiate modem with interface eth2`
  - `wan_fm350_atc is disconnected`
  - interface down -> setting up again
- No IPv4 obtained.
- After `disable`: stable safe-mode (`auto=0`, `pending=false`, `autostart=false`).

## Conclusion

- With strict pre-checks, both ports still fail to establish data session/IP.
- Bounded 8s window confirms setup start and early failure behavior, but does not always include deeper AT-command errors in tail.
- M2 safe-mode remains reproducible and effective as an experiment guardrail.

## Next Action

1. Capture a tighter first-failure window with timestamped `logread` extraction around first `is disconnected` event.
2. Compare `ttyUSB1` and `ttyUSB3` using identical bounded run, but longer post-enable capture (15-20s) to include AT command failure lines when present.
