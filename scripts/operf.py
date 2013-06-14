#!/usr/bin/python

import subprocess
import os
import sys
import json
import calendar
import time
import datetime
import platform, re

def get_processor_name():
	p = sys.platform
	if p == 'win32':
		return platform.processor()
	elif p == 'darwin':
		command ="/usr/sbin/sysctl -n machdep.cpu.brand_string"
		print command
		cc =  subprocess.Popen(('/usr/sbin/sysctl','-n','machdep.cpu.brand_string'),stdout=subprocess.PIPE)
		cc.wait()
		return cc.stdout.read().strip()
	elif p == 'linux':
		command = "cat /proc/cpuinfo"
		all_info = subprocess.check_output(command, shell=True).strip()
		for line in allInfo.split("\n"):
			if "model name" in line:
				return re.sub( ".*model name.*:", "", line,1)
	return ""

class Collect:
	def __init__(self):
		self.home = os.environ['HOME']
		self.pwd = os.getcwd()
		if os.path.exists('results.json'):
			self.all = open('results.json','r')
			self.ab  = json.loads(self.all.read())
			self.all.close()
		else:
			self.ab = {}

	def generate(self):
		of = open('result-perf.xml','w')
		of.write('<?xml version="1.0" encoding="UTF-8" ?>\n')
		of.write('<report name="Performance"  categ="OCP">\n')
		nv = datetime.datetime.today()
		sDate = nv.strftime('%Y%m%d')
		sTime = nv.strftime('%H%M%S')
		of.write('<start><date format="YYYYMMDD" val="{0}"/><time  format="HHMMSS" val="{1}"/></start>\n'.format(sDate,sTime))
		self.dumpTests(of)
		of.write('</report>\n')
		of.close()		
		print self.ab

	def platform(self,of):
		of.write('<platform name="{0}" remote="Unknown" capspool="Unknown">\n'.format(platform.node()))
		of.write('\t<os>\n')
		osd = os.uname()
		pn = get_processor_name()
		parts = pn.split('@')
		of.write('\t\t<type><![CDATA[{0}]]></type>\n'.format(osd[0]))
		of.write('\t\t<name><![CDATA[{0}]]</name>\n'.format(os.name))
		of.write('\t\t<version>![CDATA[{0}]]</version>\n'.format(osd[2]))
		of.write('\t\t<distribution>![CDATA[{0}]]</distribution>\n'.format(osd[3]))
		of.write('\t</os>\n')
		of.write('\t<processor arch="{0}">\n'.format(pn))
		of.write('\t\t<frequency unit="Mhz" cpufreq="{0}"/>\n'.format(float(parts[1][:-3])*1000.0))
		of.write('\t</processor>\n')
		of.write('</platform>\n')

	def dumpTests(self,of):
		for key in self.ab:
			self.dumpTest(of,key)

	def dumpTest(self,of,key):
		bench = self.ab[key]
		of.write('<test name="{0}" executed="yes">\n'.format(key))
		self.platform(of)
		of.write('<commandline rank="0" time="" duration="{0}">{1}</commandline>\n'.format(bench['wc'],key))
		of.write('\t<result>\n')
		if int(bench['found']) > 0:
			p = 'yes'
		else:
			p = 'no'
		s = bench['rc']
		cpu = bench['cpu']
		mem = bench['mused']
		of.write('\t\t<success passed="{0}" state="{1}" hasTimedOut="false"/>\n'.format(p,s))
		of.write('\t\t<executiontime unit="s" mesure="{0}" isRelevant="true"/>\n'.format(cpu))
		of.write('\t\t<performance unit="KB" mesure="{0}" isRelevant="true"/>\n'.format(mem))
		of.write('\t</result>\n')
		of.write('</test>\n')

c = Collect()
c.generate()

