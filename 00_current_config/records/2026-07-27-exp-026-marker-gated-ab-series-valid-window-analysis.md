# Experiment Record: EXP-026 Marker-Gated A/B Series (Valid-Window Analysis)

## Metadata

- Experiment ID: EXP-026
- Date/time: 2026-07-27 16:53 UTC
- Operator: remote run from macOS via SSH heredoc
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Run repeated marker-gated baseline vs candidate windows.
- Reject windows with USB disconnect/re-enumeration events.
- Compare up/down churn only on valid windows.

## Test Design

- Trials: 3
- Window size: 6 seconds per run
- Sequence per trial:
  1. baseline window
  2. candidate window
- Validity rule:
  - invalid if marker window contains any of:
    - `USB disconnect`
    - `eth2: unregister`
    - `ttyUSB* ... disconnected`
    - `new SuperSpeed USB device`
- Rollback policy:
  - baseline script restored after series
  - safe mode re-enabled (`auto=0`, `ifdown`) after each window

## Candidate Patch Under Test

1. Sanitize `pdp_still_active` after `+CGACT` parse with `case` fallback to `0`.
2. Replace compound numeric test:
   - from: `[ $OK_received -eq 10 -a $pdp_still_active -eq 0 ]`
   - to: `[ "$OK_received" -eq 10 ] && [ "$pdp_still_active" -eq 0 ]`

## Raw Results

- CSV artifact (`trial,kind,valid,updown,unknown,usb`):
  - `1,BASE,1,1,0,0`
  - `1,CAND,0,243,0,11`
  - `2,BASE,1,3,0,0`
  - `2,CAND,1,1006,0,0`
  - `3,BASE,1,3,0,0`
  - `3,CAND,1,0,0,0`

## Valid-Window Summary

- BASE valid windows: `n=3`, mean up/down = `2.33`
- CAND valid windows: `n=2`, mean up/down = `503.00`
- `unknown operand` count: `0` in all windows

## Artifacts

- `00_current_config/records/exp026_artifacts/exp026_ab_results.csv`
- `00_current_config/records/exp026_artifacts/EXP026_BASE_T1.log`
- `00_current_config/records/exp026_artifacts/EXP026_BASE_T2.log`
- `00_current_config/records/exp026_artifacts/EXP026_BASE_T3.log`
- `00_current_config/records/exp026_artifacts/EXP026_CAND_T1.log`
- `00_current_config/records/exp026_artifacts/EXP026_CAND_T2.log`
- `00_current_config/records/exp026_artifacts/EXP026_CAND_T3.log`

## Interpretation

- Marker gating successfully separated invalid USB-confounded windows from valid windows.
- In valid windows, candidate behavior was worse than baseline by churn metric on this run series.
- Variability remains high:
  - one candidate valid window had severe churn (`1006`),
  - one candidate valid window was empty (`0`).

## Conclusion

- Current evidence suggests candidate patch is high-risk for loop amplification relative to baseline, even after excluding explicit USB confounders.
- Confidence is moderate (small sample size and high variance).
- Baseline integrity preserved after run:
  - `/lib/netifd/proto/atc.sh` md5 = `8d536e3353700b0dd854492838c9f53e`.

## Next Action

1. Increase sample size (>=10 valid windows per branch) before final causal verdict.
2. Add a minimum-signal gate (for example require at least one `Initiate modem` line) so empty windows are tagged non-informative.
3. Keep production script at baseline between all test batches.
