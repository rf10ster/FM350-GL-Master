# 05 Field Runbook: Full Cycle (RU/EN)

RU: Единый сценарий для полевого прогона: preflight -> setup -> verify -> incident/experiment logging.
EN: Unified field scenario: preflight -> setup -> verify -> incident/experiment logging.

## Inputs

- `ARCHITECTURE.md`
- `00_current_config/guides/01-preflight-checks.md`
- `00_current_config/guides/02-initial-setup.md`
- `04_knowledge_base/troubleshooting/decision-tree.md`

## Cycle A: Preflight

1. Execute all checks from preflight guide.
2. Save artifact block.
3. Confirm current AT port candidate.

Exit criteria:

- modem visible in USB
- at least one ttyUSB present
- baseline artifacts saved

## Cycle B: Setup (Primary ATC)

1. Apply ATC profile and ensure `pdptype='IP'`.
2. Restart interface.
3. Validate status, IP, and route.

Exit criteria:

- active logical interface
- IPv4 on modem path
- default route present

## Cycle C: Fallback (Only If Needed)

1. Switch to DHCP fallback profile.
2. Revalidate route and internet reachability.
3. Keep ATC artifacts for root-cause analysis.

Exit criteria:

- temporary connectivity restored
- reason for fallback recorded

## Cycle D: Troubleshooting Branch

If any checkpoint fails:

1. Follow `decision-tree.md` branch exactly.
2. Stop random retries after 3 same failures.
3. Capture incident artifact block.

## Cycle E: Recording and Governance

1. Fill experiment record template:
   - `00_current_config/guides/04-experiment-record-template.md`
2. If failure occurred, fill incident report:
   - `00_current_config/guides/03-incident-report-template.md`

## Cycle F: Firmware Track Gate

Move to firmware track only when:

1. this full cycle passes end-to-end
2. artifacts are complete
3. rollback docs are prepared and understood

Use:

- `02_firmware/guides/01-backup-procedure.md`
- `02_firmware/guides/02-rollback-procedure.md`
- `02_firmware/comparison/firmware-matrix.md`
