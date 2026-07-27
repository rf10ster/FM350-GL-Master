# Common Issues (Index)

RU: Краткий индекс проблем. Подробные ветки диагностики вынесены в decision tree.
EN: Short issue index. Full diagnostic branches are in the decision tree.

## Primary Diagnostic Flow

- See: `04_knowledge_base/troubleshooting/decision-tree.md`

## Quick Index

1. Modem not detected:
	- check USB presence, power, cable, and ttyUSB list
2. `SESSION_FAILED` on ATC:
	- verify APN and `pdptype='IP'`
3. No IPv4 on modem path:
	- inspect `eth2`, PDP activation, and interface status
4. No default route:
	- validate routing table and active interface state
5. Low speed / unstable connection:
	- inspect signal and antenna conditions first

## Canonical References

- `ARCHITECTURE.md`
- `00_current_config/guides/01-preflight-checks.md`
- `00_current_config/guides/02-initial-setup.md`
