#!/bin/bash

while true; 
do 
  nc -l -p 58439 | while read OUTPUT; do notify-send "$(echo ${OUTPUT} | cut -f1 -d ";")" "\n$(echo ${OUTPUT} | cut -f2 -d ";")" -u low ; done; sleep 1; 
done

