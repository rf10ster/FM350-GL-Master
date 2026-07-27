# Experiment Record: EXP-044 Early-Branch Marker Boundary (Hardened Tooling)

Date: 2026-07-27

## Goal

With corrected tracing tooling, determine the first meaningful branch boundary inside `proto_atc_setup()` between BASE and CAND.

## Setup

- Script: `00_current_config/scripts/trace_atc_launch_path.sh`
- Run: `sh 00_current_config/scripts/trace_atc_launch_path.sh fm350-router EXP044 8`
- Added markers:
  - `after_json_get_vars`
  - `before_ifname_probe`
  - `no_iface_path`
  - existing launch markers (`enter_setup`, `after_initiate`, ...)

## Result

CSV row summary:

- `CAND`: `enter=1`, `after_json_get_vars=1`, `before_ifname_probe=1`, `no_iface_path=0`, `after_initiate=1`, later AT markers `0`
- `BASE`: `enter=2`, `after_json_get_vars=2`, `before_ifname_probe=2`, `no_iface_path=2`, `after_initiate=0`, later AT markers `0`

Router integrity after run:

- `/lib/netifd/proto/atc.sh` hash restored to `8d536e3353700b0dd854492838c9f53e`
- interface status remains `proto: atc`

## Interpretation

- The first differentiating branch is now visible in a clean setup:
  - BASE often exits through `no_iface_path` before modem-init stage.
  - CAND more often reaches `after_initiate` before disconnect/no-progress.
- The dominant blocker remains environment/runtime instability before the first AT command (`before_cmee=0` for both), not a clean candidate-only launch abort.
