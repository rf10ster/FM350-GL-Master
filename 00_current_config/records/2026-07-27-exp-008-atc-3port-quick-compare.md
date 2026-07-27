# Experiment Record: EXP-008 ATC 3-Port Quick Compare

## Metadata

- Experiment ID: EXP-008
- Date/time: 2026-07-27 15:56-15:57 UTC
- Operator: live SSH session
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Complete comparable quick-cycle across `ttyUSB3/ttyUSB2/ttyUSB1`.
- Verify whether any port provides immediate recoverable ATC behavior under current degraded state.

## Procedure

1. Ran `/tmp/fm350_atc_3port_quick.sh`.
2. For each port:
   - set `network.wan_fm350_atc.device`
   - `ifdown/ifup wan_fm350_atc`
   - wait 5s and capture status
3. Logged presence snapshot (`exists` + `eth2`) and ATC status.

## Results

- `/dev/ttyUSB3`:
  - `exists=0`, `eth2=no`
  - `up=false`, `pending=true`, `ip4=none`
- `/dev/ttyUSB2`:
  - `exists=0`, `eth2=no`
  - `up=false`, `pending=true`, `ip4=none`
- `/dev/ttyUSB1`:
  - `exists=0`, `eth2=no`
  - `up=false`, `pending=true`, `ip4=none`

## Critical Errors in Same Window

- `notify_proto ... (Permission denied)`
- `No interface could be found yet`
- historical tail still contains:
  - `Could not write to COM device. (1)`

## Conclusion

- None of the three tty ports gave a successful ATC state in quick-cycle.
- During this run all tested tty devices were absent at probe moment (`exists=0`) and `eth2` absent.
- Port switching alone is insufficient in current ATC failure mode.

## Next Action

1. Keep ATC from automatic relaunch loops (loop-breaker mode) while collecting clean diagnostics.
2. Re-test 3-port cycle only after confirmed stable device presence (`ttyUSB*` and `eth2`).
