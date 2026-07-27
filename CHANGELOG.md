# Changelog

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
