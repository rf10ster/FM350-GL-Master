# Experiment Record: EXP-019 ATC unknown operand Root Cause

## Metadata

- Experiment ID: EXP-019
- Date/time: 2026-07-27
- Operator: remote run from macOS via SSH one-liner
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Identify exact script branch that can generate:
  - sh: running: unknown operand

## Procedure

1. Ran targeted scan over `/lib/netifd/proto/atc.sh` with line-number extraction.
2. Printed suspicious windows around line groups 260-320, 340-430, 520-590.
3. Correlated output with previously captured runtime signature.

## Key Finding

Most likely failing condition is in `OK` branch around line ~547:

- `[ $OK_received -eq 10 -a $pdp_still_active -eq 0 ] && { ... }`

Upstream assignment for `pdp_still_active`:

- `pdp_still_active=$(echo $URCvalue | awk -F ',' '{print $2}')`

When field 2 contains non-numeric token (for example `running`), shell numeric compare emits:

- `sh: running: unknown operand`

## Supporting Evidence

- Runtime log in EXP-017 captured:
  - `sh: running: unknown operand`
- EXP-019 targeted dump showed:
  - line with numeric compare using `$pdp_still_active -eq 0`
  - parser assignment from dynamic URC field

## Conclusion

- Root cause is consistent with shell arithmetic/test incompatibility in `atc.sh` when non-numeric PDP state values reach numeric `-eq` test.
- This is a script-level robustness defect in ATC path.

## Next Action

1. Apply reversible hotfix on router:
   - sanitize `pdp_still_active` to numeric before `-eq` comparison,
   - or split condition into guarded numeric check.
2. Re-run bounded ATC test with follow-capture and verify disappearance of `unknown operand` signature.
