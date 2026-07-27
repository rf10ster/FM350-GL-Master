#!/bin/sh
set -eu

# Live netifd xtrace tracer for FM350 ATC setup.
# It prepares a traced candidate copy locally, uploads it to the router,
# forces a live ifup window, and restores the original router script after.
#
# Usage:
#   sh trace_atc_live_xtrace.sh [router_alias] [candidate_file] [exp_tag] [window_seconds]
# Example:
#   sh trace_atc_live_xtrace.sh fm350-router 00_current_config/records/atc.sh.router.snapshot.exp024.candidate EXP037 8

ROUTER="${1:-fm350-router}"
CANDIDATE_FILE="${2:-00_current_config/records/atc.sh.router.snapshot.exp024.candidate}"
TAG="${3:-EXP037}"
WINDOW="${4:-8}"

ART_DIR="00_current_config/records/${TAG}_artifacts"
CSV_LOCAL="${ART_DIR}/${TAG}_live_xtrace.csv"
ORIG_LOCAL="${ART_DIR}/${TAG}_router_orig_atc.sh"
TRACED_LOCAL="${ART_DIR}/${TAG}_candidate_traced.sh"

mkdir -p "$ART_DIR"

awk '
BEGIN {
  printed_ps4 = 0
}
{
  if (NR == 1) {
    print $0
    print "PS4=\"__XTRACE__ ${LINENO}: \""
    print "set -x"
    printed_ps4 = 1
    next
  }
  print $0
}
END {
  if (printed_ps4 != 1) exit 24
}
' "$CANDIDATE_FILE" > "$TRACED_LOCAL"

ssh "$ROUTER" "cat /lib/netifd/proto/atc.sh" > "$ORIG_LOCAL"
ssh "$ROUTER" "cat > /tmp/${TAG}_candidate_traced.sh" < "$TRACED_LOCAL"
ssh "$ROUTER" "cat > /tmp/${TAG}_orig_atc.sh" < "$ORIG_LOCAL"

if ssh "$ROUTER" "TAG='$TAG' WINDOW='$WINDOW' sh -s" <<'EOSSH'
set -eu

F=/lib/netifd/proto/atc.sh
TRACED=/tmp/${TAG}_candidate_traced.sh
ORIG=/tmp/${TAG}_orig_atc.sh
CSV=/tmp/${TAG}_live_xtrace.csv

install_proto() {
  src="$1"
  cp "$src" "$F"
  chmod 755 "$F"
}

prep_safe() {
  uci set network.wan_fm350_atc.device='/dev/ttyUSB3'
  uci set network.wan_fm350_atc.apn='internet'
  uci set network.wan_fm350_atc.pdptype='IP'
  uci set network.wan_fm350_atc.auto='0'
  uci commit network
}

run_live() {
  kind="$1"
  trial="$2"
  tag="${TAG}_${kind}_T${trial}"
  iface="wan_fm350_atc"
  down_rc=0
  up_rc=0
  after_up_registered=0

  logger "${tag}_START"
  if ubus call network.interface down "{ \"interface\" : \"$iface\" }" >/dev/null 2>&1; then
    down_rc=0
  else
    down_rc=$?
  fi
  install_proto "$TRACED"
  prep_safe
  ubus call network reload >/dev/null 2>&1 || true
  found=0
  i=0
  while [ "$i" -lt 20 ]; do
    if ubus -S list "network.interface.$iface" >/dev/null 2>&1; then
      found=1
      break
    fi
    i=$((i+1))
    sleep 1
  done
  if [ "$found" -eq 1 ]; then
    echo "__LIVE__ ${kind} registered_before_up"
    if ubus call network.interface down "{ \"interface\" : \"$iface\" }" >/dev/null 2>&1; then
      down_rc=0
    else
      down_rc=$?
    fi
    if ubus call network.interface up "{ \"interface\" : \"$iface\" }" >/dev/null 2>&1; then
      up_rc=0
    else
      up_rc=$?
    fi
    if ubus -S list "network.interface.$iface" >/dev/null 2>&1; then
      after_up_registered=1
    fi
  else
    echo "__LIVE__ ${kind} not_registered_before_up"
    up_rc=99
  fi
  sleep "$WINDOW"
  if ubus call network.interface down "{ \"interface\" : \"$iface\" }" >/dev/null 2>&1; then
    :
  else
    :
  fi
  logger "${tag}_END"

  logread | awk "/${tag}_START/{flag=1;next}/${tag}_END/{flag=0}flag" > "/tmp/${tag}.log" || true
  xtrace=$(grep -Ec "__XTRACE__|Initiate modem with interface|unknown operand|Error running AT-command|Could not write to COM device" "/tmp/${tag}.log" || true)
  entry=$(grep -Ec "proto_atc_setup|load_start|top_level_begin|after_init_proto" "/tmp/${tag}.log" || true)
  echo "$trial,$kind,$entry,$xtrace,$found,$after_up_registered,$down_rc,$up_rc" >> "$CSV"
}

printf "trial,kind,entry_like,xtrace_like,registered_before_up,registered_after_up,down_rc,up_rc\n" > "$CSV"
run_live CAND 1

install_proto "$ORIG"
ubus call network reload >/dev/null 2>&1 || true
ifdown wan_fm350_atc 2>/dev/null || true

cat "$CSV"
EOSSH
then
  runner_rc=0
else
  runner_rc=$?
fi

ssh "$ROUTER" "cat /tmp/${TAG}_live_xtrace.csv" > "$CSV_LOCAL"
ssh "$ROUTER" "cat /tmp/${TAG}_CAND_T1.log 2>/dev/null || true" > "$ART_DIR/${TAG}_CAND_T1.log"

echo "Saved artifacts to: $ART_DIR"
if [ "$runner_rc" -ne 0 ]; then
  echo "Tracer exited with status $runner_rc"
fi
exit "$runner_rc"