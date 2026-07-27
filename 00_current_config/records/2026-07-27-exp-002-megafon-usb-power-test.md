# Experiment Record: EXP-002 MegaFon + External Power USB Stability Test

## Metadata

- Experiment ID: EXP-002
- Date/time: 2026-07-27 15:28-15:36 UTC
- Operator: live SSH session
- Router: GL.iNet MT3000, OpenWrt 24.10.7
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Verify whether additional external power stabilizes USB modem presence enough to bring up WAN.
- Apply MegaFon APN in ATC profile and validate ATC and DHCP fallback branches.

## Applied Config

- `network.wan_fm350_atc.proto='atc'`
- `network.wan_fm350_atc.device='/dev/ttyUSB3'`
- `network.wan_fm350_atc.apn='internet'`
- `network.wan_fm350_atc.pdptype='IP'`
- `network.wan_modem.proto='dhcp'`
- `network.wan_modem.device='eth2'`

## Step Results

### Step 1: ATC bring-up after waiting for ttyUSB/eth2

- Wait window: 40 seconds
- Observed each second: `ttyUSB=0`, `eth2=no`
- Result: failed (modem interfaces did not remain present)

### Step 2: DHCP fallback (`wan_modem`)

- `ifup wan_modem` executed
- `ubus` status: `up=false`, `available=false`, error `NO_DEVICE`
- `ip addr show eth2`: no device/address
- Result: failed (no modem network device available)

### Step 3: Artifact snapshot

- `wan_fm350_atc` config present with MegaFon APN + PDP type IP
- `wan_modem` config present
- `ls /dev/ttyUSB*`: no devices at snapshot moment
- `ip link show eth2`: no device at snapshot moment
- default route remains via `phy0-sta0`

## Critical Logs (summary)

- Repeated attach/detach cycles:
  - `ttyUSB0..ttyUSB7` attach then disconnect
  - `rndis_host ... eth2: register/unregister`
- netifd/comgt errors on ATC path:
  - `Can't ioctl set device. (1)`
  - `No interface could be found yet`
- USB sequence ends with re-enumeration attempts (new SuperSpeed device numbers)

## Outcome

- External power did not resolve instability in this run.
- APN migration to MegaFon completed successfully at config level.
- Primary blocker is USB re-enumeration/disconnect storm, not APN/PDP config.

## Next Action

1. Freeze USB mode and stop repeated reconnect loop at hardware/USB layer.
2. Retry bring-up only when `ttyUSB*` and `eth2` remain stable for at least 30-60s.
3. Capture full `dmesg` window around one stable/unstable cycle and compare with cable/port variants.
