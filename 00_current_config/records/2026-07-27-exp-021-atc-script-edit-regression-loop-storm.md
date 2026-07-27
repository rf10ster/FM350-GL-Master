# Experiment Record: EXP-021 ATC Script Edit Regression (Setup/Down Loop Storm)

## Metadata

- Experiment ID: EXP-021
- Date/time: 2026-07-27 16:31 UTC
- Operator: remote run from macOS via SSH
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Validate post-hotfix behavior and rollback safety.

## Observed Event

- During run, netifd entered high-frequency flap storm:
  - repeated `Interface 'wan_fm350_atc' is setting up now`
  - repeated `Interface 'wan_fm350_atc' is now down`
  - many cycles within ~2 seconds.

## Impact

- ATC path became unstable/noisy and unusable for clean diagnostics in that state.

## Recovery Actions

1. Forced safe mode via loop-breaker (`auto=0`, `ifdown`).
2. Performed script rollback from backup:
   - `cp /lib/netifd/proto/atc.sh.bak_exp021 /lib/netifd/proto/atc.sh`
3. Confirmed command success (`rollback done`).

## Post-Recovery State

- Safe mode active (`autostart=false`, `pending=false`) in captured status snapshot before rollback command.
- Rollback command completed without error.

## Conclusion

- ATC script edits can trigger immediate netifd flap storms.
- Mandatory guardrails for further script experiments:
  - keep `auto=0` as default during patching,
  - always create dedicated backup before each attempt,
  - apply one minimal change per run,
  - rollback immediately on setup/down storm signature.

## Next Action

1. Before any next patch, verify baseline script hash and line content around modified section.
2. Test future patch with very short bounded window (10-15s) and immediate storm detector.
