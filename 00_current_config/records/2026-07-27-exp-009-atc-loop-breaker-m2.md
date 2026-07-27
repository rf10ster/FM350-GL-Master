# Experiment Record: EXP-009 ATC Loop-Breaker Mitigation M2

## Metadata

- Experiment ID: EXP-009
- Date/time: 2026-07-27 15:57 UTC
- Operator: live SSH session
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Stop continuous ATC auto re-setup loop (`pending=true` with repeated `notify_proto Permission denied`).
- Move system to controlled, non-looping diagnostic state.

## Procedure

1. Applied:
   - `uci set network.wan_fm350_atc.auto='0'`
   - `uci commit network`
2. Executed `ifdown wan_fm350_atc`.
3. Captured UCI/ubus/log snapshots.

## Result

- UCI now includes:
  - `network.wan_fm350_atc.auto='0'`
- Interface state changed to controlled idle:
  - `up=false`
  - `pending=false`
  - `autostart=false`
- Tail log no longer showed rapid repeating setup loop; latest lines indicate interface was brought down.

## Interpretation

- M2 succeeded as a loop-breaker control measure.
- This does not restore WAN, but it prevents noisy self-retry behavior and enables cleaner staged recovery/testing.

## Operational Note

- To re-enable ATC autostart for active recovery:
  - `uci del network.wan_fm350_atc.auto`
  - `uci commit network`
  - `ifup wan_fm350_atc`
