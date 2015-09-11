# -*- coding: utf8 -*-

from time import time

import re
import subprocess

"""
Module for displaying information about backlight.

Requires:
    - the 'xbacklight' command line

@author glaux1126
"""

CACHE_TIMEOUT = 2 # time to update light status


class Py3status:
	def __init__(self):
		self.text = ''

	def backlight_level(self, i3status_output_json, i3status_config):
		response = {'name': 'backlight-level'}

		light = subprocess.check_output(["xbacklight","-get"]).decode('utf-8')
		light = int(float(light))
		if light == 100:
			backlight = ''
		else:
			backlight = str(light) + "💡"
		
		if self.text != backlight:
			transformed = True
			self.text = backlight
		else:
			transformed = False

		response = {
			'cached_until': time() + CACHE_TIMEOUT,
			'full_text': self.text,
			'name': 'backlight',
			'transformed': transformed
		}

		return response
