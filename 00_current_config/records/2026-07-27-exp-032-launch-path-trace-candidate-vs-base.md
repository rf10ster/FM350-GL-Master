# Experiment Record: EXP-032 Launch-Path Trace, Candidate vs Base

Date: 2026-07-27

## Goal

Trace the FM350 ATC launch path with marker hooks to determine whether the candidate reaches `proto_atc_setup()` and the first modem bring-up boundary.

## Setup

- Tracing script: `00_current_config/scripts/trace_atc_launch_path.sh`
- Run: `sh 00_current_config/scripts/trace_atc_launch_path.sh fm350-router EXP032 6`
- Baseline integrity preserved after the run.

## Result

- `CAND`: `enter=0`, `after_initiate=0`, `before_cmee=0`, `before_cfun1=0`, `before_urc_loop=0`, `return_1=0`
- `BASE`: `enter=1`, `after_initiate=1`, `before_cmee=0`, `before_cfun1=0`, `before_urc_loop=0`, `return_1=0`
- Candidate log window was empty.
- Baseline log window showed `Interface 'wan_fm350_atc' is setting up now`, `__TRACE__ BASE enter_setup`, and `Initiate modem with interface eth2`.

## Interpretation

- Candidate silence is now stronger than a branch-level AT-response difference.
- The candidate does not emit even the earliest launch markers in the traced window.
- Next boundary is earlier than `proto_atc_setup()` itself or inside the path that prevents the function from being entered in the trace window.
