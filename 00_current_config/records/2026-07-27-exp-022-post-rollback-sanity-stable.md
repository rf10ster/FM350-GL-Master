# Experiment Record: EXP-022 Post-Rollback Sanity Stable

## Metadata

- Experiment ID: EXP-022
- Date/time: 2026-07-27
- Operator: remote run from macOS via SSH
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Verify system state after rollback from script-edit regression.
- Confirm that flap storm is no longer active before next patch attempt.

## Sanity Command Outcome

- UCI profile:
  - `proto='atc'`
  - `device='/dev/ttyUSB3'`
  - `apn='internet'`
  - `pdptype='IP'`
  - `auto='0'`
- Interface status:
  - `up=false`
  - `pending=false`
  - `autostart=false`
  - `available=true`
- Tail filter did not print new storm lines in this snapshot.

## Conclusion

- Post-rollback baseline is stable and controlled.
- Safe-mode remains active and suitable for short bounded patch validation.

## Next Action

1. Apply one-line guarded sanitization patch only.
2. Run very short bounded window (10-15s) with follow-capture.
3. Roll back immediately if setup/down storm appears.
