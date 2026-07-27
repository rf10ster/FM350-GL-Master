# Experiment Record: EXP-006 ATC Port Compare (Crash-Focused)

## Metadata

- Experiment ID: EXP-006
- Date/time: 2026-07-27 15:52 UTC
- Operator: live SSH session
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon
- Scope: ATC behavior comparison for `/dev/ttyUSB2` and `/dev/ttyUSB1`

## Objective

- Validate whether ATC failure is tied to a specific tty port.
- Capture crash/failure signals around `ifup wan_fm350_atc` under current conditions.

## Procedure

1. Ran `/tmp/fm350_atc_port_compare.sh`.
2. Enforced profile policy before tests:
   - `apn='internet'`
   - `pdptype='IP'`
3. Sequentially tested:
   - `/dev/ttyUSB2`
   - `/dev/ttyUSB1`
4. For each test:
   - waited up to 20s for target port + `eth2`
   - switched `network.wan_fm350_atc.device`
   - executed `ifdown/ifup wan_fm350_atc`
   - captured status and `logread` snippets

## Results Summary

- `/dev/ttyUSB2`:
  - `presence=1`
  - `up=false`, `pending=true`, `ip4=none`
  - log errors include:
    - `Can't ioctl set device. (1)`
    - `Could not write to COM device. (1)`
    - `No interface could be found yet`

- `/dev/ttyUSB1`:
  - `presence=0` (during wait window)
  - `up=false`, `pending=true`, `ip4=none`
  - repeated ATC loop entries:
    - `wan_fm350_atc is disconnected`
    - `No interface could be found yet`
    - `notify_proto ... (Permission denied)`

## Final Live State

- `wan_fm350_atc`: `up=false`, `pending=true`
- `wan_modem`: `up=false`, `available=false`, `NO_DEVICE`
- `eth2`: no IPv4 at snapshot

## Conclusion

- Failure is not resolved by switching between ttyUSB2 and ttyUSB1 in this run.
- ATC stack remains unstable and enters repeated re-setup loops.
- Combined blocker profile now includes:
  - COM/ioctl write failures in ATC path,
  - recurring `notify_proto ... Permission denied`,
  - no successful session/IP despite prior long stability window in Variant A.

## Next Action

1. Re-run same compare with explicit `/dev/ttyUSB3` included in the same script for direct 3-port comparison.
2. Collect focused `logread` window from the exact first `ifup` trigger per port.
3. Prepare OpenWrt-side mitigation package for ATC/netifd path (service restart strategy, controlled interface reset sequence).
