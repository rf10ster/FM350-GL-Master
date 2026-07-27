#!/bin/sh
set -eu

# Create a reproducible router backup bundle and store it in this project.
# Usage:
#   sh 00_current_config/scripts/create_router_backup.sh [router_alias] [output_dir]
# Example:
#   sh 00_current_config/scripts/create_router_backup.sh fm350-router 00_current_config/backups

ROUTER="${1:-fm350-router}"
OUT_DIR="${2:-00_current_config/backups}"
TS="$(date +%F_%H-%M-%S)"
TAG="router_backup_${TS}"

LOCAL_DIR="${OUT_DIR}/${TAG}"
REMOTE_DIR="/tmp/${TAG}"

mkdir -p "$LOCAL_DIR"

ssh "$ROUTER" "REMOTE_DIR='$REMOTE_DIR' TS='$TS' sh -s" <<'EOSSH'
set -eu

mkdir -p "$REMOTE_DIR"

# Canonical OpenWrt backup (if available)
if command -v sysupgrade >/dev/null 2>&1; then
  sysupgrade -b "$REMOTE_DIR/sysupgrade_${TS}.tar.gz" >/dev/null 2>&1 || true
fi

# Core reproducibility exports
uci export > "$REMOTE_DIR/uci_export_${TS}.txt" 2>&1 || true
opkg list-installed > "$REMOTE_DIR/opkg_list_${TS}.txt" 2>&1 || true
ubus call network.interface dump > "$REMOTE_DIR/network_interface_dump_${TS}.json" 2>&1 || true
ubus call system board > "$REMOTE_DIR/system_board_${TS}.json" 2>&1 || true

# Useful runtime snapshots
uname -a > "$REMOTE_DIR/uname_${TS}.txt" 2>&1 || true
ip link > "$REMOTE_DIR/ip_link_${TS}.txt" 2>&1 || true
ip addr > "$REMOTE_DIR/ip_addr_${TS}.txt" 2>&1 || true
logread | tail -500 > "$REMOTE_DIR/logread_tail_${TS}.log" 2>&1 || true

# Keep a copy of current ATC protocol script and checksum.
if [ -f /lib/netifd/proto/atc.sh ]; then
  cp /lib/netifd/proto/atc.sh "$REMOTE_DIR/atc.sh_${TS}" || true
  md5sum /lib/netifd/proto/atc.sh > "$REMOTE_DIR/atc.sh_${TS}.md5" 2>&1 || true
  ls -l /lib/netifd/proto/atc.sh > "$REMOTE_DIR/atc.sh_${TS}.mode" 2>&1 || true
fi

# Best-effort modem AT snapshot if ttyUSB3 and gcom are available.
if command -v gcom >/dev/null 2>&1 && [ -c /dev/ttyUSB3 ]; then
  {
    echo "=== ATI ==="
    COMMAND='ATI' gcom -d /dev/ttyUSB3 -s /etc/gcom/getrun_at.gcom
    echo "=== AT+CGDCONT? ==="
    COMMAND='AT+CGDCONT?' gcom -d /dev/ttyUSB3 -s /etc/gcom/getrun_at.gcom
    echo "=== AT+CGACT? ==="
    COMMAND='AT+CGACT?' gcom -d /dev/ttyUSB3 -s /etc/gcom/getrun_at.gcom
  } > "$REMOTE_DIR/modem_snapshot_${TS}.log" 2>&1 || true
fi

# Checksums for all generated artifacts.
(
  cd "$REMOTE_DIR"
  sha256sum * > SHA256SUMS.txt 2>/dev/null || true
)
EOSSH

# Pull remote backup directory as one tar stream (no sftp/scp dependency).
ssh "$ROUTER" "tar -C '$REMOTE_DIR' -czf - ." > "$LOCAL_DIR/${TAG}.tar.gz"
tar -xzf "$LOCAL_DIR/${TAG}.tar.gz" -C "$LOCAL_DIR"

# Cleanup remote temp bundle directory.
ssh "$ROUTER" "rm -rf '$REMOTE_DIR'" || true

echo "Backup saved to: $LOCAL_DIR"
echo "Bundle: $LOCAL_DIR/${TAG}.tar.gz"
