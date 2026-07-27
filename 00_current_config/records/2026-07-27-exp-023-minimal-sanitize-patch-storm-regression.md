# Experiment Record: EXP-023 Minimal Sanitize Patch Still Causes Storm

## Metadata

- Experiment ID: EXP-023
- Date/time: 2026-07-27 16:44 UTC
- Operator: remote run from macOS via SSH alias
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Validate a minimal source-level sanitize patch for `pdp_still_active` with a short bounded run (12s).

## Observed Behavior

- Immediate netifd flap storm reappeared:
  - repeated `Interface 'wan_fm350_atc' is setting up now`
  - repeated `Interface 'wan_fm350_atc' is now down`
- Multiple cycles occurred within the same second.

## Recovery

1. Forced return to safe mode.
2. Confirmed controlled idle state:
   - `up=false`
   - `pending=false`
   - `autostart=false`
3. Restored script from backup:
   - `cp /lib/netifd/proto/atc.sh.bak_exp023 /lib/netifd/proto/atc.sh`
   - command completed: `rollback done`

## Conclusion

- Even a minimal sanitize patch in live `atc.sh` can trigger immediate flap-storm regression in current environment.
- Further in-place script editing on the production router is high-risk and should be paused.

## Next Action

1. Freeze router-side script edits.
2. Continue diagnostics in safe mode only.
3. Prepare offline analysis path (extract script and logs for static review) before any next runtime patch.
