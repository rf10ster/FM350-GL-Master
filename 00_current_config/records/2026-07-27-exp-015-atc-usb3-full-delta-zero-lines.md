# Experiment Record: EXP-015 ATC ttyUSB3 Full Delta Capture (Zero Lines)

## Metadata

- Experiment ID: EXP-015
- Date/time: 2026-07-27
- Operator: remote run from macOS via SSH one-liner
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon
- Target AT port: `/dev/ttyUSB3`

## Objective

- Capture full unfiltered log delta into file after bounded 20s ATC attempt.
- Validate whether previous empty filtered slice was caused by grep patterns.

## Procedure

1. Saved baseline count: `BASE=$(logread | wc -l)` (`1222`).
2. Applied profile:
   - `device='/dev/ttyUSB3'`
   - `apn='internet'`
   - `pdptype='IP'`
3. Presence pre-check passed (`presence=ok step=1`).
4. Ran `enable`, waited 20s.
5. Exported delta:
   - `logread | tail -n +$((BASE+1)) > /tmp/exp015_delta_full.log`
6. Captured status and rolled back via `disable`.

## Results

- During attempt:
  - `up=false`
  - `pending=true`
  - `autostart=true`
- No IPv4 on `eth2`.
- Delta artifact size:
  - `0 /tmp/exp015_delta_full.log`
- After rollback:
  - `network.wan_fm350_atc.auto='0'`
  - `up=false`, `pending=false`, `autostart=false`

## Interpretation

- ATC attempt changes runtime state (`pending=true`) but produced no retrievable log delta with this method.
- Most likely causes:
  1. `logread` line-count baseline and export are not reliable for this runtime window,
  2. netifd/ATC emitted no lines at active log level during this attempt,
  3. ring-buffer semantics make line-delta extraction brittle.

## Next Action

1. Switch from static line-delta method to live stream capture (`logread -f`) in bounded window.
2. Save raw stream to `/tmp/exp016_logread_follow.log` and analyze afterward.
