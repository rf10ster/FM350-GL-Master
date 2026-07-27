# 01 Preflight Checks (RU/EN)

RU: Подготовка перед любыми изменениями сети и модема.
EN: Preparation before any modem or network changes.

## Goal

- Confirm hardware visibility
- Capture baseline state
- Detect likely blockers early

## Step 1: Hardware and USB Presence

```sh
lsusb | grep -Ei 'fibocom|2cb7|0e8d'
ls -la /dev/ttyUSB*
```

Expected:

- Modem appears in `lsusb`
- At least one `ttyUSB*` device exists

## Step 2: Current Network State Snapshot

```sh
uci show network | grep -E 'wan_fm350_atc|wan_modem'
ip addr
ip route
ubus call network.interface.wan_fm350_atc status 2>/dev/null || true
ubus call network.interface.wan_modem status 2>/dev/null || true
```

Expected:

- Existing logical interfaces are visible (or absent by design)
- Current routes are known before changes

## Step 3: AT Port Sanity

```sh
dmesg | tail -30
```

Expected:

- No obvious USB disconnect storm
- Latest ttyUSB attachment sequence is visible

## Step 4: Baseline Connectivity

```sh
ping -c2 -W2 8.8.8.8
```

Expected:

- Success is optional, but result must be recorded

## Required Evidence Artifact Block

Save outputs (copy/paste or log file) for:

1. `lsusb` modem line
2. `/dev/ttyUSB*` list
3. `uci show network` relevant lines
4. `ip addr` and `ip route`
5. `ubus` interface status
6. `dmesg` tail
7. baseline ping result

RU: Без этого блока не начинайте настройку.
EN: Do not start setup without this block.
