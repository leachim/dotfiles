# -*- coding: utf8 -*-

#import os
#import sys
import re
import subprocess
from time import time

"""
Py3status plugin - shows cpu freq and temperature if temperature above threshold:

@author glaux1126
"""

CACHE_TIMEOUT = 360 # maximum time to update indicator

THRESHOLD = 54
# in degree celsius

def get_governor():
	""" Get the current governor for cpu0, assuming all CPUs use the same, if too high """
	cpuinfo = subprocess.check_output(["cat","/proc/cpuinfo"]).decode('utf-8')
	freq = [float(x.split(": ")[1]) / 1000 for x in cpuinfo.split('\n') if x.startswith("cpu MHz")]
	return '-'.join('%5.2fGHz' % v for v in freq)
		
def get_temperature():
	""" Get the current cpu temperature, if too high. """
	with open('/sys/class/thermal/thermal_zone0/temp') as fp:
		return fp.readlines()[0].strip()
		

class Py3status:
	def __init__(self):
		self.text = ''

	def cpu_freq(self, i3_status_output_json, i3status_config):
		temperature = get_temperature()
		
		if int(temperature) > (THRESHOLD * 1000):
			if self.text != str(temperature[:2]) + "℃" + " - " + get_governor():
				transformed = True
				self.text = str(get_temperature()[:2]) + "℃" + " - " + get_governor()
			else:
				transformed = False
		else:
			if self.text != '':
				transformed = True
				self.text = ''
			else:
				transformed = False
				
		response = {
			'cached_until': time() + CACHE_TIMEOUT,
			'full_text': self.text,
			'name': 'cpu_freq',
			'transformed': transformed
		}

		return response
		

