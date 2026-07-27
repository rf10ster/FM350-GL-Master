# Experiment Record: EXP-003 USB Stability Window Test (External Power)

## Metadata

- Experiment ID: EXP-003
- Date/time: 2026-07-27 15:38 UTC
- Operator: live SSH session
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Validate whether modem USB presence can hold a stable window long enough for controlled ATC bring-up.
- Window requirement in test script: at least 8 consecutive seconds with both ttyUSB and eth2 present.

## Procedure

1. Applied/confirmed ATC profile for MegaFon:
   - apn='internet'
   - pdptype='IP'
2. Applied USB power policy on detected device:
   - power/control=on
   - power/autosuspend=-1
3. Ran `/tmp/fm350_stabilize.sh` with probe loop.

## Key Observations

- Most probes: `ttyUSB=0`, `eth2=no`.
- One short burst detected:
  - probe[41..45]: `ttyUSB=6`, `eth2=yes`, stable counter reached 5.
- Immediately after:
  - probe[46]: `ttyUSB=1`, `eth2=no`
  - probes after that returned to zero presence.

## Result

- Stable window target was not achieved (`stable=5` max, target `stable>=8`).
- ATC and DHCP fallback cannot be reliably brought up while USB presence collapses this quickly.

## Technical Conclusion

- APN/PDP configuration is no longer the primary blocker.
- Primary blocker is USB re-enumeration/disconnect loop on router-side USB path.

## Recommended Next Actions

1. Test different physical USB path/cable combination (short cable, shielded cable, alternate USB path).
2. Reduce modem re-enumeration triggers (no mode switches during bring-up attempts).
3. Capture one complete attach/detach cycle with full dmesg around the first appearance burst.
4. Re-run the same stabilization script and compare stable-window length across hardware variants.
