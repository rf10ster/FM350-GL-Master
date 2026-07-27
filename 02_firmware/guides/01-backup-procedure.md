# 01 Firmware Backup Procedure (RU/EN)

RU: Минимально безопасная процедура резервного копирования перед любыми прошивочными экспериментами.
EN: Minimal safe backup procedure before any firmware experiment.

## Scope

- This guide is for preparation and evidence capture.
- Do not start flashing without verified backups.

## Preconditions

1. Stable power source
2. Verified AT port access
3. Free storage for artifacts
4. Baseline completed from `00_current_config/guides/01-preflight-checks.md`

## Step 1: Capture Baseline Identity

```sh
date
uname -a
lsusb | grep -Ei 'fibocom|2cb7|0e8d'
```

## Step 2: Capture Modem Version and Config Snapshot

```sh
# Replace /dev/ttyUSB3 with active AT port
echo -e 'ATI\r' | socat -T10 - /dev/ttyUSB3,raw,echo=0,crnl
echo -e 'AT+CGMR\r' | socat -T10 - /dev/ttyUSB3,raw,echo=0,crnl
echo -e 'AT+QCFG?\r' | socat -T10 - /dev/ttyUSB3,raw,echo=0,crnl
```

Save raw outputs to timestamped text files.

## Step 3: Capture Router Network Backup

```sh
uci export network > network-backup-$(date +%Y%m%d-%H%M%S).uci
uci export system > system-backup-$(date +%Y%m%d-%H%M%S).uci
```

## Step 4: Capture Runtime Evidence

```sh
ip addr > ip-addr-$(date +%Y%m%d-%H%M%S).txt
ip route > ip-route-$(date +%Y%m%d-%H%M%S).txt
dmesg | tail -200 > dmesg-tail-$(date +%Y%m%d-%H%M%S).txt
logread | tail -200 > logread-tail-$(date +%Y%m%d-%H%M%S).txt
```

## Step 5: Check File Integrity

```sh
sha256sum *.uci *.txt > backup-sha256-$(date +%Y%m%d-%H%M%S).txt
```

## Required Output

- timestamped UCI exports
- timestamped AT snapshots
- runtime logs
- checksum manifest

RU: Если любой из этих пунктов отсутствует, прошивочный эксперимент откладывается.
EN: If any of these artifacts are missing, postpone flashing experiments.
