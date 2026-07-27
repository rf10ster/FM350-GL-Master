# Experiment Record: EXP-041 Permission-Safe Launch Trace Smoke

Date: 2026-07-27

## Goal

Validate tracing scripts after permission-safe install fixes and confirm that ATC protocol registration remains intact.

## Setup

- Updated scripts:
  - `00_current_config/scripts/run_exp_ab_marker_series.sh`
  - `00_current_config/scripts/trace_atc_launch_path.sh`
  - `00_current_config/scripts/trace_atc_live_xtrace.sh`
- Run: `sh 00_current_config/scripts/trace_atc_launch_path.sh fm350-router EXP041 6`

## Result

- Tracer output showed non-zero early marker activity:
  - `CAND`: `enter=1`, `updown=3`, `signal_like=18`
  - `BASE`: `enter=1`, `updown=2`, `signal_like=9`
- `atc.sh` stayed executable (`-rwxr-xr-x`) and interface status remained `proto: atc` after restore.
- Final router baseline was restored to canonical hash `8d536e3353700b0dd854492838c9f53e`.

## Interpretation

- Prior silent/no-entry observations were strongly confounded by tooling side effects.
- With permission-safe install and correct restore targets, launch markers are visible again.
- Next candidate-vs-base conclusions should only use the corrected tracing scripts.
