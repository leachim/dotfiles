#!/bin/sh

# this script allows to toggle the keyboard between english and german

setxkbmap -layout 'us,de'
setxkbmap -option 'grp:alt_shift_toggle us,de'
exit 0
