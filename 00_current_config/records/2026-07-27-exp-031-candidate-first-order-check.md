# Experiment Record: EXP-031 Candidate-First Order Check

## Metadata

- Experiment ID: EXP-031
- Date/time: 2026-07-27
- Operator: remote run from macOS via one-off SSH script
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Test whether EXP030-style candidate silence is caused by branch order or state carryover from running BASE first.
- Run CAND before BASE with the same marker-gated setup.

## Method

- Single trial with candidate-first order.
- Candidate window:
  - `CAND_T1`
- Baseline window:
  - `BASE_T1`
- Same runner logic as prior batches:
  - marker-gated logging
  - `valid` USB-confounder gate
  - `informative` churn/signal gate
  - `silent` flag for empty/no-signal windows

## Raw Artifact Status

- CSV rows: 3 lines total (header + 2 data rows)
- Artifact directory:
  - `00_current_config/records/EXP031_artifacts/`

## Results

- `CAND_T1`:
  - `valid=1`
  - `informative=0`
  - `updown=0`
  - `signal=0`
  - `silent=1`
  - log size: `0` lines
- `BASE_T1`:
  - `valid=0`
  - `informative=1`
  - `updown=1`
  - `usb=11`
  - `signal=1`
  - log size: `22` lines

## Interpretation

- Candidate-first order does not rescue candidate observability.
- The order/carryover hypothesis is falsified for this setup because candidate remains silent even when it executes first.
- Candidate silence is therefore more consistent with candidate launch-path early abort or no-op behavior than with base-first sequencing.

## Conclusion

- Candidate remains a regression blocker.
- The next useful investigation is launch-path tracing inside the candidate branch, not another reordering experiment.

## Next Action

1. Trace the candidate launch path for an early exit before first ATC/URC emission.
2. Focus on `ifup` -> `proto_atc_setup` -> first `echo`/`gcom` boundary.
3. Do not use order-only reruns as the primary diagnostic from here.
