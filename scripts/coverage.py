#!/usr/bin/python

import subprocess
import os
import sys
import json

class Runner:
	def __init__(self,bin):
		self.home = os.environ['HOME']
		self.path = os.environ['BUILT_PRODUCTS_DIR']
		self.bin = bin
		self.pwd = os.getcwd()
		self.of = open('bench-{0}.xml'.format(bin),'w')
		os.chdir(self.path)
		os.environ['DYLD_FRAMEWORK_PATH'] = self.path
		self.ab = {}

	def findFolder(self,name):
		home = os.environ['HOME']
		return 'build'

	def run(self,qp,np,par,heur):
		full = './' + self.bin;
		print 'Running in {5} [{0} -q{1} -n{2} -p{3} -h{4}]'.format(full,qp,np,par,heur,os.getcwd())
		h = subprocess.Popen((full,'-q{0}'.format(qp),'-n{0}'.format(np),'-p{0}'.format(par),'-h{0}'.format(heur)),
			stdout=subprocess.PIPE,stderr=subprocess.PIPE)
		rc = h.wait()
		print 'Return code {0}'.format(rc)
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


ab = [('queensAC',12,0,0,0),
	('queensACSem',12,0,0,0),
	('queensACSem',12,0,1,0),
	('queensACSem',12,0,2,0),
	('ais',10,0,0,0),
	('fdmul',0,0,0,0),
	('costas',6,0,0,0),
	('golomb',8,0,0,0),
	('bibd',8,0,0,0),
	('coloringModel',0,0,0,0),
	('debruijn',8,2,0,0),
	('eq20',0,0,0,0),
	('knapsack',4,0,0,0),
	('knapsack',4,0,0,1),
	('knapsack',4,0,0,2),
	('knapsack',3,0,0,3),
	('knapsack',3,0,0,4),
	('knapsackOpt',3,0,0,0),
	('langford',8,2,0,0),
	('latinSquare',7,0,0,0),
	('magicserie',500,0,0,0),
	('magicsquareModel',9,0,0,0),
	('perfect',0,0,0,0),
	('sport',0,0,0,0),
	('slab',0,0,0,0),
	('slabModel',0,0,0,0),
	('paq',6,0,0,0),
	('qg7',9,0,0,0),
	('warehouse',0,0,0,0),
	('fwarehouse',0,0,0,0),
	('bacp',0,0,0,0),
	('nonogram',0,0,0,0),
	('minesweeper',0,0,0,0),
	('circle',0,0,0,0),
	('grocery',0,0,0,0),
	('marriage',0,0,0,0),
	('nfraction',0,0,0,0),
	('slow_convergence',100,0,0,0),
	('market2s',0,0,0,0),
	('partition',20,0,0,0),
	('order',1000,0,0,0),
	('wka',0,0,0,0),
	('queensMIP',8,0,0,0),
	('testAssignment',0,0,0,0),
	('testLPConcretization',0,0,0,0)]
	  
for (b,qa,na,par,heur) in ab:
	p = Runner(b)
	p.run(qa,na,par,heur)

covdir=os.environ['CONFIGURATION_TEMP_DIR'];
os.chdir(covdir)

