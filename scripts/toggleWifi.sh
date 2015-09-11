#!/bin/bash
# Script to toggle the wireless blocked/unblocked

# index no. of phy interface
IFACE=`rfkill list all | grep phy | cut -c 1`

# WiFi block state 0=active, 1=blocked
BLOCKED=`rfkill list all | grep -iA1 phy | grep -ic soft.*yes`

if [ $BLOCKED -eq 1 ]; then
	rfkill unblock $IFACE

else
	rfkill block $IFACE
fi
