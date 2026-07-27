# Experiment Record: EXP-018 ATC Script Source Scan for unknown operand

## Metadata

- Experiment ID: EXP-018
- Date/time: 2026-07-27
- Operator: remote run from macOS via SSH one-liner
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Identify likely source of runtime signature:
  - sh: running: unknown operand
- Narrow scope from broad filesystem grep to ATC proto script candidates.

## Procedure

1. Ran broad grep over `/lib/netifd/proto/*.sh`, `/usr/bin/*`, `/sbin/*`.
2. Listed ATC-related proto scripts.
3. Attempted to dump ATC script with line numbers.

## Findings

- ATC proto candidates confirmed:
  - `/lib/netifd/proto/atc.sh`
  - `/lib/netifd/proto/3g.sh`
  - `/lib/netifd/proto/mbim.sh`
- In `atc.sh`, shell conditions with `-a` and mixed comparisons are present at least at:
  - line 109
  - line 298
  - line 371
  - line 402
  - line 547
- Script dump failed due to missing utility on router:
  - `ash: nl: not found`

## Interpretation

- Broad scan produced high noise from BusyBox binaries and is not suitable for root-cause isolation.
- Most probable source remains logic inside `/lib/netifd/proto/atc.sh`, especially compound `[` tests with `-a` and values that may become non-numeric (for example `running`).

## Next Action

1. Run targeted atc.sh-only dump with `sed -n` and explicit line windows.
2. Capture function around line ~547 and all occurrences of `running`, `OK_received`, `pdp_still_active`, `-eq`, `-a`.
