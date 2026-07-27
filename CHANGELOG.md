# Changelog

## [1.40.0] - Added firmware backup/restore runbook with project-local scripts

- Added guide:
	- `00_current_config/guides/07-backup-and-restore-after-flash.md`
- Guide documents:
	- pre-flash backup creation with `create_router_backup.sh`
	- dry-run and apply restore with `restore_router_backup.sh`
	- post-restore validation checklist for `wan_fm350_atc` and `atc.sh` permissions

## [1.39.0] - EXP-045 probe-value series isolated empty devpath/ifname as shared pre-AT barrier

- Added record:
	- `00_current_config/records/2026-07-27-exp-045-probe-value-correlation-series.md`
- Ran 3 short marker windows (`EXP045A/B/C`) with probe-value traces.
- Key finding:
	- `no_iface_path` appears even when USB event count is zero.
	- probe values frequently show `devname=ttyUSB3` but empty `devpath` and empty `ifname`.
- Interpretation:
	- the current dominant blocker is interface probe-resolution failure before first AT command, shared by BASE and CAND in short-window runtime.

## [1.38.0] - EXP-044 established first early-branch boundary after tooling hardening

- Added record:
	- `00_current_config/records/2026-07-27-exp-044-early-branch-marker-boundary.md`
- Early-branch markers added to launch tracer (`after_json_get_vars`, `before_ifname_probe`, `no_iface_path`).
- Result in hardened environment:
	- BASE frequently hits `no_iface_path` before modem init.
	- CAND more often reaches `after_initiate`.
	- both branches still fail before first AT marker (`before_cmee=0`).
- Baseline integrity preserved after run:
	- `/lib/netifd/proto/atc.sh` hash `8d536e3353700b0dd854492838c9f53e`
	- `wan_fm350_atc` remains `proto: atc`.

## [1.37.0] - Tracing scripts hardened for executable-bit and restore-target safety

- Added records:
	- `00_current_config/records/2026-07-27-exp-039-dispatch-ok-no-entry-before-perm-fix.md`
	- `00_current_config/records/2026-07-27-exp-041-permission-safe-launch-trace-smoke.md`
- Fixed tooling root causes in tracing/runner scripts:
	- force `chmod 755` on `/lib/netifd/proto/atc.sh` after each script swap
	- launch tracer now restores raw baseline (`B_RAW`) rather than traced baseline
- Verified post-fix behavior:
	- ATC protocol remains `proto: atc` after runs
	- baseline hash restored to `8d536e3353700b0dd854492838c9f53e`

## [1.36.0] - EXP-037 live registration check shows wan_fm350_atc is present before ifup

- Added live registration check record:
	- `00_current_config/records/2026-07-27-exp-037-live-registration-check.md`
- Added live tracer:
	- `00_current_config/scripts/trace_atc_live_xtrace.sh`
- Result:
	- `wan_fm350_atc` is registered before `ifup`
	- live `ifup wan_fm350_atc` still fails with `Interface wan_fm350_atc not found`
- Interpretation:
	- the next boundary is the live invocation path after registration, not missing UCI config

## [1.35.0] - EXP-032 launch-path trace confirms candidate stays silent before first ATC markers

- Added launch-path trace record:
	- `00_current_config/records/2026-07-27-exp-032-launch-path-trace-candidate-vs-base.md`
- Added tracing script:
	- `00_current_config/scripts/trace_atc_launch_path.sh`
- Result:
	- BASE reached `proto_atc_setup()` and the first modem bring-up marker
	- CAND produced an empty marker window
- Interpretation:
	- candidate silence is not just a noisier AT path; it disappears before the earliest traced ATC markers

## [1.34.0] - EXP-031 falsified order-carryover hypothesis

- Added candidate-first order-check record:
	- `00_current_config/records/2026-07-27-exp-031-candidate-first-order-check.md`
- Result:
	- candidate stayed silent even when run first (`silent=1`, `informative=0`)
	- base run after candidate remained noisy/informative but confounded by USB events
- Interpretation:
	- silence is not explained by BASE-first ordering or simple state carryover
	- next focus should stay on candidate launch-path / early-abort behavior

## [1.33.0] - EXP-030 repeated deterministic silent regression

- Added repeat validation record:
	- `00_current_config/records/2026-07-27-exp-030-repeat-deterministic-silent-regression-fail-closed.md`
- Added artifacts:
	- `00_current_config/records/EXP030_artifacts/*`
- Run parameters:
	- `20` trials, `12s` windows, thresholds `BASE>=5`, `CAND>=5` informative windows.
- Summary:
	- BASE: total `20`, valid+informative `7`, silent `0%`
	- CAND: total `20`, valid+informative `0`, silent `100%`
- Exit behavior:
	- runner exited with status `3` after failing closed on missing candidate informative windows.
- Interpretation:
	- EXP030 reproduces EXP029 and strengthens the deterministic silent-regression conclusion.

## [1.32.0] - Runner now fails closed on missing informative candidate windows

- Updated `00_current_config/scripts/run_exp_ab_marker_series.sh` so that threshold-aware runs exit non-zero when BASE/CAND informative targets are not reached.
- Artifact fetch and local summaries still run before exit, so partial batches remain inspectable.
- This keeps `EXP029`-style silent candidate regressions visible in automation without losing logs.

## [1.31.0] - EXP-029 confirmed deterministic silent regression

- Added threshold-aware long-window A/B record:
	- `00_current_config/records/2026-07-27-exp-029-threshold-aware-ab-strong-silent-regression.md`
- Added artifacts:
	- `00_current_config/records/EXP029_artifacts/*`
- Run parameters:
	- `20` trials, `12s` windows, thresholds `BASE>=5`, `CAND>=5` informative windows.
- Summary:
	- BASE: total `20`, valid+informative `7`, mean up/down `5.00`, silent `0%`
	- CAND: total `20`, valid+informative `0`, silent `100%`
	- candidate branch logs: `0` total lines vs baseline `400` lines
- Threshold outcome:
	- BASE threshold reached (`7/5`), CAND not reached (`0/5`).
- Post-run baseline integrity preserved:
	- `/lib/netifd/proto/atc.sh` md5 `8d536e3353700b0dd854492838c9f53e`.
- Interpretation:
	- silent candidate behavior is deterministic in this setup and is treated as a first-class regression mode.

## [1.30.0] - A/B runner upgraded with confidence gates

- Enhanced `00_current_config/scripts/run_exp_ab_marker_series.sh`:
	- added optional informative thresholds: `min_info_base`, `min_info_cand`
	- added early stop when both informative thresholds are reached
	- added `silent` field to CSV output
	- added branch-level silent-window summary (`silent_rate`, `valid_silent_rate`)
	- added explicit warning when informative thresholds are not met
- Updated reproducibility docs:
	- `README.md` runner usage and interpretation rules
	- `00_current_config/guides/05-field-runbook-full-cycle.md` controlled A/B cycle notes
	- `00_current_config/guides/04-experiment-record-template.md` marker-gated outcome checklist

## [1.29.0] - EXP-028 exposed silent candidate windows

- Added long-window batch record:
	- `00_current_config/records/2026-07-27-exp-028-long-window-ab-silent-candidate-pattern.md`
- Added artifacts:
	- `00_current_config/records/EXP028_artifacts/*`
- Executed 12-trial marker-gated run with 12s windows.
- Results:
	- BASE valid+informative: `n=4`, mean up/down `5.00`
	- CAND valid+informative: `n=0` (insufficient)
	- candidate logs were near-total empty in marker windows (`informative=0`, `updown=0`, `signal=0`).
- Baseline still reproduced operand error under unstable windows:
	- `sh: OK: unknown operand` observed in baseline invalid window.
- Interpretation shift:
	- candidate risk includes not only churn amplification but also silent/no-activity regression behavior.
- Baseline integrity preserved:
	- `/lib/netifd/proto/atc.sh` md5 `8d536e3353700b0dd854492838c9f53e`.

## [1.28.0] - Extended A/B series completed (EXP-027)

- Added extended marker-gated A/B record:
	- `00_current_config/records/2026-07-27-exp-027-marker-gated-ab-extended-series.md`
- Added full artifact set from reusable runner:
	- `00_current_config/records/EXP027_artifacts/*`
- Executed 12-trial series with `valid` and `informative` filters.
- Summary (`valid+informative` only):
	- BASE: `n=9`, mean up/down `2.78`
	- CAND: `n=1`, mean up/down `1057.00`
	- `unknown operand`: `0` across all windows
- Interpretation update:
	- candidate remains high-risk, but confidence is limited by low informative candidate yield.
	- next batches should target minimum informative counts, not just total trial count.
- Baseline integrity preserved:
	- `/lib/netifd/proto/atc.sh` md5 `8d536e3353700b0dd854492838c9f53e`.

## [1.27.0] - Valid-window A/B series indicates candidate churn risk

- Added EXP-026 marker-gated A/B series record and artifacts:
	- `00_current_config/records/2026-07-27-exp-026-marker-gated-ab-series-valid-window-analysis.md`
	- `00_current_config/records/exp026_artifacts/*`
- Added reusable series runner utility:
	- `00_current_config/scripts/run_exp_ab_marker_series.sh`
- Executed 3-trial baseline/candidate sequence with USB-confounder gate per window.
- Results snapshot (`trial,kind,valid,updown,unknown,usb`):
	- baseline valid windows: `n=3`, mean up/down `2.33`
	- candidate valid windows: `n=2`, mean up/down `503.00`
	- `unknown operand`: `0` in all windows
- One candidate window was invalidated by USB events; one valid candidate window was empty (`updown=0`), so variance remains high.
- Baseline script integrity preserved after batch:
	- `/lib/netifd/proto/atc.sh` md5 `8d536e3353700b0dd854492838c9f53e`.

## [1.26.0] - Marker-gated A/B run exposed USB confounder

- Added marker-gated comparison record:
	- `00_current_config/records/2026-07-27-exp-025-marker-gated-comparison-with-usb-confounder.md`
- Replaced raw `logread -f` counting with start/end marker window extraction.
- Marker-window A/B counters:
	- baseline: `updown=1`, `unknown=0`
	- candidate: `updown=225`, `unknown=0`
- Critical confounder captured in candidate window:
	- USB disconnect/re-enumeration (`eth2 unregister`, `ttyUSB* disconnected`) occurred during same 6s interval.
- Updated diagnostic rule:
	- patch causality tests are valid only when marker window has no USB disconnect/re-enumeration lines.
- Post-test integrity preserved:
	- router `atc.sh` restored to baseline hash `8d536e3353700b0dd854492838c9f53e`.

## [1.25.0] - Guarded candidate test versus baseline control

- Added guarded validation and control comparison record:
	- `00_current_config/records/2026-07-27-exp-024-guarded-candidate-vs-baseline-control.md`
- Verified script integrity before and after test:
	- router `atc.sh` and local snapshot hashes matched (`8d536e3353700b0dd854492838c9f53e`)
	- post-run rollback restored exact baseline hash
- Candidate sanitize patch run:
	- passed `ash -n`
	- `unknown operand` not observed in bounded window
	- heavy setup/down churn signature observed in capture
- Baseline control run (same short window) showed no comparable storm signature.
- Important measurement caveat captured:
	- raw counters from `logread -f` can be inflated by buffered replay without explicit start marker.
	- next runs must use marker-gated counting (`logger EXP_START`) for reliable causality.

## [1.24.0] - Minimal sanitize patch still triggers flap storm

- Added EXP-023 runtime validation record:
	- `00_current_config/records/2026-07-27-exp-023-minimal-sanitize-patch-storm-regression.md`
- Confirmed repeated high-frequency netifd flapping (`setting up now` <-> `now down`) even under a short bounded test.
- Recovery succeeded via immediate safe-mode return and backup restore (`atc.sh.bak_exp023`).
- Decision: pause further live edits of `atc.sh` on production router and continue with safe-mode diagnostics/offline script analysis.

## [1.23.0] - Post-rollback sanity checkpoint is stable

- Added post-rollback baseline verification record:
	- `00_current_config/records/2026-07-27-exp-022-post-rollback-sanity-stable.md`
- Confirmed controlled idle state after rollback:
	- `auto=0`, `up=false`, `pending=false`, `autostart=false`
- No new flap-storm lines observed in sanity snapshot.
- Cleared to run only minimal one-line patch tests with short bounded windows.

## [1.22.0] - Script-edit regression produced setup/down storm

- Added regression record for ATC script editing side-effect:
	- `00_current_config/records/2026-07-27-exp-021-atc-script-edit-regression-loop-storm.md`
- Captured critical behavior:
	- ultra-fast netifd flapping loop (`setting up now` <-> `now down`)
- Recovery path validated:
	- force safe mode (`auto=0`)
	- rollback script from backup (`atc.sh.bak_exp021`)
- Operational guardrails updated for future patch tests:
	- one minimal edit per run
	- short bounded test window + immediate rollback on storm signature

## [1.21.0] - Hotfix v1 tested, unknown operand persisted

- Added reversible hotfix test record:
	- `00_current_config/records/2026-07-27-exp-020-hotfix-v1-no-effect.md`
- During bounded follow capture after patch attempt, error still reproduced:
	- `sh: running: unknown operand`
- Safe-mode rollback remained stable after run (`auto=0`, `pending=false`, `autostart=false`).
- Next direction: sanitize `pdp_still_active` to numeric immediately after assignment in `atc.sh`.

## [1.20.0] - Root cause isolated for `unknown operand`

- Added targeted root-cause record:
	- `00_current_config/records/2026-07-27-exp-019-atc-unknown-operand-root-cause.md`
- Isolated likely failing branch in `atc.sh` (`OK` handler around line ~547):
	- numeric test uses `$pdp_still_active -eq 0` after dynamic string assignment
- Established direct compatibility hypothesis:
	- non-numeric PDP state value (e.g. `running`) reaches numeric `-eq` test
	- shell emits `sh: running: unknown operand`
- Next step defined: apply reversible script hotfix and re-test bounded ATC run.

## [1.19.0] - Source-scan narrowed unknown operand path to atc.sh

- Added script source-scan record:
	- `00_current_config/records/2026-07-27-exp-018-atc-script-source-scan.md`
- Confirmed ATC proto candidate set on router includes:
	- `/lib/netifd/proto/atc.sh`
	- `/lib/netifd/proto/3g.sh`
	- `/lib/netifd/proto/mbim.sh`
- Broad grep over `/usr/bin` and `/sbin` produced high binary noise and is not root-cause actionable.
- Preliminary atc.sh hot spots identified around compound test lines (including line ~547).
- Utility limitation captured:
	- `ash: nl: not found`

## [1.18.0] - Marker-based follow capture found shell operand error

- Added follow-capture record with disconnect-marker polling:
	- `00_current_config/records/2026-07-27-exp-017-atc-usb3-follow-until-disconnect-marker.md`
- Captured new script-level signature in ATC setup path:
	- `sh: running: unknown operand`
- Attempt still remained in non-working state (`up=false,pending=true`) with no IPv4.
- Re-confirmed safe rollback to controlled mode (`auto=0`, `pending=false`, `autostart=false`).
- Next direction: inspect ATC proto shell logic for incompatible operand/test branch.

## [1.17.0] - Follow-capture method validated for ATC logs

- Added bounded live stream capture record:
	- `00_current_config/records/2026-07-27-exp-016-atc-usb3-follow-capture-20s.md`
- Validated that `logread -f` capture produces non-empty artifact (`57` lines), unlike zero-line static delta export.
- In this 20s sample, captured only early lifecycle lines:
	- `setting up now`
	- `Initiate modem with interface eth2`
- Re-confirmed controlled rollback to safe-mode (`auto=0`, `pending=false`, `autostart=false`).
- Next direction: extend bounded window (45-60s) or stop on first `is disconnected` marker.

## [1.16.0] - Full delta export returned zero lines

- Added full unfiltered delta export record for ttyUSB3:
	- `00_current_config/records/2026-07-27-exp-015-atc-usb3-full-delta-zero-lines.md`
- Observed paradoxical state:
	- runtime status moved to `pending=true`
	- exported delta file `/tmp/exp015_delta_full.log` contained 0 lines
- Re-confirmed rollback stability with M2 (`auto=0`):
	- `pending=false`, `autostart=false`
- Next method switched to bounded live stream capture (`logread -f`).

## [1.15.0] - Clean delta-window run with empty critical slice

- Added delta-log bounded run record for ttyUSB3:
	- `00_current_config/records/2026-07-27-exp-014-atc-usb3-delta-log-empty.md`
- Confirmed control-state pattern remains:
	- attempt state `up=false,pending=true`
	- rollback state `auto=0,pending=false,autostart=false`
- Observed that critical-pattern grep over new log delta returned no lines in this run.
- Next diagnostic direction: capture full unfiltered delta-log first, then classify signatures from that artifact.

## [1.14.0] - ttyUSB3 long-window (20s) lifecycle capture

- Added long-window bounded run record for ttyUSB3:
	- `00_current_config/records/2026-07-27-exp-013-atc-usb3-long-window-20s.md`
- Confirmed repeatable lifecycle in 20s window:
	- `setting up` -> `Initiate modem` -> `is disconnected` -> `now down`
- Still no IPv4 on `eth2`; ATC remained `up=false, pending=true` during attempt.
- Re-confirmed safe rollback behavior with M2 (`auto=0`):
	- `pending=false`, `autostart=false`

## [1.13.0] - Paired bounded ttyUSB1/ttyUSB3 run with presence pre-check

- Added paired one-shot comparison record with strict `ttyUSBx + eth2` pre-check:
	- `00_current_config/records/2026-07-27-exp-012-paired-bounded-ttyusb1-vs-ttyusb3.md`
- Confirmed both ports fail to obtain IPv4 in bounded run despite immediate device presence.
- Observed on `ttyUSB3`: state can start at `pending=false` right after enable and move to `pending=true` during setup.
- Re-confirmed post-attempt safe-mode behavior after each test:
	- `network.wan_fm350_atc.auto='0'`
	- `pending=false`, `autostart=false`

## [1.12.0] - Bounded ttyUSB3 single-try parity with ttyUSB1

- Added bounded single-try record for explicit `ttyUSB3`:
	- `00_current_config/records/2026-07-27-exp-011-atc-single-try-usb3-safe-mode-cycle.md`
- Confirmed same early ATC failure as `ttyUSB1` in one-shot mode:
	- `Could not write to COM device. (1)`
- Re-confirmed M2 safe-mode behavior after run:
	- `network.wan_fm350_atc.auto='0'`
	- `pending=false`, `autostart=false`

## [1.11.0] - M2 loop-breaker validated with bounded single-try cycle

- Added quick 3-port ATC cycle record:
	- `00_current_config/records/2026-07-27-exp-008-atc-3port-quick-compare.md`
- Added M2 loop-breaker validation record (`auto=0`):
	- `00_current_config/records/2026-07-27-exp-009-atc-loop-breaker-m2.md`
- Added bounded single-try recovery cycle record (enable -> capture -> disable):
	- `00_current_config/records/2026-07-27-exp-010-atc-single-try-safe-mode-cycle.md`
- Added reusable ATC control utility:
	- `00_current_config/scripts/atc_loop_breaker.sh`
- Confirmed operational behavior:
	- safe-mode (`auto=0`) yields `pending=false, autostart=false`
	- one-shot enable attempt stays `up=false,pending=true` and captures `Could not write to COM device. (1)`

## [1.10.0] - Controlled reset M1 and EIAAPN failure capture

- Added controlled ATC reset experiment (M1) with `ifdown/ubus reload/ifup` sequence:
	- `00_current_config/records/2026-07-27-exp-007-atc-controlled-reset-m1.md`
- Confirmed mitigation M1 did not recover session/IP:
	- `wan_fm350_atc` stayed `up=false,pending=true`
	- `wan_modem` stayed `NO_DEVICE`
- Captured persistent ATC software loop signatures:
	- `notify_proto ... (Permission denied)`
	- `No interface could be found yet`
- Captured AT command failure in setup path:
	- `Error running AT-command: AT+EIAAPN="internet",0,"","",,"",""`
- Updated known issues with EIAAPN compatibility case:
	- `01_4pda_research/solutions_database/known_issues.md`

## [1.9.0] - ATC port comparison and re-setup loop finding

- Added crash-focused ATC comparison record for `ttyUSB2` and `ttyUSB1`:
	- `00_current_config/records/2026-07-27-exp-006-atc-port-compare-crash-focus.md`
- Confirmed both tested ports failed to establish session/IP:
	- `up=false`, `pending=true`, `ip4=none`
- Captured recurring ATC failure signatures:
	- `Can't ioctl set device. (1)`
	- `Could not write to COM device. (1)`
	- `No interface could be found yet`
	- `notify_proto ... (Permission denied)` with repeated re-setup loop
- Updated known issues with explicit `notify_proto Permission denied` loop case:
	- `01_4pda_research/solutions_database/known_issues.md`

## [1.8.0] - Variant A control run and ATC crash finding

- Completed Variant A control repeat on current cable/port path and captured long stable presence window:
	- `00_current_config/records/2026-07-27-exp-005-variant-a-control-window.md`
- Confirmed measured stability improvement:
	- observed `max_stable` reached 115s (`ttyUSB*` + `eth2` present continuously)
- ATC still failed to establish data session despite stable window:
	- `wan_fm350_atc` remained `up=false,pending=true`
	- no IPv4 on `eth2` at snapshot
- Captured new critical software finding in logs:
	- `wan_fm350_atc (...): Segmentation fault (core dumped)`
- Updated known issues with ATC crash scenario:
	- `01_4pda_research/solutions_database/known_issues.md`

## [1.7.0] - Edge-triggered bring-up validation

- Ran edge-triggered ATC bring-up attempt on live router and captured failure mode under USB re-enumeration storm:
	- `00_current_config/records/2026-07-27-exp-004-edge-bringup-failure.md`
- Confirmed no stable network state after attempt:
	- `wan_fm350_atc` remained `up=false,pending=true`
	- `wan_modem` remained `NO_DEVICE`
	- `eth2` absent at snapshot
- Updated known issues with explicit edge-bringup limitation under short presence windows:
	- `01_4pda_research/solutions_database/known_issues.md`

## [1.6.0] - Live MegaFon migration and USB stability test

- Performed live router-side APN migration to MegaFon (`apn='internet'`) with PDP policy preserved (`pdptype='IP'`).
- Added real experiment record with external power test and full step outcomes:
	- `00_current_config/records/2026-07-27-exp-002-megafon-usb-power-test.md`
- Added known issue entry for USB re-enumeration loop causing `NO_DEVICE` and ATC ioctl failures:
	- `01_4pda_research/solutions_database/known_issues.md`
- Added focused stability-window experiment with external power and probe traces:
	- `00_current_config/records/2026-07-27-exp-003-usb-stability-window-test.md`

## [1.5.0] - First real records from ATC recovery case

- Added first filled experiment record from real ATC stabilization cycle:
	- `00_current_config/records/2026-07-27-exp-001-atc-stabilization.md`
- Added first filled incident report for SESSION_FAILED case:
	- `00_current_config/records/2026-07-27-inc-001-session-failed.md`
- Updated firmware matrix with real baseline row and references:
	- `02_firmware/comparison/firmware-matrix.md`
- Added concrete known issue row for pdptype-related SESSION_FAILED:
	- `01_4pda_research/solutions_database/known_issues.md`
- Updated root README with field record links:
	- `README.md`

## [1.4.0] - Firmware matrix and hardware baseline

- Added firmware comparison matrix:
	- `02_firmware/comparison/firmware-matrix.md`
- Added NC2312 hardware baseline:
	- `03_nc2312_integration/hardware/hardware-baseline.md`
- Added unified field runbook full cycle:
	- `00_current_config/guides/05-field-runbook-full-cycle.md`
- Updated section indexes with package 4 document links:
	- `02_firmware/README.md`
	- `03_nc2312_integration/README.md`

## [1.3.0] - Script resilience and experiment governance templates

- Improved dynamic AT port detection in scripts:
	- `00_current_config/scripts/check_setup_stage.sh`
	- `00_current_config/scripts/monitor_connection.sh`
	- `00_current_config/scripts/usb_mode_switch.sh`
- Added incident report template:
	- `00_current_config/guides/03-incident-report-template.md`
- Added experiment record template:
	- `00_current_config/guides/04-experiment-record-template.md`
- Added firmware backup guide:
	- `02_firmware/guides/01-backup-procedure.md`
- Added firmware rollback guide:
	- `02_firmware/guides/02-rollback-procedure.md`

## [1.2.0] - Troubleshooting and automation hardening

- Added structured diagnostics: `04_knowledge_base/troubleshooting/decision-tree.md`
- Converted common issues into index and canonical links: `04_knowledge_base/troubleshooting/common_issues.md`
- Expanded AT reference with purpose, expected responses, and baseline command sequence: `04_knowledge_base/at_commands/basic_commands.md`
- Hardened bootstrap script to non-destructive mode (no overwrite, no auto-push): `setup_fm350_repo.sh`
- Hardened deployment script to idempotent safe mode (preserve existing content): `deploy_fm350_setup.sh`

## [1.1.0] - Documentation implementation start

- Added canonical architecture document: `ARCHITECTURE.md`
- Added preflight guide: `00_current_config/guides/01-preflight-checks.md`
- Added zero-state setup runbook: `00_current_config/guides/02-initial-setup.md`
- Added ATC primary UCI reference: `00_current_config/configs/uci-atc-profile.conf`
- Added DHCP fallback UCI reference: `00_current_config/configs/uci-dhcp-profile.conf`
- Updated root README with canonical v1.1 path and links

## [1.0.0] - Initial structure
