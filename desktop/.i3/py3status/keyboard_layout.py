# -*- coding: utf8 -*-

import os
import re
import subprocess
from time import time

"""
Py3status plugin - shows current keyboard layout

Requires:

@author glaux1126
"""

CACHE_TIMEOUT = 1  # maximum time to update indicator


def get_keylayout():
	""" return current keyboard layout """
	bashCommand = 'case "$(xset -q | grep LED| awk \'{ print $10 }\')" in "00000000") echo "US" ;;"00001000") echo "DE" ;;*) echo "unknown" ;;esac'
	language = subprocess.Popen(bashCommand, shell=True, stdout=subprocess.PIPE).communicate()[0]
	language = re.findall( r'\b[A-Z]{2}\b', str(language) )[0]                                                 
	if isinstance(language, str):
		return language.strip()
	else:
		return ""
	

class Py3status:
	def __init__(self):
		initKeyboardLayoutCommand = '/usr/bin/setxkbmap -layout us,de ;/usr/bin/setxkbmap -option grp:alt_shift_toggle;'
		subprocess.Popen(initKeyboardLayoutCommand, shell=True, stdout=subprocess.PIPE)
		self.text = ''

	def keyboard_layout(self, i3_status_output_json, i3status_config):
		layout = get_keylayout()

		if self.text != layout:
			transformed = True
			self.text = layout
		else:
			transformed = False

		response = {
			'cached_until': time() + CACHE_TIMEOUT,
			'full_text': self.text,
			'name': 'keyboard-layout',
			'transformed': transformed
		}

		return response
		
