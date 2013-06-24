#!/usr/bin/python

import subprocess
import os
import sys
import json

class Runner:
	def __init__(self,bin):
		self.home = os.environ['HOME']
		self.path = self.findFolder('ObjecticeCP')
		self.bin = bin
		self.pwd = os.getcwd()
		self.of = open('bench-{0}.xml'.format(bin),'w')
		if os.path.exists('results.json'):
			self.all = open('results.json','r')
			self.ab  = json.loads(self.all.read())
			self.all.close()
		else:
			self.ab = {}
		os.chdir(self.path)
		os.environ['DYLD_FRAMEWORK_PATH'] = '.'

	def findFolder(self,name):
		home = os.environ['HOME']
		return 'build'
		# rootdir = self.home + '/Library/Developer/Xcode/DerivedData'
		# for root, subFolders, files in os.walk(rootdir):
		# 	for folder in subFolders:
		# 		if folder[:11] == name:
		# 			endPath = folder + '/Build/Products/Release'
		# 			print 'Full path is [' , rootdir + '/' + endPath , ']'					
		# 			return rootdir + '/' + endPath
		# return '/tmp'

	def run(self,qp,np):
		full = './' + self.bin;
		print 'Running in {3} [{0} -q{1} -n{2}]\n'.format(full,qp,np,os.getcwd())
		h = subprocess.Popen((full,'-q{0}'.format(qp),'-n{0}'.format(np)),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
		rc = h.wait()
		print 'Return code {0}\n'.format(rc)
		err = h.stderr.read()
		out = ''
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
		self.ab[self.bin] = res

		if res['found'] == 0:
			error = 1
		else:
			error = 0
		self.of.write('<?xml version="1.0" ?>\n')
		self.of.write('<testsuite errors="{0}" failures="{1}" name="OCP" tests="1">\n'.format(error,rc))
		self.of.write('<testcase name="{0}" classname="{0}" time="{1}">\n'.format(self.bin,res['cpu']))
		self.of.write('\t<system-out><![CDATA[\n')
		self.of.write(out)
		self.of.write('\t]]></system-out>\n')		
		self.of.write('\t<system-err><![CDATA[\n')
		self.of.write(err)
		self.of.write('\t]]></system-err>\n')
		self.of.write('</testcase>\n')
		self.of.write('</testsuite>\n')
		os.chdir(self.pwd)
		self.all = open('results.json','w')
		self.all.write(json.dumps(self.ab,indent=4))
		self.all.close()


ab = [('queensAC',12,0),('ais',20,0),('fdmul',0,0),('costas',6,0),('golomb',8,0),
	  ('bibd',8,0),('coloringModel',0,0),('debruijn',8,2),('eq20',0,0),('knapsack',4,0),
	  ('knapsackOpt',3,0),('langford',8,2),('latinSquare',7,0),('magicserie',500,0),
	  ('magicsquareModel',9,0),('perfect',0,0),('sport',0,0),('slab',0,0)]
for (b,qa,na) in ab:
	p = Runner(b)
	p.run(qa,na)
