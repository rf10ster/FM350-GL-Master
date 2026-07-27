#!/bin/sh
set -eu

# Launch-path tracer for FM350 ATC setup.
# It does not modify /lib/netifd/proto/atc.sh in place.
# Instead it builds temporary traced copies on the router and compares
# whether BASE/CAND reach the early ATC setup points.
#
# Usage:
#   sh trace_atc_launch_path.sh [router_alias] [exp_tag] [window_seconds]
# Example:
#   sh trace_atc_launch_path.sh fm350-router EXP032 8

ROUTER="${1:-fm350-router}"
TAG="${2:-EXP032}"
WINDOW="${3:-8}"

ART_DIR="00_current_config/records/${TAG}_artifacts"
CSV_LOCAL="${ART_DIR}/${TAG}_trace_results.csv"

mkdir -p "$ART_DIR"

if ssh "$ROUTER" "TAG='$TAG' WINDOW='$WINDOW' sh -s" <<'EOSSH'
set -eu

F=/lib/netifd/proto/atc.sh
B_RAW=/lib/netifd/proto/atc.sh.trace_${TAG}.base.raw
B=/lib/netifd/proto/atc.sh.trace_${TAG}.base
C_RAW=/tmp/atc.sh.${TAG}.trace.cand.raw
C=/tmp/atc.sh.${TAG}.trace.cand
TB=/tmp/atc.sh.${TAG}.trace.base
CSV=/tmp/${TAG}_trace_results.csv

cp "$F" "$B_RAW"

install_proto() {
  src="$1"
  cp "$src" "$F"
  chmod 755 "$F"
}

make_candidate() {
  awk '
  {
    line=$0
    if (line ~ /\[ \$OK_received -eq 10 -a \$pdp_still_active -eq 0 \] && \{/) {
      print "                    [ \"$OK_received\" -eq 10 ] && [ \"$pdp_still_active\" -eq 0 ] && {"
      next
    }
    print line
    if (line ~ /pdp_still_active=\$\(echo \$URCvalue \| awk -F/ && done==0) {
      print "                    case \"$pdp_still_active\" in"
      print "                        \"\"|*[!0-9]*) pdp_still_active=0 ;;"
      print "                        *) : ;;"
      print "                    esac"
      done=1
    }
  }
  END { if (done!=1) exit 23 }
  ' "$B_RAW" > "$C_RAW"
}

make_traced_copy() {
  src="$1"
  dst="$2"
  kind="$3"

  awk -v kind="$kind" '
  function trace(msg) { print "    echo \"__TRACE__ " kind " " msg "\"" }
  {
    print $0
    if (NR == 1) {
      trace("load_start")
      next
    }
    if ($0 ~ /^\[ -n "\$INCLUDE_ONLY" \] \|\| \{$/) {
      in_top=1
      trace("top_level_begin")
      next
    }
    if ($0 ~ /^    init_proto "\$@"$/) {
      trace("after_init_proto")
      next
    }
    if (in_top == 1 && $0 ~ /^\}$/) {
      trace("top_level_end")
      in_top=0
      next
    }
    if ($0 ~ /^proto_atc_setup \(\) \{$/) {
      trace("enter_setup")
      next
    }
    if ($0 ~ /^    json_get_vars device ifname apn pdp pincode auth username password delay atc_debug \$PROTO_DEFAULT_OPTIONS$/) {
      trace("after_json_get_vars")
      next
    }
    if ($0 ~ /^    \[ -z \$ifname \] && \{$/) {
      trace("before_ifname_probe")
      next
    }
    if ($0 ~ /^        devname=\$\(basename \$device\)$/) {
      print "        echo \"__TRACE__ " kind " probe_devname=$devname device=$device\""
      next
    }
    if ($0 ~ /^            \*ttyACM\*\)$/) {
      probe_case="acm"
      print "            echo \"__TRACE__ " kind " probe_case=acm\""
      next
    }
    if ($0 ~ /^            \*ttyUSB\*\)$/) {
      probe_case="usb"
      print "            echo \"__TRACE__ " kind " probe_case=usb\""
      next
    }
    if ($0 ~ /^                devpath="\$\(readlink -f \/sys\/class\/tty\/\$devname\/device\)"$/) {
      print "                echo \"__TRACE__ " kind " probe_devpath_" probe_case "=$devpath devname=$devname\""
      next
    }
    if ($0 ~ /^                \[ -n "\$devpath" \] && ifname="\$\(ls  \$devpath\/\.\.\/\*\/net\/\)" 2>\/dev\/null$/) {
      print "                echo \"__TRACE__ " kind " probe_ifname_acm=$ifname devpath=$devpath\""
      next
    }
    if ($0 ~ /^                \[ -n "\$devpath" \] && ifname="\$\(ls \$devpath\/\.\.\/\.\.\/\*\/net\/\)"  2>\/dev\/null$/) {
      print "                echo \"__TRACE__ " kind " probe_ifname_usb=$ifname devpath=$devpath\""
      next
    }
    if ($0 ~ /^    \[ -n "\$ifname" \] \|\| \{$/) {
      trace("before_ifname_guard")
      print "    echo \"__TRACE__ " kind " ifname_guard_value=$ifname\""
      next
    }
    if ($0 ~ /^        echo "No interface could be found yet"$/) {
      trace("no_iface_path")
      next
    }
    if ($0 ~ /^    echo Initiate modem with interface \$ifname$/) {
      trace("after_initiate")
      next
    }
    if ($0 ~ /^    atOut=\$\(COMMAND='AT\+CMEE=2' gcom -d "\$device" -s \/etc\/gcom\/run_at\.gcom\)$/) {
      trace("before_cmee")
      next
    }
    if ($0 ~ /^    COMMAND='AT\+CFUN=1' gcom -d "\$device" -s \/etc\/gcom\/at\.gcom$/) {
      trace("before_cfun1")
      next
    }
    if ($0 ~ /^    while read URCline$/) {
      trace("before_urc_loop")
      next
    }
    if ($0 ~ /^        return 1$/) {
      print "        echo \"__TRACE__ " kind " return_1\""
      next
    }
  }
  ' "$src" > "$dst"
}

prep_safe() {
  uci set network.wan_fm350_atc.device='/dev/ttyUSB3'
  uci set network.wan_fm350_atc.apn='internet'
  uci set network.wan_fm350_atc.pdptype='IP'
  uci set network.wan_fm350_atc.auto='0'
  uci commit network
  ubus call network reload >/dev/null 2>&1 || true
  ifdown wan_fm350_atc 2>/dev/null || true
}

run_window() {
  kind="$1"
  trial="$2"
  tag="${TAG}_${kind}_T${trial}"

  logger "${tag}_START"
  uci -q delete network.wan_fm350_atc.auto || true
  uci commit network
  ifup wan_fm350_atc || true
  sleep "$WINDOW"
  uci set network.wan_fm350_atc.auto='0'
  uci commit network
  ifdown wan_fm350_atc 2>/dev/null || true
  logger "${tag}_END"

  logread | awk "/${tag}_START/{flag=1;next}/${tag}_END/{flag=0}flag" > "/tmp/${tag}.log" || true

  enter=$(grep -Ec "__TRACE__ ${kind} enter_setup" "/tmp/${tag}.log" || true)
  after_json=$(grep -Ec "__TRACE__ ${kind} after_json_get_vars" "/tmp/${tag}.log" || true)
  if_probe=$(grep -Ec "__TRACE__ ${kind} before_ifname_probe" "/tmp/${tag}.log" || true)
  no_iface=$(grep -Ec "__TRACE__ ${kind} no_iface_path" "/tmp/${tag}.log" || true)
  cmee=$(grep -Ec "__TRACE__ ${kind} before_cmee" "/tmp/${tag}.log" || true)
  cfun1=$(grep -Ec "__TRACE__ ${kind} before_cfun1" "/tmp/${tag}.log" || true)
  urc=$(grep -Ec "__TRACE__ ${kind} before_urc_loop" "/tmp/${tag}.log" || true)
  after_init=$(grep -Ec "__TRACE__ ${kind} after_initiate" "/tmp/${tag}.log" || true)
  return1=$(grep -Ec "__TRACE__ ${kind} return_1" "/tmp/${tag}.log" || true)
  updown=$(grep -Ec "Interface 'wan_fm350_atc' is setting up now|Interface 'wan_fm350_atc' is now down" "/tmp/${tag}.log" || true)
  silent=$(grep -Ec "__TRACE__|Interface 'wan_fm350_atc' is setting up now|Interface 'wan_fm350_atc' is now down|Initiate modem with interface|Error running AT-command|Could not write to COM device|AT\+EIAAPN|unknown operand|wan_fm350_atc is disconnected" "/tmp/${tag}.log" || true)

  echo "$trial,$kind,$enter,$after_json,$if_probe,$no_iface,$after_init,$cmee,$cfun1,$urc,$return1,$updown,$silent" >> "$CSV"
}

make_candidate
make_traced_copy "$B_RAW" "$B" BASE
make_traced_copy "$C_RAW" "$C" CAND

ash -n "$B_RAW"
ash -n "$B"
ash -n "$C_RAW"
ash -n "$C"

printf "trial,kind,enter,after_json_get_vars,before_ifname_probe,no_iface_path,after_initiate,before_cmee,before_cfun1,before_urc_loop,return_1,updown,signal_like\n" > "$CSV"

install_proto "$C"
prep_safe
run_window CAND 1

install_proto "$B"
prep_safe
run_window BASE 1

install_proto "$B_RAW"
prep_safe
md5sum "$F"
cat "$CSV"
EOSSH
then
  runner_rc=0
else
  runner_rc=$?
fi

ssh "$ROUTER" "cat /tmp/${TAG}_trace_results.csv" > "$CSV_LOCAL"

for kind in CAND BASE; do
  remote_file="/tmp/${TAG}_${kind}_T1.log"
  local_file="${ART_DIR}/${TAG}_${kind}_T1.log"
  ssh "$ROUTER" "cat '$remote_file' 2>/dev/null || true" > "$local_file"
done

echo "Saved trace artifacts to: $ART_DIR"
if [ "$runner_rc" -ne 0 ]; then
  echo "Tracer exited with status $runner_rc"
fi
exit "$runner_rc"