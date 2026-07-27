# 02 Firmware Rollback Procedure (RU/EN)

RU: Минимальная безопасная процедура отката после неуспешного изменения.
EN: Minimal safe rollback procedure after unsuccessful changes.

## Scope

- Applies to recovery from configuration/firmware-related regressions.
- Focuses on restoring known-good network path and evidence continuity.

## Preconditions

1. Existing backup artifacts from `01-backup-procedure.md`
2. Physical access to router/modem power
3. Confirmed ability to run shell commands

## Step 1: Freeze Current State Before Rollback

```sh
date
ip addr
ip route
uci show network | grep -E 'wan_fm350_atc|wan_modem'
dmesg | tail -50
```

## Step 2: Restore Known-Good Network Config

```sh
# Example: restore previous exported network config
uci import network < network-backup-YYYYMMDD-HHMMSS.uci
uci commit network
/etc/init.d/network restart
```

## Step 3: Re-establish Connectivity Path

1. Try ATC primary (`wan_fm350_atc`) first if known-good.
2. If ATC is blocked, bring up DHCP fallback (`wan_modem` on `eth2`).

```sh
ifdown wan_fm350_atc 2>/dev/null || true
ifup wan_fm350_atc
sleep 3
ubus call network.interface.wan_fm350_atc status 2>/dev/null || true

ifdown wan_modem 2>/dev/null || true
ifup wan_modem
sleep 3
ubus call network.interface.wan_modem status 2>/dev/null || true
```

## Step 4: Validate Rollback

```sh
ip addr show eth2
ip route
ping -c2 -W2 8.8.8.8
```

Expected:

- valid IPv4 path on active profile
- default route available
- basic internet reachability

## Step 5: Record Post-Rollback Evidence

```sh
uci show network | grep -E 'wan_fm350_atc|wan_modem'
ls -la /dev/ttyUSB*
dmesg | tail -100
logread | tail -100
```

## Stop Condition

If rollback validation fails 3 times with same symptom, stop and open incident report using:

- `00_current_config/guides/03-incident-report-template.md`
