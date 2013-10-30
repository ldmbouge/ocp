#!/usr/bin/python

import subprocess
import os
import sys
import json
import intoDB

class Runner:
	def __init__(self,bin):
		self.home = os.environ['HOME']
		self.path = os.environ['BUILT_PRODUCTS_DIR']
		self.bin = bin
		self.pwd = os.getcwd()
		if os.path.exists('results.json'):
			self.all = open('results.json','r')
			self.ab  = json.loads(self.all.read())
			self.all.close()
		else:
			self.ab = {}
		print "CWD is:" + self.pwd
		os.chdir(self.path)
		os.environ['DYLD_FRAMEWORK_PATH'] = self.path

	def run(self,qp,np,par,heur):
		full = './' + self.bin;
		key = '{0} -q{1} -n{2} -p{3} -h{4}'.format(self.bin,qp,np,par,heur)
		print 'Running in {5} [{0} -q{1} -n{2} -p{3} -h{4}]'.format(full,qp,np,par,heur,os.getcwd())
		h = subprocess.Popen((full,'-q{0}'.format(qp),'-n{0}'.format(np),'-p{0}'.format(par),'-h{0}'.format(heur)),
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
	('TestAssignment',0,0,0,0),
	('testLPConcretization',0,0,0,0),
	('queensMIP',8,0,0,0)
]
#	('queensMIP',8,0,0,0),
	  
cmd = "cd Clo;/usr/bin/xcodebuild -workspace ObjecticeCP.xcworkspace -scheme allProgs -showBuildSettings|grep '^ *BUILT_PRODUCTS_DIR ='|head -1"

task = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
result = task.stdout.read()
assert task.wait() == 0
(key,value) = result.split('=')
value = value.lstrip().rstrip()

print "VALUE IS:" + value

os.environ['BUILT_PRODUCTS_DIR'] = value
for (b,qa,na,par,heur) in ab:
 	p = Runner(b)
 	p.run(qa,na,par,heur)

collector = intoDB.Collect()
collector.loadINDB()
collector.makeMarkdown(1,True)

covdir=value
cmd = "/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier -message \"Coverage Report Ready\"  -execute 'open -a Safari summary.html' "
os.system(cmd)
