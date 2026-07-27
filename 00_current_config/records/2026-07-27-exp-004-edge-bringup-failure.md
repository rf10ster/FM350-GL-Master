# Experiment Record: EXP-004 Edge-Triggered Bring-up Failure

## Metadata

- Experiment ID: EXP-004
- Date/time: 2026-07-27 15:41 UTC
- Operator: live SSH session
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Catch short modem presence window and immediately raise ATC by fast device retries (`ttyUSB3`, `ttyUSB2`, `ttyUSB1`, `ttyUSB0`).
- If ATC fails, fallback to DHCP on `wan_modem`.

## Procedure

1. Created and ran `/tmp/fm350_edge_bringup.sh`.
2. Applied APN/PDP policy before attempts:
   - `apn='internet'`
   - `pdptype='IP'`
3. Edge flow:
   - wait for `ttyUSB*` + `eth2`
   - quickly try ATC device candidates with `ifup wan_fm350_atc`
   - check `ubus up` and IPv4 on `eth2`

## Observations

- Round 1 detected presence window.
- Attempts during window:
  - device `/dev/ttyUSB3` -> `up=false`, `ip4=none`
  - device `/dev/ttyUSB2` -> `up=false`, `ip4=none`
- Subsequent round often had no usable presence window.
- Kernel log continues attach/detach storm:
  - repeated `ttyUSB0..7 attach` followed by disconnect
  - `rndis_host eth2 register/unregister`
  - immediate USB disconnect after attach burst

## Final State

- `wan_fm350_atc`: `up=false`, `pending=true`
- `wan_modem`: `up=false`, `available=false`, `NO_DEVICE`
- `eth2`: no IPv4/device at snapshot
- default route remains through `phy0-sta0`

## Conclusion

- Edge-trigger strategy did not overcome instability.
- Current blocker remains physical/USB path instability, not APN/PDP config.

## Next Action

1. Perform controlled A/B hardware pass (cable/USB path variants) and compare stable window length.
2. Capture full logs for the first successful stable window >=8-10s before repeating bring-up.
3. Avoid prolonged software retry loops until USB attach/detach storm is reduced.
