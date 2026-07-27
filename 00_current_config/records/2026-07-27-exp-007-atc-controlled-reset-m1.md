# Experiment Record: EXP-007 ATC Controlled Reset M1

## Metadata

- Experiment ID: EXP-007
- Date/time: 2026-07-27 15:53 UTC
- Operator: live SSH session
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Test a controlled ATC path reset without reboot:
  - `ifdown wan_fm350_atc`
  - `ifdown wan_modem`
  - `ubus call network reload`
  - `ifup wan_fm350_atc`
- Check whether it breaks the `notify_proto ... Permission denied` re-setup loop.

## Procedure

1. Executed mitigation sequence M1 on router shell.
2. Waited for ATC setup cycle.
3. Collected status and filtered `logread` diagnostics.
4. Captured current UCI ATC profile snapshot.

## Profile Snapshot at Test Time

- `proto='atc'`
- `device='/dev/ttyUSB1'`
- `apn='internet'`
- `pdptype='IP'`

## Result

- Mitigation M1 did not recover WAN.
- Final state:
  - `wan_fm350_atc`: `up=false`, `pending=true`
  - `wan_modem`: `up=false`, `available=false`, `NO_DEVICE`
  - `eth2`: no IPv4 at snapshot

## Critical Logs

- Repeated loop persists:
  - `wan_fm350_atc is disconnected`
  - `notify_proto ... (Permission denied)`
  - `No interface could be found yet`
- Additional ATC stack errors observed in same cycle:
  - `Could not write to COM device. (1)`
  - `Error running AT-command: AT+EIAAPN="internet",0,"","",,"",""`

## Conclusion

- Controlled reload/reset M1 does not stop the ATC re-setup failure loop.
- Failure now has a strong software signature in ATC control path (`notify_proto` permission errors + malformed/failed EIAAPN command path).

## Next Action

1. Add direct 3-port comparison (`ttyUSB3/2/1`) under same capture script.
2. Validate ATC profile compatibility with current FM350 command set (focus on EIAAPN command generation).
3. Prepare OpenWrt-side workaround package for ATC stack (controlled restart sequence + loop breaker).
