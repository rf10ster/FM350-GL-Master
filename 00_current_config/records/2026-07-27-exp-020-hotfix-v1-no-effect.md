# Experiment Record: EXP-020 Hotfix v1 (No Effect)

## Metadata

- Experiment ID: EXP-020
- Date/time: 2026-07-27 16:27 UTC
- Operator: remote run from macOS via SSH heredoc
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon
- Target AT port: /dev/ttyUSB3

## Objective

- Validate first reversible hotfix for `unknown operand` by replacing compound test in `atc.sh`.

## Procedure

1. Backup created on router:
   - `/lib/netifd/proto/atc.sh.bak_exp020`
2. Applied scripted `sed -i` replacement of condition:
   - from numeric combined test to string-guarded test.
3. Ran bounded follow-capture (30s) in active ATC setup window.
4. Returned system to safe-mode (`auto=0`) via loop-breaker.

## Results

- Interface state during run remained:
  - `up=false`
  - `pending=true`
- Key logs still include the same failure:
  - `sh: running: unknown operand`
- Safe rollback after run succeeded:
  - `up=false`
  - `pending=false`
  - `autostart=false`

## Interpretation

- Hotfix v1 did not eliminate the runtime error.
- Most likely causes:
  1. replacement did not hit the effective line in `atc.sh`,
  2. `unknown operand` is emitted by another numeric compare path in the same script,
  3. both apply together.

## Next Action

1. Patch by adding numeric sanitization immediately after `pdp_still_active` assignment.
2. Re-run bounded follow-capture and compare for disappearance of `unknown operand`.
