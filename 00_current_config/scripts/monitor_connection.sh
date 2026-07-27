#!/bin/bash

detect_at_port() {
  local port

  for port in /dev/ttyUSB*; do
    [ -e "$port" ] || continue
    if command -v socat >/dev/null 2>&1; then
      if printf 'AT\r' | socat -T2 - "$port,raw,echo=0,crnl" 2>/dev/null | grep -q "OK"; then
        echo "$port"
        return 0
      fi
    fi
  done

  for port in /dev/ttyUSB*; do
    [ -e "$port" ] || continue
    echo "$port"
    return 0
  done

  return 1
}

while true; do
  clear
  date
  lsusb | grep -Ei 'fibocom|2cb7|0e8d' || echo "Modem not detected"
  ip -br addr show | grep -E 'wwan|eth2' || echo "No modem interface"

  if AT_PORT="$(detect_at_port)"; then
    echo "AT port candidate: $AT_PORT"
  else
    echo "AT port candidate: not found"
  fi

  ping -c1 -W2 8.8.8.8 &>/dev/null && echo Online || echo Offline
  sleep 5
done
