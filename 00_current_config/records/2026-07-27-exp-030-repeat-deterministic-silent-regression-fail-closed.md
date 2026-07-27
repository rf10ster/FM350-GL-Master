# Experiment Record: EXP-030 Repeat Deterministic Silent Regression, Fail-Closed

## Metadata

- Experiment ID: EXP-030
- Date/time: 2026-07-27
- Operator: remote run from macOS via reusable runner script
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Repeat EXP-029 with the same threshold-aware runner.
- Confirm whether candidate silence reproduces deterministically under the same setup.
- Preserve fail-closed behavior and fetched artifacts even when thresholds are not met.

## Method

- Command:
  - `sh 00_current_config/scripts/run_exp_ab_marker_series.sh fm350-router 20 12 EXP030 5 5`
- Trials: 20
- Window size: 12 seconds
- Gates:
  - `valid=1` if no USB-confounder signatures
  - `informative=1` if churn or signal lines are present
  - `silent=1` if both `updown=0` and `signal=0`
- Exit policy:
  - fail closed with non-zero exit when informative thresholds are not met

## Raw Artifact Status

- CSV rows: 41 lines total (header + 40 data rows)
- Artifact directory:
  - `00_current_config/records/EXP030_artifacts/`
- Header schema:
  - `trial,kind,valid,informative,updown,unknown,usb,signal,silent`

## Aggregated Results

- BASE:
  - total windows: `20`
  - valid windows: `7`
  - valid+informative windows: `7`
  - mean up/down on valid+informative: `5.00`
  - silent windows: `0` (`0.0%`)
  - unknown operand total: `6`
  - USB confounder count: `84`
- CAND:
  - total windows: `20`
  - valid windows: `20`
  - valid+informative windows: `0`
  - mean up/down on valid+informative: `n/a`
  - silent windows: `20` (`100.0%`)
  - unknown operand total: `0`
  - USB confounder count: `0`

## Threshold Outcome

- BASE threshold reached (`7/5`)
- CAND threshold not reached (`0/5`)
- Runner exited with status `3` as intended by fail-closed policy.

## Integrity

- Post-run router baseline hash:
  - `/lib/netifd/proto/atc.sh` md5 `8d536e3353700b0dd854492838c9f53e`

## Interpretation

- EXP030 reproduces EXP029: candidate remains completely silent under the same long-window threshold-aware setup.
- This supports the hypothesis that candidate silence is deterministic in the current environment, not an isolated one-off.
- The fail-closed runner behavior is working as intended and preserves artifacts for analysis.

## Conclusion

- Candidate patch remains unsafe for deployment.
- EXP030 confirms deterministic silent-regression behavior on repeat.
- Baseline path remains informative and stable enough for comparison, but candidate contributes no informative windows.

## Next Action

1. Keep baseline on router.
2. Do not deploy candidate.
3. If further root-cause work is needed, shift from batch comparison to candidate launch-path tracing and early-abort analysis.
