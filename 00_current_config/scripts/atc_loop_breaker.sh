#!/bin/sh
set -eu

# Controlled ATC loop breaker for OpenWrt netifd ATC retry storms.
# Usage:
#   sh atc_loop_breaker.sh disable   # stop ATC auto-retry loop
#   sh atc_loop_breaker.sh enable    # re-enable ATC autostart and trigger ifup
#   sh atc_loop_breaker.sh status    # print current UCI/ubus state

ACTION="${1:-status}"

show_status() {
  echo "[ATC] UCI"
  uci show network.wan_fm350_atc | grep -E "proto|device|apn|pdptype|auto" || true
  echo
  echo "[ATC] UBUS"
  ubus call network.interface.wan_fm350_atc status 2>/dev/null || true
}

case "$ACTION" in
  disable)
    echo "[ATC] Disable autostart loop"
    uci set network.wan_fm350_atc.auto='0'
    uci commit network
    ifdown wan_fm350_atc 2>/dev/null || true
    show_status
    ;;
  enable)
    echo "[ATC] Enable autostart loop"
    # Remove explicit auto=0 override and return to default autostart behavior.
    uci -q delete network.wan_fm350_atc.auto || true
    uci commit network
    ifup wan_fm350_atc || true
    sleep 3
    show_status
    ;;
  status)
    show_status
    ;;
  *)
    echo "Usage: sh atc_loop_breaker.sh {disable|enable|status}" >&2
    exit 2
    ;;
esac
