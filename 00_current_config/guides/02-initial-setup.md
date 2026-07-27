# 02 Initial Setup From Zero (RU/EN)

RU: Базовый путь настройки с нуля: сначала ATC, затем DHCP fallback при необходимости.
EN: Zero-state setup path: ATC first, DHCP fallback only if needed.

## Branch A (Primary): ATC Profile

### A1. Apply Reference Profile

```sh
uci batch <<'EOF'
set network.wan_fm350_atc=interface
set network.wan_fm350_atc.proto='atc'
set network.wan_fm350_atc.device='/dev/ttyUSB3'
set network.wan_fm350_atc.apn='internet.beeline.ru'
set network.wan_fm350_atc.pdptype='IP'
commit network
EOF
```

Note:

- Replace `/dev/ttyUSB3` with the currently active AT port from preflight.

### A2. Restart Interface

```sh
ifdown wan_fm350_atc 2>/dev/null || true
ifup wan_fm350_atc
sleep 3
```

### A3. Validate Session

```sh
ubus call network.interface.wan_fm350_atc status
ip addr show eth2
ip route
```

Expected:

- Interface status is up or progressing to up
- `eth2` has IPv4 address
- default route appears via modem path

## Branch B (Fallback): DHCP on eth2

Use only if Branch A is blocked and quick recovery is needed.

### B1. Apply Fallback Profile

```sh
uci batch <<'EOF'
set network.wan_modem=interface
set network.wan_modem.proto='dhcp'
set network.wan_modem.device='eth2'
commit network
EOF
```

### B2. Bring Up Fallback

```sh
ifdown wan_modem 2>/dev/null || true
ifup wan_modem
sleep 3
```

### B3. Validate Fallback

```sh
ubus call network.interface.wan_modem status
ip addr show eth2
ip route
ping -c2 -W2 8.8.8.8
```

Expected:

- DHCP lease on `eth2`
- default route via `eth2`
- ping success

## Failure Handling Shortlist

1. `SESSION_FAILED` on ATC:
   - verify `pdptype='IP'`
   - re-check active ttyUSB port
2. `Interface not found`:
   - recreate UCI interface block
3. no IPv4 on `eth2`:
   - inspect `dmesg` and modem USB mode

## Required Evidence After Setup

Collect:

1. Final `uci show network` lines for active profile
2. `ubus` status for active interface
3. `ip addr show eth2`
4. `ip route`
5. `ping` result
