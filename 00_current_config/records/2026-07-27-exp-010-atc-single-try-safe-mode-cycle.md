# Experiment Record: EXP-010 ATC Single-Try with Safe-Mode Return

## Metadata

- Experiment ID: EXP-010
- Date/time: 2026-07-27 16:05 UTC
- Operator: remote run from macOS via SSH one-liner
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Validate controlled cycle:
  1. temporarily re-enable ATC autostart,
  2. allow one short ATC setup attempt,
  3. return to safe-mode (`auto=0`) to avoid retry loop.
- Capture first deterministic failure signature in this bounded window.

## Procedure

1. Upload and execute `/tmp/atc_loop_breaker.sh`.
2. Run `enable`, wait 8 seconds.
3. Collect:
   - `ubus call network.interface.wan_fm350_atc status`
   - `ip -4 -o addr show dev eth2`
   - `logread` tail filtered for ATC critical signatures.
4. Run `disable` and `status`.

## Results

### During single try (enable window)

- Interface state:
  - `up=false`
  - `pending=true`
  - `autostart=true`
- No IPv4 on `eth2`.
- Critical error captured immediately:
  - `Error@180, line 10, Could not write to COM device. (1)`

### After return to safe-mode (disable)

- UCI contains `network.wan_fm350_atc.auto='0'`.
- Interface state stabilized to controlled idle:
  - `up=false`
  - `pending=false`
  - `autostart=false`

## Conclusion

- Bounded single-attempt cycle is reproducible and useful for diagnostics.
- Core failure remains in ATC modem command path (`Could not write to COM device`) even in short controlled run.
- M2 safe-mode reliably suppresses repeated netifd re-setup behavior after capture.

## Next Action

1. Repeat single-attempt cycle with explicit `device='/dev/ttyUSB3'` and pre-check of `ttyUSB3 + eth2` presence.
2. Compare whether first-failure signature differs between `ttyUSB1` and `ttyUSB3` under same bounded window.
