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

ab = [
        'SMTLIB2'
      ,
      'Float/heron',
      'Float/heron156',
      'Float/solve_cubic',
      'Float/inv_square_int_true_unreach-call',
      'Float/float_int_inv_square_false-unreach-call',
      'Float/slope26-1',
      'Float/Odometrie_1',
      'Float/Odometrie_10',
      'Float/Odometrie_100',
      'Float/Odometrie_150',
      'Float/Odometrie_200',
      'Float/Odometrie_50',
      'Float/add_01_1000_1',
      'Float/add_01_1000_2',
      'Float/add_01_1000_3',
      'Float/add_01_1000_4',
      'Float/add_01_100_1',
      'Float/add_01_100_2',
      'Float/add_01_100_3',
      'Float/add_01_100_4',
      'Float/add_01_10_1',
      'Float/add_01_10_2',
      'Float/add_01_10_3',
      'Float/add_01_10_4',
      'Float/add_01_1_1',
      'Float/add_01_1_2',
      'Float/add_01_1_3',
      'Float/add_01_1_4',
      'Float/div1_10',
      'Float/div1_20',
      'Float/div1_3',
      'Float/div1_30',
      'Float/div1_40',
      'Float/div1_50',
      'Float/div2_10',
      'Float/div2_20',
      'Float/div2_3',
      'Float/div2_30',
      'Float/div2_40',
      'Float/div2_50',
      'Float/div3_10',
      'Float/div3_20',
      'Float/div3_3',
      'Float/div3_30',
      'Float/div3_40',
      'Float/div3_50',
      'Float/e1_1',
      'Float/e1_2',
      'Float/e2_1',
      'Float/e2_2',
      'Float/e2_3',
      'Float/e_1',
      'Float/heron10-8',
      'Float/mul_000003_30000_1',
      'Float/mul_03_3000_1',
      'Float/mul_03_300_1',
      'Float/mul_03_30_1',
      'Float/mul_03_30_2',
      'Float/mul_03_30_3',
      'Float/mul_03_30_4',
      'Float/mul_03_30_5',
      'Float/mul_03_30_6',
      'Float/mul_03_30_7',
      'Float/mul_03_3_1',
      'Float/mul_03_3_2',
      'Float/mul_03_3_3',
      'Float/mul_03_3_4',
      'Float/mult1_10',
      'Float/mult1_20',
      'Float/mult1_3',
      'Float/mult1_30',
      'Float/mult1_40',
      'Float/mult1_50',
      'Float/mult2_10',
      'Float/mult2_20',
      'Float/mult2_3',
      'Float/mult2_30',
      'Float/mult2_40',
      'Float/mult2_50',
      'Float/newton_1_1_true-unreach-call',
      'Float/newton_1_2_true-unreach-call',
      'Float/newton_1_3_true-unreach-call',
      'Float/newton_1_4_false-unreach-call',
      'Float/newton_1_5_false-unreach-call',
      'Float/newton_1_6_false-unreach-call',
      'Float/newton_1_7_false-unreach-call',
      'Float/newton_1_8_false-unreach-call',
      'Float/newton_2_1_true-unreach-call',
      'Float/newton_2_2_true-unreach-call',
      'Float/newton_2_3_true-unreach-call',
      'Float/newton_2_4_true-unreach-call',
      'Float/newton_2_5_true-unreach-call',
      'Float/newton_2_6_false-unreach-call',
      'Float/newton_2_7_false-unreach-call',
      'Float/newton_2_8_false-unreach-call',
      'Float/newton_3_1_true-unreach-call',
      'Float/newton_3_2_true-unreach-call',
      'Float/newton_3_3_true-unreach-call',
      'Float/newton_3_4_true-unreach-call',
      'Float/newton_3_5_true-unreach-call',
      'Float/newton_3_6_false-unreach-call',
      'Float/newton_3_7_false-unreach-call',
      'Float/newton_3_8_false-unreach-call',
      'Float/optimized_heron',
      'Float/pid_diff_opt1',
      'Float/pid_diff_opt10',
      'Float/pid_diff_opt4',
      'Float/pid_diff_opt5',
      'Float/pid_diff_opt6',
      'Float/pid_diff_opt7',
      'Float/pid_diff_opt8',
      'Float/pid_diff_opt9',
      'Float/pid_diff_unsat_10',
      'Float/pid_diff_unsat_9',
      'Float/pid_diff_unsat_8',
      'Float/pid_diff_unsat_7',
      'Float/pid_diff_unsat_6',
      'Float/pid_diff_unsat_5',
      'Float/precise_1',
      'Float/precise_2',
      'Float/precise_3',
      'Float/precise_4',
      'Float/range_add_mult',
      'Float/rumps',
      'Float/runge_kutta_1_1',
      'Float/runge_kutta_1_2',
      'Float/runge_kutta_1_3',
      'Float/runge_kutta_1_4',
      'Float/runge_kutta_1_5',
      'Float/sine_1_false-unreach-call',
      'Float/sine_2_false-unreach-call',
      'Float/sine_3_false-unreach-call',
      'Float/sine_4',
      'Float/sine_5',
      'Float/sine_6',
      'Float/sine_7',
      'Float/sine_8',
      'Float/sine_double',
      'Float/slope26+10',
      'Float/solve_quadratic',
      'Float/square_1_false-unreach-call',
      'Float/square_2_false-unreach-call',
      'Float/square_3_false-unreach-call',
      'Float/square_4_false-unreach-call',
      'Float/square_5_false-unreach-call',
      'Float/square_6_false-unreach-call',
      'Float/square_7_false-unreach-call',
      'Float/square_8_false-unreach-call',
      'Float/square_8_true-unreach-call',
      'Float/testAbs',
      'Float/testMultipleAbs'
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
        splittedPath = b.split('/')
        of.write('LOC=' + ''.join(['../' for p in splittedPath]) + '\n');
	of.write('include $(LOC)common.make\n')
	of.write('SRCS = main.m ORCmdLineArgs.m\n')
	of.write('EXE  = ' + os.path.basename(b) + '\n')
	of.write('include $(LOC)rules.make\n')
	of.close()
	gmf.write('\n' + b + ':\n')
	gmf.write("	@$(MAKE) -s -C " + b + " USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'\n")

gmf.write('\nclean:\n')
for b in ab:
	gmf.write("	@$(MAKE) -s -C " + b + " clean\n")
gmf.close()
