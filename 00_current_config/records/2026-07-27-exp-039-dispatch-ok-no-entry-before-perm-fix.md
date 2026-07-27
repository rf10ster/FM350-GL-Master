# Experiment Record: EXP-039 Dispatch OK but No Entry Markers Before Permission Fix

Date: 2026-07-27

## Goal

Verify whether live netifd dispatch (`ubus ... up/down`) reaches ATC launch markers when `wan_fm350_atc` is registered.

## Setup

- Script: `00_current_config/scripts/trace_atc_live_xtrace.sh`
- Candidate source: `00_current_config/records/atc.sh.router.snapshot.exp024.candidate`
- Run: `sh 00_current_config/scripts/trace_atc_live_xtrace.sh fm350-router 00_current_config/records/atc.sh.router.snapshot.exp024.candidate EXP039 10`

## Result

- CSV row: `1,CAND,0,0,1,1,0,0`
  - `registered_before_up=1`
  - `registered_after_up=1`
  - `down_rc=0`, `up_rc=0`
  - but `entry_like=0`, `xtrace_like=0`
- Follow-up status showed `proto: none` and `errors: NO_DEVICE` on `wan_fm350_atc`.

## Interpretation

- Live dispatch itself was accepted, but marker absence was not evidence of candidate-only regression.
- The trace workflow still had a tooling confounder that was resolved immediately after this run:
  - `atc.sh` execute bit loss (`0644`) can force `proto:none`
  - launch tracer restore path could leave traced baseline installed
