#!/usr/bin/python

import subprocess
import os

class Runner:
	def __init__(self,bin,fname):
		home = os.environ['HOME']
		self.path = home + '/Library/Developer/Xcode/DerivedData/ObjecticeCP-azsdoocmmwfkhhdmoovkwzwhlkja/Build/Products/Release'
		self.bin = bin
		self.fName = fname
		os.chdir(self.path)
		self.of = open('{0}/Desktop/{1}'.format(home,fname),'w')
		self.of.write('heur,rand,threads,size,found,restartRate,#f,#c,#p,cpu,wc,mUsed,mPeak\n')
		os.environ['DYLD_FRAMEWORK_PATH'] = self.path

	def run(self,runs,heuristic,timeOut):
		for i in range(1,runs+1):
			full = self.path + '/' + self.bin;
			h = subprocess.Popen((full,'-h{0}'.format(heuristic),'-q2','-p1','-r1','-t{0}'.format(timeOut)),
				stdout=subprocess.PIPE,stderr=subprocess.PIPE)
			h.wait()
			err = h.stderr.read()
			for line in h.stdout:
				if line[:4] == 'OUT:':
					parts = line[4:].rstrip().split(',')
					self.of.write(str(i) + ',' + parts[0] + ',' + parts[1] + ',' + parts[2] + ',' + parts[3] + 
						',' + parts[4] +  ',' + parts[5]   + ',' + parts[6] + ',' + parts[7] + ',' +  parts[8] + 
						',' + parts[9] + ',' + parts[10]  + ',' + parts[11] + ',' + parts[12] + '\n')
			print 'Iteration ' , i , ' on heuristic ' , heuristic

timeOut = 300
p = Runner('knapsackOpt','ksOpt.csv')
for h in [0,1,2,3]:
	p.run(50,h,timeOut)