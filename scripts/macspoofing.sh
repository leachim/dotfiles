#!/bin/bash
# source: https://mensfeld.pl/2015/09/random-mac-address-changing-script-for-your-linux-wifi-mac-address-spoofing/
INTERFACE=wlp2s0

echo "This script requires root privileges"
echo "$INTERFACE"
sleep 3
hexchars="0123456789ABCDEF"
end=$( for i in {1..6}; do echo -n ${hexchars:$(( $RANDOM % 16 )):1}; done | sed -e 's/\(..\)/:\1/g' )
MAC=34:E1:2D$end

ip link set dev wlp2s0 down
ip link set dev wlp2s0 address $MAC
ip link set dev wlp2s0 up

echo $MAC


