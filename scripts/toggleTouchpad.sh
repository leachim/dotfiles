#!/bin/bash
# Copyright (c) 2013 Scott Garman
#
# This script will toggle the functionality of your Synaptics touchpad,
# restarting syndaemon as needed, and send a desktop notification event
# for some visual feedback. It is even more useful when run via a custom
# keyboard binding.

idle_time=1.2 # seconds

killall syndaemon

state=`synclient -l | grep TouchpadOff | sed 's/^.*= //'`
if [ $state -eq 1 ]
then
	notify-send "Touchpad on"
	synclient TouchpadOff=0
	syndaemon -i $idle_time -d
else
	notify-send "Touchpad off"
	synclient TouchpadOff=1
fi
