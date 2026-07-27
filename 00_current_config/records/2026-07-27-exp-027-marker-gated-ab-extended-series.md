# Experiment Record: EXP-027 Marker-Gated A/B Extended Series

## Metadata

- Experiment ID: EXP-027
- Date/time: 2026-07-27
- Operator: remote run from macOS via reusable runner script
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Increase confidence vs EXP-026 using a larger A/B batch.
- Keep USB-confounder gate and non-informative window filter.
- Preserve baseline script integrity after the run.

## Method

- Command:
  - `sh 00_current_config/scripts/run_exp_ab_marker_series.sh fm350-router 12 6 EXP027`
- Trials: 12 (BASE + CAND per trial)
- Window size: 6 seconds
- Filters:
  - `valid=1` only if no USB disconnect/re-enumeration signatures
  - `informative=1` if `updown>0` OR one of signal lines is present

## Raw Results Snapshot

- Header: `trial,kind,valid,informative,updown,unknown,usb,signal`
- Key rows:
  - `1,BASE,1,1,1,0,0,1`
  - `1,CAND,0,1,242,0,11,0`
  - `2,BASE,1,1,3,0,0,1`
  - `2,CAND,1,1,1057,0,0,0`
  - `3,BASE,1,1,3,0,0,1`
  - `3,CAND,1,0,0,0,0,0`
  - ... (full CSV in artifacts)

## Aggregated Summary

- `valid+informative` windows:
  - BASE: `n=9`, mean up/down = `2.78`
  - CAND: `n=1`, mean up/down = `1057.00`
- `unknown operand`:
  - `0` across all windows
- Integrity:
  - final `/lib/netifd/proto/atc.sh` md5 = `8d536e3353700b0dd854492838c9f53e`

## Artifacts

- `00_current_config/records/EXP027_artifacts/EXP027_ab_results.csv`
- `00_current_config/records/EXP027_artifacts/EXP027_BASE_T*.log`
- `00_current_config/records/EXP027_artifacts/EXP027_CAND_T*.log`

## Interpretation

- Evidence still points to candidate churn amplification risk when a candidate window is informative.
- Statistical confidence remains limited because informative candidate yield is too low (`1` window).
- Many candidate windows are valid but non-informative (empty), so they cannot support causal magnitude estimates.

## Conclusion

- Candidate patch remains high-risk and is not suitable for production deployment in current state.
- Stronger causal confidence now depends on increasing informative candidate windows, not just total trials.

## Next Action

1. Raise capture window to 10-12 seconds for next batch to increase candidate informative yield.
2. Require acceptance threshold before verdict publication, for example:
   - candidate informative windows >=5 and baseline informative windows >=5.
3. Keep baseline script on router between all test batches.
