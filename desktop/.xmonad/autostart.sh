#!/bin/sh

# set the cursor
xsetroot -cursor_name left_ptr

# Programs to launch at startup
#sh ~/.fehbg &
#~/.xmonad/bin/conkybar.sh &
#~/.xmonad/bin/musicbar.sh &
#trayer --edge bottom --align right --SetDockType true --SetPartialStrut true --expand true --width 10 --widthtype percent --transparent true --tint black --alpha 0 --height 12 &
#trayer --edge bottom --align right --SetDockType true --SetPartialStrut true --expand true --width 100 --transparent true --tint black --alpha 0 --height 12 &

#stalonetray --icon-gravity E --geometry 5x1-0+0 --max-geometry 5x1-0+0 --background '#000000' --skip-taskbar --icon-size 16 --kludges force_icons_size --window-strut none &
stalonetray --icon-gravity SE --geometry 6x1-0+0 --max-geometry 8x1-0+0 --background '#000000' --skip-taskbar --icon-size 16 --kludges force_icons_size --window-strut none --no-shrink false --grow-gravity W &

#trayer --edge bottom --align right --distance 1 --widthtype request --heighttype request --SetDockType true --expand true --transparent false --alpha 255

# Programs which will run after Xmonad has started
sleep 1
urxvtc +bc +uc -cr Green -name tmux -e tmux -2 attach &
#urxvtc -name ranger -e ranger &
#firefox &
#urxvtc -name weechat -e weechat-curses &
#urxvtc -name ncmpcpp -e ncmpcpp &
#urxvtc -name mutt -e mutt &
#sleep 1 
#urxvtc -name newsbeuter -e newsbeuter & 
#urxvtc -name unison -e unison -repeat 600 raspi &
#sleep 1 
#urxvtc -name slurm -e slurm -i eth0 &
#urxvtc -name nethogs -e sudo nethogs -d3 eth0 &
#urxvtc -name iftop -e sudo iftop -i eth0 &
#sleep 1
#urxvtc -name htop -e htop &

###!/bin/bash
# 
# xmonad "startup hook" script. This gets run after xmonad is initialized,
# via the startupHook facility provided by xmonad. It's useful for 
# running any programs which you want to use within xmonad but
# which don't need to be initialized before xmonad is running. 
#
# Author: David Brewer
# Repository: https://github.com/davidbrewer/xmonad-ubuntu-conf

#
# TRAY ICON SOFTWARE
#

# Empathy chat client (-h: start hidden, -n: don't connect on launch)
#if [ -z "$(pgrep empathy)" ] ; then
    #empathy -h -n &
#fi

# Remmina remote desktop connection client (-i: start hidden)
#if [ -z "$(pgrep remmina)" ] ; then
    #remmina -i &
#fi

# Network manager, so we don't have to configure wifi at the command line.
#if [ -z "$(pgrep nm-applet)" ] ; then
    #nm-applet --sm-disable &
#fi

# Applet for managing print jobs from the tray.
#if [ -z "$(pgrep system-config-printer-applet)" ] ; then
    #system-config-printer-applet &
#fi

#
# APPLICATION LAUNCHER
#

# Use synapse as our app launcher. (-s: don't display until requested) 
#if [ -z "$(pgrep synapse)" ] ; then
    #synapse -s &
#fi

# On login, we unlock the ssh keychain so we're not prompted for 
# passphrases later. We pipe /dev/null to ssh-add to make it realize 
# it's not running in a terminal. Otherwise, it won't launch the prompt.
# 
# If you don't use the ssh keychain you may not want this. Commented
# by default as it is assumed many users will not want this feature.

# export SSH_ASKPASS="/usr/bin/ssh-askpass"
# cat /dev/null | ssh-add &

# I disable the middle mouse button because otherwise I constantly 
# accidentally paste unwanted text in the middle of my code while scrolling. 
# Note that the id of the mouse device may be different depending on 
# which usb port it is plugged into! To find it, use:
# xinput list |grep 'id='
# In the following command, the id is the first argument, the rest is 
# the remapping.

# Commented by default as it is assumed many users will not want this.
# xinput set-button-map 10 1 0 3 4 5 6 7

# I disabled my touchpad because I hate those things. You can find the id
# of a device you want to disable using "xinput list"; unfortunately it can
# change depending on what devices you have plugged into USB. We extract the
# id of the device from the output of xinput, then use it to disable the
# device
#TOUCHPAD_ID=`xinput | grep 'Synaptics TouchPad' | cut -f 2 | cut -f 2 -d =`
#xinput set-prop $TOUCHPAD_ID "Device Enabled" 0
