# Troubleshooting Decision Tree (RU/EN)

RU: Дерево решений для типовых сбоев FM350-GL на OpenWrt.
EN: Decision tree for common FM350-GL failures on OpenWrt.

## Start Here

1. Run preflight from `00_current_config/guides/01-preflight-checks.md`.
2. Confirm canonical profile strategy from `ARCHITECTURE.md`.
3. Collect required artifacts before changing anything.

## Tree

### 1) Interface not found (`wan_fm350_atc` or `wan_modem`)

- Check: `uci show network | grep -E 'wan_fm350_atc|wan_modem'`
- If missing: recreate UCI block from reference profile.
- Validate: `ubus call network.interface.<name> status`

### 2) AT commands do not respond

- Check: `ls -la /dev/ttyUSB*` and `dmesg | tail -30`
- Try alternative ttyUSB candidate.
- If still failing: reconnect modem and re-run preflight.

### 3) ATC bring-up fails with `SESSION_FAILED`

- Verify `pdptype='IP'` in `wan_fm350_atc`.
- Check APN and PDP context via `AT+CGDCONT?`.
- Retry `ifdown/ifup` after correcting UCI values.

### 4) Interface exists but no IPv4 on `eth2`

- Check: `ip addr show eth2`
- Verify modem mode/driver state via `dmesg` and `logread`.
- For ATC path: verify PDP activation (`AT+CGACT?`, `AT+CGPADDR=1`).

### 5) IPv4 present but no default route

- Check: `ip route`
- Ensure active logical interface is up in `ubus`.
- Recycle target interface and confirm route after 3-5 seconds.

### 6) Route exists but internet unavailable

- Test: `ping -c2 -W2 8.8.8.8`
- If failed: inspect DNS and upstream network restrictions.
- Validate operator registration: `AT+COPS?`, `AT+CREG?`.

### 7) Low throughput or unstable link

- Check signal: `AT+CSQ`
- Confirm antenna/power conditions.
- Compare behavior across USB modes only after stable baseline is documented.

### 8) Need urgent connectivity recovery

- Switch to DHCP fallback profile (`wan_modem` on `eth2`).
- Keep ATC artifacts for root-cause analysis.
- Return to ATC after issue is fixed.

## Fail-Fast Rule

- Stop repeated random retries when the same error repeats 3 times.
- Re-enter at the previous checkpoint with fresh artifacts.

## Mandatory Artifacts Per Incident

1. `uci show network` relevant lines
2. `ubus` status of active interface
3. `ip addr show eth2`
4. `ip route`
5. relevant `logread` and `dmesg`
6. AT output used in diagnosis
