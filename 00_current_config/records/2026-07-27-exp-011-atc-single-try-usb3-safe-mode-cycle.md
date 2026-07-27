# Experiment Record: EXP-011 ATC Single-Try on ttyUSB3 with Safe-Mode Return

## Metadata

- Experiment ID: EXP-011
- Date/time: 2026-07-27 16:07 UTC
- Operator: remote run from macOS via SSH one-liner
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Re-run bounded single-attempt cycle using explicit `device='/dev/ttyUSB3'`.
- Compare first-failure signature against previous bounded run on `ttyUSB1`.

## Procedure

1. Applied UCI profile and forced AT device:
   - `network.wan_fm350_atc.device='/dev/ttyUSB3'`
   - `apn='internet'`, `pdptype='IP'`
2. Ran `sh /tmp/atc_loop_breaker.sh enable`.
3. Waited 8s and collected status/log tail.
4. Returned to safe-mode with `disable` + `status`.

## Results

### During single try (ttyUSB3)

- Interface state stayed:
  - `up=false`
  - `pending=true`
  - `autostart=true`
- No IPv4 on `eth2`.
- Critical first error:
  - `Error@180, line 10, Could not write to COM device. (1)`
- Follow-up state:
  - `wan_fm350_atc is disconnected`
  - interface transitioned down.

### After safe-mode return

- UCI contains `network.wan_fm350_atc.auto='0'`.
- Interface stabilized again:
  - `up=false`
  - `pending=false`
  - `autostart=false`

## Comparison with EXP-010 (ttyUSB1)

- First-failure signature is the same (`Could not write to COM device. (1)`).
- No functional advantage of `ttyUSB3` over `ttyUSB1` in bounded single-attempt mode.

## Conclusion

- Port switch `ttyUSB1` -> `ttyUSB3` does not change early failure behavior in ATC path.
- M2 safe-mode remains reliable for keeping diagnostic loop under control.

## Next Action

1. Run paired bounded attempts with strict pre-checks of `ttyUSBx` and `eth2` presence immediately before `ifup`.
2. If failure remains identical, focus next on ATC script/command compatibility (not port selection).
