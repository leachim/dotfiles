#!/bin/sh
# shell script to prepend i3status output with some custom stuff
counter=0
i3status --config ~/.i3/i3status.conf | while :
do
		read line
		counter=$((counter + 1))
		LG=$(setxkbmap -print | grep xkb_symbols | awk -F"+" '{print $2}')
		id=$(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')
		name=$(xprop -id $id | awk '/_NET_WM_NAME/{$1=$2="";print}' | cut -d'"' -f2 | cut -c 1-80)
		if [ "$counter" -ge 1800 ];then
			myIP=$(curl -s http://checkip.dyndns.org/ | awk '/:/ {print $6}' | cut -d "<" -f1 )
			counter=0
		fi
        #pycom=$(/home/user/.i3/pys.py) # custom python script
        #todo=$(task ls | sed -n '4s/[[:blank:]]\+/ /pg' ) # todo task list
		#echo "$name | $myIP | $LG | $line" || exit 1
		echo "$line" || exit 1 
done

