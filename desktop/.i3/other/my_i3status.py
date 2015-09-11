#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# This script is a simple wrapper which prefixes each i3status line with custom
# information. It is a python reimplementation of:
# http://code.stapelberg.de/git/i3status/tree/contrib/wrapper.pl
#
# To use it, ensure your ~/.i3status.conf contains this line:
#     output_format = "i3bar"
# in the 'general' section.
# Then, in your ~/.i3/config, use:
#     status_command i3status | ~/i3status/contrib/wrapper.py
# In the 'bar' section.
#
# In its current version it will display the cpu frequency governor, but you
# are free to change it to display whatever you like, see the comment in the
# source code below.
#
# © 2012 Valentin Haenel <valentin.haenel@gmx.de>
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License (WTFPL), Version
# 2, as published by Sam Hocevar. See http://sam.zoy.org/wtfpl/COPYING for more
# details.

import sys
import json
import os
import re
import subprocess
import httplib2

def get_governor():
	""" Get the current governor for cpu0, assuming all CPUs use the same, if too high """
	with open('/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor') as fp:
		return fp.readlines()[0].strip()
		
def get_temperature():
	""" Get the current cpu temperature, if too high. """
	with open('/sys/class/thermal/thermal_zone0/temp') as fp:
		return fp.readlines()[0].strip()
		
def get_keylayout():
	""" return current keyboard layout """
	bashCommand = 'case "$(xset -q | grep LED| awk \'{ print $10 }\')" in "00000000") echo "US" ;;"00001000") echo "DE" ;;*) echo "unknown" ;;esac'
	language = subprocess.Popen(bashCommand, shell=True, stdout=subprocess.PIPE).communicate()[0]
	language = re.findall( r'\b[A-Z]{2}\b', str(language) )[0]                                                 
	if isinstance(language, str):
		return language.strip()
	else:
		return ""
	

def get_wanip():
	""" return current wan ip """
	try:
		h = httplib2.Http('.cache')                                                    
		response, content = h.request("http://ifconfig.me/ip")  
		ip = re.findall( r'[0-9]+(?:\.[0-9]+){3}', str(content) )[0]                                                 
		return ip
	except Exception:
		return ""

def get_wancountry():
	""" return current wan ip country"""
	try:
		h = httplib2.Http('.cache')
		response, content = h.request("http://ipinfo.io/country")
		country = re.findall( r'\b[A-Z]{2}\b', str(content) )[0]                                                 
		return country
	except Exception:
		return ""
	
def print_line(message):
    """ Non-buffered printing to stdout. """
    sys.stdout.write(message + '\n')
    sys.stdout.flush()

def read_line():
    """ Interrupted respecting reader for stdin. """
    # try reading a line, removing any extra whitespace
    try:
        line = sys.stdin.readline().strip()
        # i3status sends EOF, or an empty line
        if not line:
            sys.exit(3)
        return line
    # exit on ctrl-c
    except KeyboardInterrupt:
        sys.exit()

if __name__ == '__main__':
    # Skip the first line which contains the version header.
	print_line(read_line())

    # The second line contains the start of the infinite array.
	print_line(read_line())
	
	counter = 0
	wanip = ""
	wancountry = ""
	ip_info = ""
	
	while True:
		line, prefix = read_line(), ''
		# ignore comma at start of lines
		if line.startswith(','):
			line, prefix = line[1:], ','

		j = json.loads(line)
				
		if counter >= 180:
				wanip = get_wanip()
				wancountry = get_wancountry()
				ip_info = wancountry + " " + wanip
				j.insert(0, {'full_text' : '%s' % ip_info, 'name' : 'ip_info'})
				#j.insert(0, {'full_text' : '%s' % wanip, 'name' : 'wan_ip'})
				#j.insert(0, {'full_text' : '%s' % wancountry, 'name' : 'wan_country'})
				counter = 0
			
		j.insert(0, {'full_text' : '%s' % ip_info, 'name' : 'ip_info'})
		#j.insert(0, {'full_text' : '%s' % wanip, 'name' : 'wan_ip'})
		#j.insert(0, {'full_text' : '%s' % wancountry, 'name' : 'wan_country'})
		#j.insert(0, {'full_text' : '%s' % counter, 'name' : 'debugger'})
		#j.insert(0, {'full_text' : '%s' % get_keylayout(), 'name' : 'language'})
		counter = counter + 1
		
		if int(get_temperature()) > 55000:
			temperature = str(get_temperature()[:2]) + "℃"
			j.insert(0, {'full_text' : '%s' % temperature, 'name' : 'cpu_temp'})

		language = get_keylayout()
		j.insert(len(j) - 1, {'full_text' : '%s' % language, 'name' : 'cpu_temp'})
			
        # insert information into the start of the json, but could be anywhere
        # CHANGE THIS LINE TO INSERT SOMETHING ELSE
        #j.insert(0, {'full_text' : '%s' % get_governor(), 'name' : 'gov'})
        
        # and echo back new encoded json
		print_line(prefix+json.dumps(j))
