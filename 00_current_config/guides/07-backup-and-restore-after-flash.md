# 07 Backup and Restore After Flash (RU/EN)

RU: Практичный runbook для бэкапа перед перепрошивкой и быстрого восстановления после нее.
EN: Practical runbook for pre-flash backup and fast post-flash restore.

## Scope

This guide uses project scripts:

- `00_current_config/scripts/create_router_backup.sh`
- `00_current_config/scripts/restore_router_backup.sh`

It produces artifacts inside the current project under:

- `00_current_config/backups/`

## A. Before Flash (Create Backup)

Run from project root:

```bash
sh 00_current_config/scripts/create_router_backup.sh fm350-router 00_current_config/backups
```

Expected output:

1. Backup folder `00_current_config/backups/router_backup_<timestamp>/`
2. Bundle archive `router_backup_<timestamp>.tar.gz`
3. OpenWrt restore archive `sysupgrade_<timestamp>.tar.gz`
4. Integrity file `SHA256SUMS.txt`

Quick verify:

```bash
ls -la 00_current_config/backups/router_backup_<timestamp>
grep -n "sysupgrade_" 00_current_config/backups/router_backup_<timestamp>/SHA256SUMS.txt
```

## B. Flash Firmware

Perform your regular firmware update flow.

Important:

1. Keep router reachable over SSH after first boot.
2. Do not run heavy ATC experiments before restore/checks.

## C. Restore After Flash

### C1. Dry-run (recommended first)

```bash
sh 00_current_config/scripts/restore_router_backup.sh \
  00_current_config/backups/router_backup_<timestamp> \
  fm350-router
```

This uploads restore archive to `/tmp` on router and prints the exact restore command.

### C2. Apply restore

```bash
sh 00_current_config/scripts/restore_router_backup.sh \
  00_current_config/backups/router_backup_<timestamp> \
  fm350-router --apply
```

This executes:

- `sysupgrade -r /tmp/restore_sysupgrade_<epoch>.tar.gz`

Router should reboot during restore.

## D. Post-Restore Validation

After router is back online:

```bash
ssh fm350-router 'ubus call network.interface.wan_fm350_atc status 2>/dev/null || true'
ssh fm350-router 'ls -l /lib/netifd/proto/atc.sh; md5sum /lib/netifd/proto/atc.sh'
ssh fm350-router 'uci show network.wan_fm350_atc || true'
```

Expected:

1. `wan_fm350_atc` object exists.
2. `/lib/netifd/proto/atc.sh` is executable (`-rwx...`).
3. `wan_fm350_atc` UCI section present.

## E. Recovery Notes

If ATC object exists but behaves unexpectedly:

1. Force network reload:
   - `ssh fm350-router 'ubus call network reload >/dev/null 2>&1 || /etc/init.d/network restart'`
2. Re-check ATC proto status.
3. Avoid tracer scripts until baseline checks are green.

If executable bit on `atc.sh` is lost:

```bash
ssh fm350-router 'chmod 755 /lib/netifd/proto/atc.sh; /etc/init.d/network restart >/dev/null 2>&1 || true'
```

## F. Recommended Artifact Retention

Keep at minimum for each firmware cycle:

1. Backup folder in `00_current_config/backups/`
2. Flash image metadata/version used
3. Post-restore validation output
