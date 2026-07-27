# Experiment Record: EXP-028 Long-Window A/B and Silent Candidate Pattern

## Metadata

- Experiment ID: EXP-028
- Date/time: 2026-07-27
- Operator: remote run from macOS via reusable runner script
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Increase informative yield by extending window duration.
- Re-check candidate vs baseline behavior under same marker-gated logic.

## Method

- Command:
  - `sh 00_current_config/scripts/run_exp_ab_marker_series.sh fm350-router 12 12 EXP028`
- Trials: 12
- Window size: 12 seconds
- Filters:
  - `valid=1` if no USB-confounder signatures
  - `informative=1` if churn or signal lines exist

## Raw Summary

- CSV header: `trial,kind,valid,informative,updown,unknown,usb,signal`
- Aggregate from runner:
  - BASE valid+informative: `n=4`, mean up/down `5.00`
  - CAND valid+informative: `n=0` (insufficient)
- Integrity:
  - final `/lib/netifd/proto/atc.sh` md5 = `8d536e3353700b0dd854492838c9f53e`

## Key Observation

- Candidate branch showed a near-total silent pattern:
  - all candidate marker-window logs are empty (`0` lines)
  - candidate rows are mostly `valid=1, informative=0, updown=0, signal=0`
- Baseline branch remained active and produced expected ATC lifecycle lines (with periodic USB confounders in some windows).

## Additional Findings

- In one baseline invalid window, script error reappeared as:
  - `sh: OK: unknown operand`
- This indicates the operand issue is still reproducible on baseline under unstable USB conditions.

## Artifacts

- `00_current_config/records/EXP028_artifacts/EXP028_ab_results.csv`
- `00_current_config/records/EXP028_artifacts/EXP028_BASE_T*.log`
- `00_current_config/records/EXP028_artifacts/EXP028_CAND_T*.log`

## Interpretation

- EXP028 did not increase informative candidate coverage; instead it exposed a stronger behavioral divergence: candidate path often produces no observable ATC activity in the marker window.
- This is no longer only a churn-risk question; it is also a candidate no-op/silent-regression risk.

## Conclusion

- Candidate patch remains unsafe for deployment.
- Current evidence supports rejecting candidate both for:
  1. high churn risk in informative windows (EXP026/EXP027),
  2. silent/no-activity behavior in long-window batch (EXP028).

## Next Action

1. Treat empty candidate windows as a first-class regression signal (`silent_window=1`).
2. Add explicit runner summary for silent-window rate by branch.
3. Keep baseline on router and avoid candidate deployment until root cause is isolated.
