#!/bin/bash

# monitor.sh - Monitors a web page for changes
# sends an email notification if the file change
# Copyright: http://bhfsteve.blogspot.de/2013/03/monitoring-web-page-for-changes-using.html

USERNAME="mail@me.com"
PASSWORD="appspecific"
URL_ARRAY=()

cd $HOME/.cache/

for index in ${!URL_ARRAY[*]}; do
    #echo $index"_new.html"
    mv $index"_new.html" $index"_old.html" 2> /dev/null
    #echo ${URL_ARRAY[$index]}
    #echo $index"_new.html"
    curl "${URL_ARRAY[$index]}" -L --compressed -s > $index"_new.html"
	DIFF_OUTPUT="$(diff $index"_new.html" $index"_old.html")"
	if [ "0" != "${#DIFF_OUTPUT}" ]; then
		sendEmail -f $USERNAME -s smtp.gmail.com:587 \
		-xu $USERNAME -xp $PASSWORD -t $USERNAME \
		-o tls=yes -u "[Cron] Web page changed" \
		-m "Visit it at ${URL_ARRAY[$index]}"
		sleep 10
	fi
done
