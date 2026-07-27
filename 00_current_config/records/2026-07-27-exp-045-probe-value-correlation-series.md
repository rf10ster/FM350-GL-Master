# Experiment Record: EXP-045 Probe Value Correlation Series (3 short runs)

Date: 2026-07-27

## Goal

Correlate `no_iface_path` with live probe values (`devname`, `devpath`, `ifname`) and USB re-enumeration events using hardened launch tracing.

## Setup

- Script: `00_current_config/scripts/trace_atc_launch_path.sh`
- Added probe markers:
  - `probe_devname`
  - `probe_case`
  - `probe_devpath_*`
  - `probe_ifname_*`
  - `ifname_guard_value`
- Runs:
  - `EXP045A` (6s)
  - `EXP045B` (6s)
  - `EXP045C` (6s)

## Result

Window summary:

- `EXP045A,CAND`: `usb=0`, `no_iface=0`, probe markers mostly absent in window
- `EXP045A,BASE`: `usb=11`, `no_iface=2`, probe markers present
- `EXP045B,CAND`: `usb=0`, `no_iface=4`, probe markers present
- `EXP045B,BASE`: `usb=0`, `no_iface=4`, probe markers present
- `EXP045C,CAND`: `usb=0`, `no_iface=4`, probe markers present
- `EXP045C,BASE`: `usb=0`, `no_iface=4`, probe markers present

Representative probe lines (`EXP045B`):

- `probe_devname=ttyUSB3 device=/dev/ttyUSB3`
- `probe_case=usb`
- `probe_devpath_usb=` (empty)
- `probe_ifname_usb=` (empty)
- `ifname_guard_value=` (empty)
- followed by `No interface could be found yet` / `no_iface_path`

## Interpretation

- `no_iface_path` occurs even with `usb=0`, so it is not exclusively explained by immediate USB disconnect noise.
- The dominant local failure at this boundary is empty `devpath` -> empty `ifname` during probe resolution.
- Candidate-vs-base difference at this step is weak; both branches hit the same empty-probe failure mode under short-window runtime conditions.

## Integrity

- Post-series baseline remains canonical:
  - `/lib/netifd/proto/atc.sh` md5 `8d536e3353700b0dd854492838c9f53e`
  - `wan_fm350_atc` stays `proto: atc`
