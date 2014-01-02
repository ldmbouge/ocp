#!/usr/bin/python
import subprocess
import os
import sys
import json
import intoDB
import runner
import csv

#  bench qArgument	nArgument	parallel (0/1)	heuristic [0|1|2|3|4]
# ab = [('sport',0,0,0,0),
# 	  ('progressive',1,9,0,0),
# 	  ('slab',0,0,0,0),
# 	  ('slabLNSModel',0,0,0,0),
# 	  ('perfect',0,0,0,0),
# 	  ('knapsackOpt',3,0,0,0),
# 	  ('latinSquare',8,0,0,0),
# 	  ('golomb',13,0,0,0)
# 	  ]

# ab = [('magicserie',8,0,0,0,2048),
#       ('magicseriesModel',8,0,0,0,256)]

#ab = [('slow_convergence',8,0,0,0,2048)]

ab = [('order',8,0,0,0,8192)]

e = runner.Environment()
nbRun = 10

for (b,qa,na,par,heur,ub) in ab:
 	p = runner.Runner(b,1)
 	ar = []
        sz = qa
        while sz <= ub:                
                for run in range(nbRun):
                        res = p.run(sz,na,par,heur)
                        ar.append(res)
                sz *= 2
	#print ar
	f = open(b + '.csv','w')
	k = ar[0].keys()
	writer = csv.DictWriter(f,k)
	writer.writer.writerow(k)
	writer.writerows(ar)
	f.close()
