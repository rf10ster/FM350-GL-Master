# Experiment Record: EXP-036 Direct Stubbed proto_atc_setup Compare

Date: 2026-07-27

## Goal

Call `proto_atc_setup()` directly in a stubbed shell for BASE and CAND to separate function-level behavior from netifd/runtime context.

## Setup

- Base source: `00_current_config/records/atc.sh.router.snapshot`
- Candidate source: `00_current_config/records/atc.sh.router.snapshot.exp024.candidate`
- Remote direct harness on `fm350-router`
- Minimal stubs provided for `gcom`, `fw3`, `proto_*`, and `json_get_vars`
- `device` pointed at an empty temp file so the URC loop would terminate immediately

## Result

- `BASE` reached the direct call path and printed `Initiate modem with interface eth2`
- `CAND` reached the same direct call path and printed the same early marker
- Both branches then executed the same early AT command sequence under the stubbed environment
- The harness still surfaced `sh: BASE: unknown operand` / `sh: CAND: unknown operand` in the isolated shell, which indicates the direct stub is not reproducing the exact router runtime precondition that drives the observed silent candidate on netifd

## Interpretation

- The candidate regression is not explained by a simple difference inside isolated `proto_atc_setup()` when the modem and netifd dependencies are stubbed away.
- The next useful boundary is the real router runtime context around netifd, shell operands, and device/config state before or during the live invocation.
