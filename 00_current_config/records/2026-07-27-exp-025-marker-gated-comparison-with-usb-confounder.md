# Experiment Record: EXP-025 Marker-Gated Comparison with USB Confounder

## Metadata

- Experiment ID: EXP-025
- Date/time: 2026-07-27 16:50 UTC
- Operator: remote run from macOS via SSH heredoc
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Remove `logread -f` buffered replay artifact.
- Compare baseline and candidate in equal marker-bounded windows.
- Keep guaranteed rollback to baseline hash.

## Method

1. Baseline prepared in safe mode (`auto=0`, `ifdown`).
2. Marker window A:
   - `logger EXP024_BASE_START`
   - `ifup wan_fm350_atc`, wait 6s
   - `auto=0`, `ifdown`
   - `logger EXP024_BASE_END`
3. Candidate patch applied temporarily (`ash -n` passed).
4. Marker window B with same timing:
   - `logger EXP024_CAND_START` ... `logger EXP024_CAND_END`
5. Extracted only lines between markers and counted:
   - up/down lines
   - `unknown operand`
   - non-up/down lines.
6. Restored original script and safe mode.

## Results

- Baseline window:
  - `EXP024_BASE_updown=1`
  - `EXP024_BASE_unknown=0`
  - `EXP024_BASE_other=1`
  - non-up/down line: `Initiate modem with interface eth2`
- Candidate window:
  - `EXP024_CAND_updown=225`
  - `EXP024_CAND_unknown=0`
  - `EXP024_CAND_other=19`
  - non-up/down lines include USB disconnect/re-enumeration events (`eth2 unregister`, `ttyUSB* disconnected`, new USB device attach)
- Post-test script integrity:
  - `/lib/netifd/proto/atc.sh` md5 restored to `8d536e3353700b0dd854492838c9f53e`

## Interpretation

- Marker-gated method removed the replay-count artifact and confirmed a strong up/down delta between windows.
- However, candidate window simultaneously contained an explicit USB disconnect/re-enumeration storm.
- This is a hard confounder: observed loop amplification cannot be attributed to script patch alone with high confidence.

## Conclusion

- Causality remains unresolved: candidate patch correlates with heavy loop count, but hardware instability occurred in the same measurement window.
- `unknown operand` was absent in both marker windows.
- Rollback and baseline integrity controls worked as expected.

## Next Action

1. Add pre-gate and in-window validity rule:
   - run is valid only if no USB disconnect/re-enumeration lines appear between start/end markers.
2. Repeat marker-gated A/B only in hardware-stable windows.
3. Keep production `atc.sh` at baseline between all attempts.
