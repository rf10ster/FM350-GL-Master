#!/bin/bash
while true; do
  clear
  date
  lsusb | grep 2cb7
  ip -br addr show | grep wwan
  ping -c1 -W2 8.8.8.8 &>/dev/null && echo Online || echo Offline
  sleep 5
done
