# Experiment Record: EXP-001 ATC Stabilization

## Metadata

- Experiment ID: EXP-001
- Date/time: 2026-07-27
- Operator: local session
- Target track: OpenWrt stable

## Objective

- Hypothesis: ATC session failures are caused by missing PDP type in UCI profile, not by wrong USB mode driver binding.
- Success criteria:
  1. ATC profile can activate data session after explicit PDP type is set.
  2. Session activation no longer fails at CGACT step for the tested cycle.
  3. Evidence artifacts are complete.
- Stop conditions:
  1. Repeated AT timeout on all ttyUSB candidates.
  2. Repeated identical SESSION_FAILED after pdptype correction.

## Baseline

- Current firmware version (AT+CGMR): not captured in this record (to be captured in next cycle)
- Current profile: wan_fm350_atc
- APN: internet.beeline.ru
- PDP type in UCI before fix: missing
- AT port behavior: drift observed between /dev/ttyUSB1 and /dev/ttyUSB3
- Current connectivity status before fix: session failed

## Procedure

1. Verified that tested USB mode values available on current firmware were 40/41 and that mode was stable at 41 during troubleshooting.
2. Verified working AT port candidate as /dev/ttyUSB3 while /dev/ttyUSB1 was non-responsive in this cycle.
3. Reproduced failure path where ATC flow reached CGDCONT with empty PDP type and then failed during CGACT.
4. Applied manual AT corrective commands:
   - AT+CGDCONT=1,"IP","internet.beeline.ru"
   - AT+CGACT=1,1
5. Observed successful PDN activation response and OK result.

## Checkpoints

- Checkpoint A:
  - Command(s): uci show network.wan_fm350_atc
  - Expected result: profile exists, APN set
  - Actual result: APN present, pdptype absent
  - Pass/fail: fail

- Checkpoint B:
  - Command(s): AT+CGDCONT and AT+CGACT flow
  - Expected result: valid PDP type and successful activation
  - Actual result: activation failed until PDP type was explicitly set
  - Pass/fail: fail then pass after correction

- Checkpoint C:
  - Command(s): manual AT correction + activation
  - Expected result: PDN active event and OK
  - Actual result: +CGEV: ME PDN ACT 1 and OK
  - Pass/fail: pass

## Artifact Block

1. UCI network snapshot (relevant lines): captured in session notes
2. Interface status snapshots via ubus: partially captured
3. ip addr eth2 snapshot: pending in this record
4. ip route snapshot: pending in this record
5. ttyUSB enumeration snapshots: captured in session notes
6. dmesg tail: captured in session notes
7. AT output snippets: captured

## Outcome

- Result summary: hypothesis supported for this cycle; missing pdptype was the immediate blocker for ATC bring-up.
- Did success criteria pass: partially (session activation fixed, but evidence set not fully archived as files).
- Any regressions: AT port instability remains and requires repeated re-detection across reconnect/reboot.

## Rollback

- Rollback executed: no
- Commands used: none
- Post-rollback validation: not applicable

## Next Action

1. Persist UCI setting with pdptype='IP' and verify after reboot.
2. Capture full artifact set including AT+CGMR, ip addr, and ip route in a dedicated backup folder.
3. Re-run full cycle using 00_current_config/guides/05-field-runbook-full-cycle.md.
