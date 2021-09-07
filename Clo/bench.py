#!/usr/bin/python
import subprocess
import os
import sys
import json


ab = [
        'magicSquareLS',
        'magicserieLS',
        'progressiveLS',
        'queensLS',
        'sceneLS',
        'smoryLS',
        'sudokuLS',
        'ais',
        'bacp',
        'bibd',
        'circle',
        'coloringModel',
        'costas',
        'costas2',
        'debruijn',
        'eq20',
        'Euler',
        'fdmul',
        'fdmul2',
        'fwarehouse',
        'golomb',
        'grocery',
        'knapsack',
        'knapsackOpt',
        'langford',
        'latinSquare',
        'magicserie',
        'magicseriesModel',
        'magicsquareModel',
        'market2s',
        'marriage',
        'minesweeper',
        'nfraction',
        'nonogram',
        'order',
        'paq',
        'partition',
        'perfect',
        'progressive',
        'qg7',
        'queens2',
        'queensAC',
        'queensACSem',
        'queensMIP',
        'queensModel',
        'queensNaive',
        'regular',
        'slab',
        'slabLNSModel',
        'slabModel',
        'slow_convergence',
        'sport',
        'sportModel',
        'stressLimit',
        'Sudoku',
        'TestAssignment',
        'testLPConcretization',
        'testMIP',
        'testPacking',
        'warehouse',
        'wka']

print ab

gmf = open('bench.make','w')
gmf.write('TARGETS = ')
for b in ab:
	gmf.write(b + ' ')
gmf.write('\n')
gmf.write('VIEWS=1\n')
gmf.write('CFL= -g\n')
gmf.write('.PHONY: $(TARGETS)\n')
gmf.write('all: $(TARGETS)\n')
gmf.write('	@echo "Done all..."\n')

for b in ab:
	of = open(b + '/' + 'Makefile','w')
	of.write('include ../common.make\n')
	of.write('SRCS = main.m ORCmdLineArgs.m\n')
	of.write('EXE  = ' + b + '\n')
	of.write('include ../rules.make\n')
	of.close()
	gmf.write('\n' + b + ':\n')
	gmf.write("	@make -s -C " + b + " USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'\n")

gmf.write('\nclean:\n')
for b in ab:
	gmf.write("	@make -s -C " + b + " clean\n")
gmf.close()
