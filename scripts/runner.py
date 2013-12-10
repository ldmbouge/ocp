#!/usr/bin/python
# Filename intoDB.py

import subprocess
import os
import sys
import json
import calendar
import time
import datetime
import platform, re
import sqlite3

version = '0.1'

class Environment:
	def __init__(self):
		cmd = "cd Clo;/usr/bin/xcodebuild -workspace ObjecticeCP.xcworkspace -scheme allProgs -showBuildSettings|grep '^ *BUILT_PRODUCTS_DIR ='|head -1"
		task = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
		result = task.stdout.read()
		assert task.wait() == 0
		(key,value) = result.split('=')
		value = value.lstrip().rstrip()
		os.environ['BUILT_PRODUCTS_DIR'] = value
	def notify(self,msg,execmd):
		notPath = "/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier"
		cmd = notifierPath + " -message \"" + msg + "\"  -execute '" + execmd + "'"
		os.system(cmd)

class Runner:
	def __init__(self,bin,randomized):
		self.home = os.environ['HOME']
		self.path = os.environ['BUILT_PRODUCTS_DIR']
		#print "BUILT_PRODUCT_DIR IS " + self.path
		self.bin = bin
		self.pwd = os.getcwd()
		if os.path.exists('results.json'):
			self.all = open('results.json','r')
			self.ab  = json.loads(self.all.read())
			self.all.close()
		else:
			self.ab = {}
		print "CWD is:" + self.pwd
		os.environ['DYLD_FRAMEWORK_PATH'] = self.path
		self.rand = randomized

	def run(self,qp,np,par,heur):
		os.chdir(self.path)
		full = './' + self.bin;
		key = '{0} -q{1} -n{2} -p{3} -h{4}'.format(self.bin,qp,np,par,heur)
		print 'Running in {6} [{0} -q{1} -n{2} -p{3} -h{4} -r{5}]'.format(full,qp,np,par,heur,self.rand,os.getcwd())
		h = subprocess.Popen((full,'-q{0}'.format(qp),'-n{0}'.format(np),'-p{0}'.format(par),'-h{0}'.format(heur),'-r{0}'.format(self.rand)),
			stdout=subprocess.PIPE,stderr=subprocess.PIPE)
		rc = h.wait()
		print 'Return code {0}'.format(rc)
		err = h.stderr.read()
		out = ''
		res = {'cpu' : 0, 'found' : 0, 'rc' : rc}
		if rc == 0:
			for line in h.stdout:
				if line[:4] == 'OUT:':
					parts = line[4:].rstrip().split(',')
					res = {'method' : parts[0],
					'randomized' : int(parts[1]),
					'threads' : int(parts[2]),
					'size' : parts[3],
					'found' : parts[4],
					'rrate' : parts[5],
					'nfail' : int(parts[6]),
					'nchoice' : int(parts[7]),
					'nprop' : int(parts[8]),
					'cpu' : float(parts[9]) / 1000.0,
					'wc'  : float(parts[10]) / 1000.0,
					'mused' : float(parts[11]) / 1024,
					'mpeak' : float(parts[12]) / 1024,
					'rc'    : rc}
					out = out + line
		else:
			out = h.stdout.read()
			res = {'cpu' : 0, 'found' : 0, 'rc' : rc}
		self.ab[key] = res
		if res['found'] == 0:
			error = 1
		else:
			error = 0
		os.chdir(self.pwd)
		self.all = open('results.json','w')
		self.all.write(json.dumps(self.ab,indent=4))
		self.all.close()
		return res

