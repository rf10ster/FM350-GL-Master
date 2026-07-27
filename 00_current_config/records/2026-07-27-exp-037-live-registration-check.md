# Experiment Record: EXP-037 Live Registration Check Before ifup

Date: 2026-07-27

## Goal

Check whether `wan_fm350_atc` is registered in live netifd state before calling `ifup` when the traced candidate script is installed on the router.

## Setup

- Tracing script: `00_current_config/scripts/trace_atc_live_xtrace.sh`
- Run: `sh 00_current_config/scripts/trace_atc_live_xtrace.sh fm350-router 00_current_config/records/atc.sh.router.snapshot.exp024.candidate EXP037 8`

## Result

- The live tracer printed `__LIVE__ CAND registered_before_ifup`
- The subsequent `ifup wan_fm350_atc` still failed with `Interface wan_fm350_atc not found`
- The captured CSV reported `entry_like=0` and `xtrace_like=0`

## Interpretation

- The interface exists in live netifd state before `ifup`, so the failure is not a missing UCI section.
- The remaining problem is in the live invocation path after registration, not in the basic interface definition.
- Next useful boundary is the exact live `ifup`/proto invocation path, not further config existence checks.
