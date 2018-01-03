#!/bin/bash
# source: https://mensfeld.pl/2015/09/random-mac-address-changing-script-for-your-linux-wifi-mac-address-spoofing/

echo "This script requires root privileges"
hexchars="0123456789ABCDEF"
end=$( for i in {1..10}; do echo -n ${hexchars:$(( $RANDOM % 16 )):1}; done | sed -e 's/\(..\)/:\1/g' )
MAC=00$end

service network-manager stop
ifconfig wlp3s0 down
ifconfig wlp3s0 hw ether $MAC
ifconfig wlp3s0 up
service network-manager start

echo $MAC


