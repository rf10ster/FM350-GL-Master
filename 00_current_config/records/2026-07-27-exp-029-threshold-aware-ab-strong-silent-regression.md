# Experiment Record: EXP-029 Threshold-Aware A/B with Strong Silent Regression

## Metadata

- Experiment ID: EXP-029
- Date/time: 2026-07-27
- Operator: remote run from macOS via reusable runner script
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Use upgraded runner with confidence gates and silent-window metrics.
- Attempt to reach minimum informative windows in both branches.
- Validate whether longer repeated sampling changes EXP028 conclusion.

## Method

- Command:
  - `sh 00_current_config/scripts/run_exp_ab_marker_series.sh fm350-router 20 12 EXP029 5 5`
- Trials: 20 (BASE + CAND)
- Window size: 12 seconds
- Gates:
  - `valid=1` if no USB-confounder signatures
  - `informative=1` if churn or signal lines are present
  - `silent=1` if both `updown=0` and `signal=0`
- Early stop condition:
  - stop only if both informative thresholds reached (`BASE>=5` and `CAND>=5`)

## Raw Artifact Status

- CSV rows: 41 lines total (header + 40 data rows)
- Artifact directory:
  - `00_current_config/records/EXP029_artifacts/`
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
- CAND:
  - total windows: `20`
  - valid windows: `20`
  - valid+informative windows: `0`
  - mean up/down on valid+informative: `n/a`
  - silent windows: `20` (`100.0%`)
  - unknown operand total: `0`

## Strong Contrast Evidence

- Total marker-log lines by branch:
  - BASE logs: `400` lines
  - CAND logs: `0` lines
- Candidate branch produced fully silent windows in every trial.

## Threshold Outcome

- Informative thresholds were not met:
  - BASE reached threshold (`7/5`)
  - CAND did not (`0/5`)
- Result confidence for churn magnitude remains limited for candidate because there are no informative candidate windows.

## Integrity

- Post-run router baseline hash:
  - `/lib/netifd/proto/atc.sh` md5 `8d536e3353700b0dd854492838c9f53e`

## Interpretation

- EXP029 strengthens EXP028 conclusion from pattern-level to deterministic behavior in this setup:
  - candidate path is not merely low-signal; it is systematically silent (`100%` silent windows).
- This is a high-priority regression class (no-op / early-abort behavior), independent of churn metrics.

## Conclusion

- Candidate patch remains unsafe for deployment.
- Reject candidate based on two independent risk modes:
  1. churn amplification when informative windows occur (EXP026/EXP027),
  2. systematic silent regression under repeated long-window threshold-aware run (EXP029).

## Next Action

1. Keep baseline script on router (no candidate deployment).
2. Add explicit runner exit code when `CAND informative == 0` after max trials.
3. Add root-cause probes in candidate window (pre/post markers around ifup return code and atc process launch path).
