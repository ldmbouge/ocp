#!/usr/bin/python

import subprocess
import os
import sys

class Runner:
	def __init__(self,bin,fname):
		home = os.environ['HOME']
		self.path = self.findFolder('ObjecticeCP')
		self.bin = bin
		self.fName = fname
		os.chdir(self.path)
		self.of = open('{0}/Desktop/{1}'.format(home,fname),'w')
		self.of.write('heur,method,rand,threads,size,found,restartRate,#f,#c,#p,cpu,wc,mUsed,mPeak\n')
		os.environ['DYLD_FRAMEWORK_PATH'] = self.path

	def findFolder(self,name):
		home = os.environ['HOME']
		rootdir = home + '/Library/Developer/Xcode/DerivedData'
		for root, subFolders, files in os.walk(rootdir):
			for folder in subFolders:
				if folder[:11] == name:
					endPath = folder + '/Build/Products/Release'
					print 'Full path is [' , rootdir + '/' + endPath , ']'					
					return rootdir + '/' + endPath
		return '/tmp'


	def run(self,runs,depth,size,bench):
		for i in range(1,runs+1):
			full = self.path + '/' + self.bin;
			#print 'ENV' , os.environ['DYLD_FRAMEWORK_PATH']
			#print 'Running' , full
			#print (full,'-n{0}'.format(depth),'-q{0}'.format(size),'-b{0}'.format(bench))
			h = subprocess.Popen((full,'-b{0}'.format(bench),'-q{0}'.format(size),'-n{0}'.format(depth)),
				stdout=subprocess.PIPE,stderr=subprocess.PIPE)
			h.wait()
			err = h.stderr.read()
			for line in h.stdout:
				if line[:4] == 'OUT:':
					parts = line[4:].rstrip().split(',')
					self.of.write(str(i) + ',' + parts[0] + ',' + parts[1] + ',' + parts[2] + ',' + parts[3] + 
						',' + parts[4] +  ',' + parts[5]   + ',' + parts[6] + ',' + parts[7] + ',' +  parts[8] + 
						',' + parts[9] + ',' + parts[10]  + ',' + parts[11] + ',' + parts[12] + '\n')
			print 'Iteration ' , i , ' on depth ' , depth


#bench=0
#p = Runner('stressLimit','stress-b{0}.csv'.format(bench))
#for depth in range(0,21):
#	p.run(50,depth,16,bench)

bench=3
p1 = Runner('stressLimit','stress-b{0}.csv'.format(bench))
for depth in range(0,21):
	p1.run(50,depth,12,bench)
