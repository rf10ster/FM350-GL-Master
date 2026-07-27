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

send_at() {
	local port="$1"
	local cmd="$2"

	if command -v socat >/dev/null 2>&1; then
		printf '%s\r' "$cmd" | socat -T10 - "$port,raw,echo=0,crnl"
	else
		printf '%s\r' "$cmd" > "$port"
		echo "socat not found; command written to $port without response capture"
	fi
}

if ! AT_PORT="$(detect_at_port)"; then
	echo "No ttyUSB AT port detected"
	exit 1
fi

echo "Detected AT port: $AT_PORT"
echo "1) MBIM-like (usbnet=0)"
echo "2) QMI-like (usbnet=3)"
read -r -p "Choose mode [1/2]: " c

case "$c" in
	1)
		echo "Sending AT+QCFG=\"usbnet\",0"
		send_at "$AT_PORT" 'AT+QCFG="usbnet",0'
		;;
	2)
		echo "Sending AT+QCFG=\"usbnet\",3"
		send_at "$AT_PORT" 'AT+QCFG="usbnet",3'
		;;
	*)
		echo "Unknown choice: $c"
		exit 1
		;;
esac
