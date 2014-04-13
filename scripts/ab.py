#!/usr/bin/python
import subprocess
import os
import sys
import json
import intoDB
import runner

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
	  
e = runner.Environment()

e.buildRelease()

for (b,qa,na,par,heur) in ab:
 	p = runner.Runner(b,0)
 	p.run(qa,na,par,heur)

collector = intoDB.Collect()
collector.loadINDB()
collector.latestMarkDown(True)
os.system("/usr/local/bin/mmd summary.md")
out = open('fragment.html','w')
collector.makeHTMLPage(out,600,200)

execmd = 'open ' + os.getcwd() + '/summary.html'
e.notify('Test Report Ready',execmd)
