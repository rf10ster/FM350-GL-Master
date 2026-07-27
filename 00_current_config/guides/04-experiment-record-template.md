# 04 Experiment Record Template (RU/EN)

RU: Шаблон для документирования экспериментов (режимы USB, прошивки, роутеры).
EN: Template for experiment records (USB modes, firmware, routers).

## Metadata

- Experiment ID:
- Date/time:
- Operator:
- Target track:
  - OpenWrt stable
  - modem firmware
  - router firmware
  - Keenetic USB/M.2

## Objective

- Hypothesis:
- Success criteria:
- Stop conditions:

## Baseline

- Current firmware version (`AT+CGMR`):
- Current profile (`wan_fm350_atc` / `wan_modem`):
- Current AT port candidate:
- Current connectivity status:

## Procedure

1. Step 1:
2. Step 2:
3. Step 3:

## Checkpoints

For each checkpoint provide:

- Command(s):
- Expected result:
- Actual result:
- Pass/fail:

## Artifact Block (Mandatory)

1. `uci show network` relevant lines
2. `ubus` interface status
3. `ip addr show eth2`
4. `ip route`
5. `ls -la /dev/ttyUSB*`
6. `dmesg` snippet
7. AT output snippets

## Outcome

- Result summary:
- Did success criteria pass:
- Any regressions:

If marker-gated A/B was used, include:

- CSV schema version (for example includes `silent` column)
- valid+informative counts by branch (BASE/CAND)
- mean churn (`up/down`) on valid+informative windows
- silent-window rate by branch
- confidence note if informative thresholds were not reached

## Rollback

- Rollback executed (yes/no):
- Commands used:
- Post-rollback validation:

## Next Action

1. Promote change to docs/scripts
2. Repeat with adjusted variables
3. Abort track and return to stable profile
