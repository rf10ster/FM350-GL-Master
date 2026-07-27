#!/bin/sh
set -eu

# Marker-gated baseline vs candidate A/B runner for FM350 ATC script tests.
# Runs on local machine and executes experiment on router via ssh.
#
# Usage:
#   sh run_exp_ab_marker_series.sh [router_alias] [trials] [window_seconds] [exp_tag] [min_info_base] [min_info_cand]
# Example:
#   sh run_exp_ab_marker_series.sh fm350-router 5 6 EXP027
#   sh run_exp_ab_marker_series.sh fm350-router 20 12 EXP029 5 5

ROUTER="${1:-fm350-router}"
TRIALS="${2:-5}"
WINDOW="${3:-6}"
TAG="${4:-EXP027}"
MIN_INFO_BASE="${5:-0}"
MIN_INFO_CAND="${6:-0}"

ART_DIR="00_current_config/records/${TAG}_artifacts"
CSV_LOCAL="${ART_DIR}/${TAG}_ab_results.csv"

mkdir -p "$ART_DIR"

if ssh "$ROUTER" "TRIALS='$TRIALS' WINDOW='$WINDOW' TAG='$TAG' MIN_INFO_BASE='$MIN_INFO_BASE' MIN_INFO_CAND='$MIN_INFO_CAND' sh -s" <<'EOSSH'
set -eu

F=/lib/netifd/proto/atc.sh
B=/lib/netifd/proto/atc.sh.bak_${TAG}
C=/tmp/atc.sh.${TAG}.candidate
CSV=/tmp/${TAG}_ab_results.csv

cp "$F" "$B"

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
  ' "$B" > "$C"
}

prep_safe() {
  uci set network.wan_fm350_atc.device='/dev/ttyUSB3'
  uci set network.wan_fm350_atc.apn='internet'
  uci set network.wan_fm350_atc.pdptype='IP'
  uci set network.wan_fm350_atc.auto='0'
  uci commit network
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

  updown=$(grep -Ec "Interface 'wan_fm350_atc' is setting up now|Interface 'wan_fm350_atc' is now down" "/tmp/${tag}.log" || true)
  unknown=$(grep -Ec "unknown operand" "/tmp/${tag}.log" || true)
  usb=$(grep -Ec "USB disconnect|eth2: unregister|ttyUSB[0-9].*disconnected|new SuperSpeed USB device" "/tmp/${tag}.log" || true)
  signal=$(grep -Ec "Initiate modem with interface|wan_fm350_atc is disconnected|Error running AT-command|Could not write to COM device|AT\+EIAAPN" "/tmp/${tag}.log" || true)

  valid=1
  [ "$usb" -gt 0 ] && valid=0

  informative=1
  [ "$updown" -eq 0 ] && [ "$signal" -eq 0 ] && informative=0

  silent=0
  [ "$updown" -eq 0 ] && [ "$signal" -eq 0 ] && silent=1

  echo "$trial,$kind,$valid,$informative,$updown,$unknown,$usb,$signal,$silent" >> "$CSV"
}

make_candidate
ash -n "$B"
ash -n "$C"

printf "trial,kind,valid,informative,updown,unknown,usb,signal,silent\n" > "$CSV"

for t in $(seq 1 "$TRIALS"); do
  install_proto "$B"
  prep_safe
  run_window BASE "$t"

  install_proto "$C"
  prep_safe
  run_window CAND "$t"

  if [ "$MIN_INFO_BASE" -gt 0 ] || [ "$MIN_INFO_CAND" -gt 0 ]; then
    base_info=$(awk -F, 'NR>1 && $2=="BASE" && $3==1 && $4==1 {n++} END {print n+0}' "$CSV")
    cand_info=$(awk -F, 'NR>1 && $2=="CAND" && $3==1 && $4==1 {n++} END {print n+0}' "$CSV")
    if [ "$base_info" -ge "$MIN_INFO_BASE" ] && [ "$cand_info" -ge "$MIN_INFO_CAND" ]; then
      echo "INFO: reached informative thresholds at trial $t (BASE=$base_info/$MIN_INFO_BASE, CAND=$cand_info/$MIN_INFO_CAND)"
      break
    fi
  fi
done

install_proto "$B"
prep_safe

echo "--- raw ---"
cat "$CSV"
echo "--- valid+informative summary ---"
awk -F, 'NR>1 && $3==1 && $4==1 {n[$2]++; s[$2]+=$5} END {for (k in n) printf "%s n=%d mean_updown=%.2f\n",k,n[k],s[k]/n[k]; if (n["BASE"]==0 || n["CAND"]==0) print "WARN: insufficient valid+informative windows"}' "$CSV"
echo "--- silent-window summary ---"
awk -F, '
NR>1 {
  total[$2]++
  if ($9==1) silent[$2]++
  if ($3==1) {
    valid[$2]++
    if ($9==1) valid_silent[$2]++
  }
}
END {
  for (k in total) {
    sr = (total[k] > 0) ? (100.0 * silent[k] / total[k]) : 0
    vsr = (valid[k] > 0) ? (100.0 * valid_silent[k] / valid[k]) : 0
    printf "%s total=%d silent=%d silent_rate=%.1f%% valid=%d valid_silent=%d valid_silent_rate=%.1f%%\n", k, total[k], silent[k], sr, valid[k], valid_silent[k], vsr
  }
}' "$CSV"
if [ "$MIN_INFO_BASE" -gt 0 ] || [ "$MIN_INFO_CAND" -gt 0 ]; then
  base_info=$(awk -F, 'NR>1 && $2=="BASE" && $3==1 && $4==1 {n++} END {print n+0}' "$CSV")
  cand_info=$(awk -F, 'NR>1 && $2=="CAND" && $3==1 && $4==1 {n++} END {print n+0}' "$CSV")
  if [ "$base_info" -lt "$MIN_INFO_BASE" ] || [ "$cand_info" -lt "$MIN_INFO_CAND" ]; then
    echo "WARN: informative thresholds not reached (BASE=$base_info/$MIN_INFO_BASE, CAND=$cand_info/$MIN_INFO_CAND)"
    exit 3
  fi
fi
md5sum /lib/netifd/proto/atc.sh
EOSSH
then
  runner_rc=0
else
  runner_rc=$?
fi

# Fetch artifacts without sftp/scp dependency (router may not provide sftp-server).
ssh "$ROUTER" "cat /tmp/${TAG}_ab_results.csv" > "$CSV_LOCAL"

for t in $(seq 1 "$TRIALS"); do
  for kind in BASE CAND; do
    remote_file="/tmp/${TAG}_${kind}_T${t}.log"
    local_file="${ART_DIR}/${TAG}_${kind}_T${t}.log"
    ssh "$ROUTER" "cat '$remote_file' 2>/dev/null || true" > "$local_file"
  done
done

echo "Saved artifacts to: $ART_DIR"
if [ "$runner_rc" -ne 0 ]; then
  echo "Runner exited with status $runner_rc"
fi
exit "$runner_rc"
