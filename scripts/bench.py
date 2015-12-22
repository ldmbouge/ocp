#!/usr/bin/python
import subprocess
import os
import sys
import json
import intoDB
import runner
import csv

#  bench qArgument	nArgument	parallel (0/1)	heuristic [0|1|2|3|4]

ab = [
#      ('sport',0,0,0,0,0,lambda x : x + 1),
       ('progressive',7,6,0,0,7,lambda x : x + 1),
#      ('slab',0,0,0,0,0,lambda x : x + 1),
#      ('slabLNSModel',0,0,0,0,0,lambda x : x + 1),
#      ('perfect',0,0,0,0,0,lambda x : x + 1),
#      ('knapsackOpt',1,0,0,0,4,lambda x : x + 1),
#      ('golomb',8,0,0,0,13,lambda x : x + 1),
#	('order2',8,0,0,0,4096,lambda x : x * 2),
#	('order',8,0,0,0,8192,lambda x : x * 2)
  ]

#      ('latinSquare',8,0,0,0,8,lambda x : x + 1),

# ab = [('magicserie',8,0,0,0,2048,lambda x : x * 2),
#       ('magicseriesModel',8,0,0,0,256,lambda x : x * 2)]
#ab = [('slow_convergence',8,0,0,0,2048,lambda x : x * 2)]
#ab = [('order',8,0,0,0,32,lambda x : x * 2)]

e = runner.Environment()
nbRun = 50

for (b,qa,na,par,heur,ub,step) in ab:
 	p = runner.Runner(b,1)
 	ar = []
        sz = qa
        print sz, " ", ub
	while sz <= ub:                
                for run in range(nbRun):
                        res = p.run(sz,na,par,heur)
                        ar.append(res)
                sz = step(sz)
	print ar
	f = open(b + '.csv','w')
	k = ar[0].keys()
	writer = csv.DictWriter(f,k)
	writer.writer.writerow(k)
	writer.writerows(ar)
	f.close()
