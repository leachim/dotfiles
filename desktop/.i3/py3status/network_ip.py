# -*- coding: utf8 -*-

import httplib2
import re
from time import time

"""
Py3status plugin - shows current wan ip and wan country.

@author glaux1126
"""

CACHE_TIMEOUT = 420  # maximum time to update indicator

def get_wanip():
	""" return current wan ip """
	try:
		h = httplib2.Http('/home/michael/.cache')
		response, content = h.request("http://ifconfig.me/ip")
		ip = re.findall( r'[0-9]+(?:\.[0-9]+){3}', str(content) )[0]
		return ip
	except Exception:
		return ""


def get_wancountry():
	""" return current wan ip country"""
	try:
		h = httplib2.Http('/home/michael/.cache')
		response, content = h.request("http://ipinfo.io/country")
		country = re.findall( r'\b[A-Z]{2}\b', str(content) )[0]                                                 
		return country
	except Exception:
		return ""


class Py3status:
	def __init__(self):
		self.text = ''

	def network_ip(self, i3_status_output_json, i3status_config):
		ip_info = get_wancountry() + " " + get_wanip()
		
		if self.text != ip_info:
			transformed = True
			self.text = ip_info
		else:
			transformed = False

		response = {
			'cached_until': time() + CACHE_TIMEOUT,
			'full_text': self.text,
			'name': 'network_ip',
			'transformed': transformed
		}

		return response
		
