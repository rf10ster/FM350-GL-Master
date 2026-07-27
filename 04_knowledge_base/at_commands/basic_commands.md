# Basic AT Commands (RU/EN)

RU: Базовый справочник для первичной диагностики FM350-GL.
EN: Baseline reference for first-line FM350-GL diagnostics.

## Usage Notes

- Use the currently active AT port from preflight checks.
- Typical serial check flow: identify modem -> network registration -> signal -> operator.
- If commands timeout, re-check ttyUSB mapping before deeper troubleshooting.

## Command Reference

| Command | Purpose | Expected response (example) | If abnormal |
|---|---|---|---|
| `AT` | Port sanity check | `OK` | Wrong port or modem busy/unavailable |
| `ATI` | Device identity | vendor/model lines + `OK` | Port mismatch or modem not ready |
| `AT+CGMM` | Model string | `FM350-GL` + `OK` | Firmware/port mismatch |
| `AT+CGMR` | Firmware version | version string + `OK` | Keep output for experiment baseline |
| `AT+CGSN` | Modem serial/IMEI | numeric ID + `OK` | Missing output can indicate port instability |
| `AT+CSQ` | Signal quality | `+CSQ: <rssi>,<ber>` + `OK` | Very low RSSI may explain slow/no data |
| `AT+COPS?` | Operator status | `+COPS: ...` + `OK` | Not attached to expected operator |
| `AT+CREG?` | Network registration | `+CREG: ...,1` or `...,5` | Not registered -> diagnose SIM/network/signal |
| `AT+CGDCONT?` | PDP contexts | includes APN and PDP type | Missing PDP type can break ATC session |
| `AT+CGACT?` | PDP activation state | context `1,1` for active | Inactive PDP -> no internet session |
| `AT+CGPADDR=1` | Context IP address | assigned IPv4/IPv6 | No address -> PDP not fully active |
| `AT+QCFG?` | Vendor config dump | config lines + `OK` | Keep for before/after experiment diff |

## Minimal Diagnostic Sequence

```sh
# Replace /dev/ttyUSB3 with detected active AT port
echo -e 'AT\r' | socat -T10 - /dev/ttyUSB3,raw,echo=0,crnl
echo -e 'ATI\r' | socat -T10 - /dev/ttyUSB3,raw,echo=0,crnl
echo -e 'AT+CREG?\r' | socat -T10 - /dev/ttyUSB3,raw,echo=0,crnl
echo -e 'AT+CSQ\r' | socat -T10 - /dev/ttyUSB3,raw,echo=0,crnl
echo -e 'AT+CGDCONT?\r' | socat -T10 - /dev/ttyUSB3,raw,echo=0,crnl
```

RU: Для воспроизводимости сохраняйте вывод каждой команды.
EN: Save command outputs for reproducible diagnostics.
