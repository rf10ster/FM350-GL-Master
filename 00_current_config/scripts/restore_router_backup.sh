#!/bin/sh
set -eu

# Restore helper for OpenWrt sysupgrade backup archive.
# Default mode is dry-run (upload + verify only).
#
# Usage:
#   sh 00_current_config/scripts/restore_router_backup.sh <backup_dir_or_archive> [router_alias] [--apply]
#
# Examples:
#   sh 00_current_config/scripts/restore_router_backup.sh 00_current_config/backups/router_backup_2026-07-28_10-00-00 fm350-router
#   sh 00_current_config/scripts/restore_router_backup.sh 00_current_config/backups/router_backup_2026-07-28_10-00-00/sysupgrade_2026-07-28_10-00-00.tar.gz fm350-router --apply

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <backup_dir_or_archive> [router_alias] [--apply]" >&2
  exit 2
fi

SRC_PATH="$1"
ROUTER="${2:-fm350-router}"
MODE="${3:-}"

find_sysupgrade_archive() {
  input="$1"
  if [ -f "$input" ]; then
    echo "$input"
    return 0
  fi
  if [ -d "$input" ]; then
    f=$(find "$input" -maxdepth 2 -type f -name 'sysupgrade_*.tar.gz' | head -n 1)
    if [ -n "$f" ]; then
      echo "$f"
      return 0
    fi
  fi
  return 1
}

ARCHIVE="$(find_sysupgrade_archive "$SRC_PATH" || true)"
if [ -z "$ARCHIVE" ]; then
  echo "No sysupgrade archive found in: $SRC_PATH" >&2
  exit 3
fi

REMOTE_ARCHIVE="/tmp/restore_sysupgrade_$(date +%s).tar.gz"

ssh "$ROUTER" "cat > '$REMOTE_ARCHIVE'" < "$ARCHIVE"

echo "Uploaded archive to $ROUTER:$REMOTE_ARCHIVE"
ssh "$ROUTER" "ls -lh '$REMOTE_ARCHIVE'"

if [ "$MODE" = "--apply" ]; then
  echo "Applying restore via: sysupgrade -r $REMOTE_ARCHIVE"
  ssh "$ROUTER" "sysupgrade -r '$REMOTE_ARCHIVE'"
else
  echo "Dry-run only. To apply restore, run with --apply"
  echo "Command to execute on router: sysupgrade -r '$REMOTE_ARCHIVE'"
fi
