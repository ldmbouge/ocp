#!/usr/bin/python

import subprocess
import os

class Runner:
	def __init__(self,fname):
		self.path = '/Users/ldm/Library/Developer/Xcode/DerivedData/ObjecticeCP-azsdoocmmwfkhhdmoovkwzwhlkja/Build/Products/Release'
		self.bin = 'knapsack'
		self.fName = fname
		os.chdir(self.path)
		home = os.environ['HOME']
		self.of = open('{0}/Desktop/{1}'.format(home,fname),'w')
		self.of.write('run,choice,fail,time\n')
		os.environ['DYLD_FRAMEWORK_PATH'] = self.path

	def run(self,runs,heuristic):
		for i in range(1,runs):
			full = self.path + '/' + self.bin;
			h = subprocess.Popen((full,str(heuristic)),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
			h.wait()
			err = h.stderr.read()
			for line in h.stdout:
				pfx = line[:4]
				if pfx == 'OUT:':
					parts = line.rstrip().split(':')
					self.of.write(str(i) + ',' + parts[1] + ',' + parts[2] + ',' + parts[3] + ',' + parts[4] + '\n')
			print 'Iteration ' , i , ' on heuristic ' , heuristic

p = Runner('nobacktofail.csv')
p.run(50,0)
p.run(50,1)
p.run(50,2)
p.run(50,3)

	