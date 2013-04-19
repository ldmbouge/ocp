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


	def run(self,runs,arg1,arg2,heur):
		for i in range(1,runs+1):
			full = self.path + '/' + self.bin;
			#print 'ENV' , os.environ['DYLD_FRAMEWORK_PATH']
			#print 'Running' , full
			#print (full,'-q{0}'.format(arg2),'-n{0}'.format(arg1))
			h = subprocess.Popen((full,'-q{0}'.format(arg1),'-n{0}'.format(arg2),heur),
				stdout=subprocess.PIPE,stderr=subprocess.PIPE)
			h.wait()
			err = h.stderr.read()
			for line in h.stdout:
				if line[:4] == 'OUT:':
					parts = line[4:].rstrip().split(',')
					self.of.write(str(i) + ',' + parts[0] + ',' + parts[1] + ',' + parts[2] + ',' + parts[3] + 
						',' + parts[4] +  ',' + parts[5]   + ',' + parts[6] + ',' + parts[7] + ',' +  parts[8] + 
						',' + parts[9] + ',' + parts[10]  + ',' + parts[11] + ',' + parts[12] + '\n')
			print 'Iteration ' , i , ' on  ' + self.bin + '(' + str(arg1) + ',' + str(arg2) +  ')'


#bench=0
#p = Runner('stressLimit','stress-b{0}.csv'.format(bench))
#for depth in range(0,21):
#	p.run(50,depth,16,bench)

ac3 = [('bibd',6,0,''),('queensAC',12,0,''),('knapsack',4,0,''),
       ('eq20',0,0,''),('partition',20,0,''),('perfect',0,0,'')]
ac5 = [('latinSquare',7,0),('fdmul',0,0),('ais',30,0),('sport',0,0),
       ('langford',3,9)]
wl  = [('debruijn',0,0),('slab',0,0),('magicserie',300,0)]
nbr = 50
for i,b in enumerate(ac3):
	print "Bench" , i , b[0] , b[1] , b[2] , b[3]
	p = Runner(b[0],b[0] + "-VARVIEW.csv")
	p.run(nbr,b[1],b[2],b[3])

for i,b in enumerate(ac5):
	print "Bench" , i , b[0] , b[1] , b[2]
	p = Runner(b[0],b[0] + "-VARVIEW.csv")
	p.run(nbr,b[1],b[2],'')

for i,b in enumerate(wl):
	print "Bench" , i , b[0] , b[1] , b[2]
	p = Runner(b[0],b[0] + "-VARVIEW.csv")
	p.run(nbr,b[1],b[2],'')
