# Experiment Record: EXP-005 Variant A Control Window (Current Cable/Port)

## Metadata

- Experiment ID: EXP-005
- Date/time: 2026-07-27 15:47-15:49 UTC
- Operator: live SSH session
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon
- Variant: A (control repeat, same current cable/port path)

## Objective

- Run control A/B measurement on current hardware path.
- Measure stable presence window length for `ttyUSB*` + `eth2`.
- Attempt ATC bring-up inside stable window.

## Procedure

1. Ran `/tmp/fm350_variantA_probe.sh` with 1-second probes.
2. Enforced policy before test:
   - `apn='internet'`
   - `pdptype='IP'`
3. Probe interrupted manually after long stable run to save time.
4. Parsed resulting log for max stability.
5. Performed direct ATC retry on `/dev/ttyUSB3`.

## Key Results

- Observed stability metric:
  - `max_stable_observed=115s`
  - last probe: `probe[115] ttyUSB=8 eth2=yes stable=115`
- This is a major improvement versus prior short windows (~5s).

## ATC Bring-up Attempt in Stable Window

- Applied:
  - `network.wan_fm350_atc.device='/dev/ttyUSB3'`
  - `network.wan_fm350_atc.apn='internet'`
  - `network.wan_fm350_atc.pdptype='IP'`
- Executed:
  - `ifdown wan_fm350_atc`
  - `ifup wan_fm350_atc`
- Outcome:
  - `wan_fm350_atc`: `up=false`, `pending=true`
  - `eth2`: no IPv4 at snapshot
  - default route unchanged (via `phy0-sta0`)

## Critical Log Finding

- `logread` contains ATC-path crash:
  - `wan_fm350_atc (...): Segmentation fault (core dumped)`
- Attach/detach events still exist in kernel logs, but stability window is now significantly longer than before.

## Conclusion

- Variant A confirms that physical USB presence can now stay stable for long windows (>=115s observed).
- Connectivity is still blocked at ATC software stack/runtime stage despite improved hardware stability.
- New blocker candidate: `netifd`/ATC process crash during modem bring-up.

## Next Action

1. Capture reproducible ATC crash evidence (`logread` around `ifup wan_fm350_atc`) and compare tty port variants.
2. Test ATC bring-up on `/dev/ttyUSB2` and `/dev/ttyUSB1` under same stable-window conditions.
3. If crash persists, prepare package for OpenWrt-side ATC/netifd mitigation path.
