# Experiment Record: EXP-024 Guarded Candidate vs Baseline Control

## Metadata

- Experiment ID: EXP-024
- Date/time: 2026-07-27 16:48 UTC
- Operator: remote run from macOS via SSH alias
- Router: GL.iNet MT3000 (OpenWrt 24.10.7)
- Modem: FM350-GL via USB
- SIM/Operator: MegaFon

## Objective

- Validate offline candidate sanitize patch under strict guardrails.
- Compare behavior against baseline control run.
- Keep guaranteed rollback to safe mode and baseline script hash.

## Procedure

1. Hash baseline verification:
   - `/lib/netifd/proto/atc.sh` md5 = `8d536e3353700b0dd854492838c9f53e`
   - local snapshot md5 = `8d536e3353700b0dd854492838c9f53e`
2. Built offline candidate from snapshot:
   - sanitize after `pdp_still_active=$(...)` via `case` fallback to `0`
   - split compound numeric test to two guarded tests:
     - from: `[ $OK_received -eq 10 -a $pdp_still_active -eq 0 ]`
     - to: `[ "$OK_received" -eq 10 ] && [ "$pdp_still_active" -eq 0 ]`
3. Applied candidate on router temporarily, passed `ash -n` syntax check.
4. Ran bounded one-shot attempt (12s) with log follow capture.
5. Forced safe mode + rollback to baseline script backup.
6. Ran baseline control with same bounded window.

## Results

- Candidate run:
  - `syntax_check=OK`
  - `unknown_count=0`
  - reported `storm_count=4137`
  - extracted non-netifd lines from follow log: none
- Baseline control run:
  - `control_storm_count=1`
  - `control_unknown_count=0`
- Post-run integrity:
  - router `atc.sh` hash restored to baseline `8d536e3353700b0dd854492838c9f53e`

## Interpretation

- Candidate run reproduced heavy setup/down churn signature in observed capture window.
- Measurement caveat identified: `logread -f` can replay buffered historical lines, which can inflate simple line-count metrics if no explicit start marker is used.
- Because of this artifact, direct numeric comparison of raw storm counters is not yet fully reliable.

## Conclusion

- Router remained recoverable and baseline was restored successfully.
- Current evidence still indicates high regression risk for live `atc.sh` edits.
- Next diagnostics must use marker-bounded counting before deciding on any new live patch attempt.

## Next Action

1. Use marker-gated follow capture (`logger EXP_START`) and count only post-marker events.
2. Keep `auto=0` as default safe mode between attempts.
3. Avoid production script edits until marker-based method confirms causality with high confidence.
