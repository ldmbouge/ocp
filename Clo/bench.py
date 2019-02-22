#!/usr/bin/python
import subprocess
import os
import sys
import json


# ab = ['ais',
# 'bacp',
# 'bibd',
# 'circle',
# 'costas',
# 'costas2',
# 'debruijn',
# 'eq20',
# 'Euler',
# 'smory',
# 'fdmul',
# 'fdmul2',
# 'fwarehouse',
# 'golomb',
# 'grocery',
# 'knapsack',
# 'knapsackOpt',
# 'langford',
# 'latinSquare',
# 'magicserie',
# 'magicseriesModel',
# 'magicsquareModel',
# 'market2s',
# 'marriage',
# 'minesweeper',
# 'nfraction',
# 'nonogram',
# 'order',
# 'paq',
# 'partition',
# 'perfect',
# 'progressive',
# 'qg7',
# 'queens2',
# 'queensAC',
# 'queensACSem',
# 'queensMIP',
# 'queensModel',
# 'queensNaive',
# 'regular',
# 'slab',
# 'slabLNSModel',
# 'slabModel',
# 'slow_convergence',
# 'sport',
# 'sportModel',
# 'stressLimit',
# 'Sudoku',
# 'TestAssignment',
# 'testLPConcretization',
# 'testPacking',
# 'warehouse',
#       'wka',
#       'coloringModel',
#       'jobshop',
#       'JobShopBenchmarks',
#       'UTC',
#       'FanghuiTest'
# ]

ab = ['kepler0',
'kepler1',
'kepler2',
'optimized_heron156',
'add_01_1_1',
'add_01_1_2',
'add_01_1_3', 
'add_01_1_4',
'add_01_10_1',
'add_01_10_2',
'add_01_10_3', 
'add_01_10_4', 
'add_01_100_1', 
'add_01_100_2', 
'add_01_100_3',
'add_01_100_4',
'add_01_1000_1', 
'add_01_1000_2', 
'add_01_1000_3', 
'add_01_1000_4', 
'sine_1_false-unreach-call',
'sine_2_false-unreach-call',
'sine_3_false-unreach-call', 
'sine_4_true-unreach-call',
'sine_5_true-unreach-call',
'sine_6_true-unreach-call', 
'sine_7_true-unreach-call',
'sine_8_true-unreach-call',
'PID_diff_opt',
'PID_diff_opt_5',
'PID_diff_opt_6',
'PID_diff_opt_7',
'PID_diff_opt_8',
'PID_diff_opt_9',
'PID_diff_opt_10',
'PID_diff_opt_5_0',
'PID_diff_opt_6_0_SAT',
'PID_diff_opt_7_SAT',
'PID_diff_opt_8_0_SAT',
'PID_diff_opt_9_0_SAT',
'PID_diff_opt_10_0_SAT',
'square_1_false-unreach-call',
'square_2_false-unreach-call',
'square_3_false-unreach-call',
'square_4_true-unreach-call', 
'square_5_true-unreach-call',
'square_6_true-unreach-call',
'square_7_true-unreach-call', 
'square_8_true-unreach-call',
'newton_1_1_true-unreach-call',
'newton_1_2_true-unreach-call', 
'newton_1_3_true-unreach-call',
'newton_1_4_false-unreach-call',
'newton_1_5_false-unreach-call', 
'newton_1_6_false-unreach-call',
'newton_1_7_false-unreach-call',
'newton_1_8_false-unreach-call',
'newton_2_1_true-unreach-call',
'newton_2_2_true-unreach-call',
'newton_2_3_true-unreach-call',
'newton_2_4_true-unreach-call',
'newton_2_5_true-unreach-call',
'newton_2_6_false-unreach-call', 
'newton_2_7_false-unreach-call',
'newton_2_8_false-unreach-call',
'newton_3_1_true-unreach-call', 
'newton_3_2_true-unreach-call',
'newton_3_3_true-unreach-call',
'newton_3_4_true-unreach-call', 
'newton_3_5_true-unreach-call', 
'newton_3_6_false-unreach-call',
'newton_3_7_false-unreach-call', 
'newton_3_8_false-unreach-call', 
'e1_1',
'e1_2',
'heron10-8',
'slope26+10',
'slope26-10',
'heron156',
'heron',
'slope26-1', 
'optimized_heron', 
'solve_quadratic',
'solve_cubic',
'MullerKahan',
'Odometrie_1',
'Odometrie_10',
'Odometrie_50',
'Odometrie_100',
'Odometrie_150',
'Odometrie_200',
'runge_kutta_1_1', 
'runge_kutta_1_2',
'runge_kutta_1_3',
'runge_kutta_1_4',
'runge_kutta_1_5'
# 'rumps'
]

nba = len(sys.argv)
aa  = str(sys.argv)

print "All args:" , sys.argv[1]

dOpt = sys.argv[1]

gmf = open('bench.make','w')
gmf.write('TARGETS = ')
for b in ab:
	gmf.write(b + ' ')
gmf.write('\n')
gmf.write('VIEWS=1\n')
gmf.write(dOpt + '\n')
gmf.write('.PHONY: $(TARGETS)\n')
gmf.write('all: $(TARGETS)\n')
gmf.write('	@echo "Done all..."\n')

for b in ab:
	of = open(b + '/' + 'Makefile','w')
	of.write(dOpt + '\n')
	of.write('USER_DEFINES=$(CFL)\n')
	of.write('include ../common.make\n')
	of.write('SRCS = main.m ORCmdLineArgs.m\n')
	of.write('EXE  = ' + b + '\n')
	of.write('include ../rules.make\n')
	of.close()
	gmf.write('\n' + b + ':\n')
	gmf.write("	@$(MAKE) -s -C " + b + " USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'\n")

gmf.write('\nclean:\n')
for b in ab:
	gmf.write("	@$(MAKE) -s -C " + b + " clean\n")
gmf.close()
