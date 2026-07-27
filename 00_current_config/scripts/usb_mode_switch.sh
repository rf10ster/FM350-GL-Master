#!/bin/bash
echo "1) Standard  2) Fastboot"
read -p "Choose: " c
[ "$c" = "1" ] && echo 'AT+QCFG="usbnet",0' > /dev/ttyUSB2
[ "$c" = "2" ] && echo 'AT+QCFG="usbnet",3' > /dev/ttyUSB2
