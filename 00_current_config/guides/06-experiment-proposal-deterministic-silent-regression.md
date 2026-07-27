# 06 Experiment Proposal: Deterministic Silent Regression Follow-up

RU: Proposal для следующего шага после EXP-029: подтвердить, что `CAND` silent-regression является детерминированным и отделить его от USB-confounder шума.
EN: Proposal for the next step after EXP-029: confirm that `CAND` silent-regression is deterministic and separate it from USB-confounder noise.

## Goal

- Verify whether candidate silence is reproducible under the same controlled conditions.
- Keep baseline recovery and artifact retention mandatory.
- Produce a fail-closed result when candidate informative windows stay at zero.

## Proposed Setup

- Runner: `00_current_config/scripts/run_exp_ab_marker_series.sh`
- Command:
  - `sh 00_current_config/scripts/run_exp_ab_marker_series.sh fm350-router 20 12 EXP030 5 5`
- Constraints:
  - keep `auto=0` outside each bounded attempt
  - restore baseline script after every batch
  - preserve marker-gated logging
  - retain `silent` column and threshold-aware exit code

## Hypothesis

- H1: `CAND` remains silent (`silent=100%`, `informative=0`) under the same threshold-aware long-window run.
- H0: candidate silence was incidental and disappears on repetition.

## Cheap Falsification Check

- If any `CAND` window becomes informative (`informative=1`) and produces non-empty marker logs, the deterministic silence hypothesis weakens.
- If `CAND` stays silent across the batch, the hypothesis strengthens.

## Success Criteria

- Base branch still produces informative windows.
- Candidate branch remains silent or non-informative.
- Final router hash matches baseline after rollback.
- Local artifacts are fetched even if the runner exits non-zero.

## Stop Conditions

- Abort immediately if baseline integrity changes unexpectedly.
- Abort if the router cannot return to safe mode (`auto=0`, `pending=false`).
- Abort if USB-confounder noise makes both branches invalid for the full batch.

## Deliverables

1. New experiment record `EXP-030`.
2. Updated changelog entry for the run.
3. If silence persists, add a root-cause branch focused on candidate launch/early-abort behavior rather than churn.