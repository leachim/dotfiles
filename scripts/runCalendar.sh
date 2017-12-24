#!/bin/bash

# gcalcli is a program installed from 
# https://github.com/insanum/gcalcli

# Note that it is a python 2.7 program

# you need to edit crontab as follows
# $ crontab -e
# MAILTO=""
# */10 * * * * /bin/bash /home/michael/.dotfiles/scripts/runCalendar.sh

# dbus_session_file=~/.dbus/session-bus/$(cat /var/lib/dbus/machine-id)-0
# if [ -e "$dbus_session_file" ]; then
  # . "$dbus_session_file"
  # export DBUS_SESSION_BUS_ADDRESS DBUS_SESSION_BUS_PID
  # export $(</proc/$DBUS_SESSION_BUS_PID/environ tr \\0 \\n | grep -E '^DBUS_SESSION_BUS_ADDRESS=')
# fi

# PID=$(pgrep i3)  # instead of 'gnome-session' it can be also used 'noutilus' or 'compiz' or the name of a process of a graphical program about that you are sure that is running after you log in the X session
# export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2-)
export DISPLAY=:0
# echo $DBUS_SESSION_BUS_ADDRESS
# export XAUTHORITY=/home/michael/.Xauthority
# eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME gnome-session)/environ)";
# /usr/bin/python2.7 ~/.local/bin/gcalcli remind 10 "notify-send -u normal -c popup -a Calendar %s" #>/dev/null 2>&1
/usr/bin/dbus-launch /usr/bin/python2.7 ~/.local/bin/gcalcli remind 15 "/usr/bin/notify-send -u normal -a calendar -t 0 %s"
# /usr/bin/python2.7 ~/.local/bin/gcalcli remind 10 "/usr/bin/notify-send -u normal -a calendar -t 0 %s"
