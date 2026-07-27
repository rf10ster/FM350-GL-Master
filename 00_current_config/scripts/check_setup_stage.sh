#!/bin/bash
echo "FM350-GL Setup Stage Checker"
lsusb | grep "2cb7" || echo "Modem not detected"
ip link show | grep wwan || echo "No wwan interface"
ping -c1 8.8.8.8 &>/dev/null && echo "Internet OK" || echo "No Internet"
