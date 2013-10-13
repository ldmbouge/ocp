TARGETS = ais bacp bibd circle coloringModel costas costas2 debruijn eq20 Euler fdmul fdmul2 fwarehouse golomb grocery knapsack knapsackOpt langford latinSquare magicserie magicseriesModel magicsquareModel market2s marriage minesweeper nfraction nonogram order paq partition perfect progressive qg7 queens2 queensAC queensACSem queensMIP queensModel queensNaive regular slab slabLNSModel slabModel slow_convergence sport sportModel stressLimit Sudoku TestAssignment testLPConcretization testMIP testPacking warehouse wka 
VIEWS=1
CFL= -g
.PHONY: $(TARGETS)
all: $(TARGETS)
	@echo "Done all..."

ais:
	@make -s -C ais USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

bacp:
	@make -s -C bacp USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

bibd:
	@make -s -C bibd USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

circle:
	@make -s -C circle USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

coloringModel:
	@make -s -C coloringModel USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

costas:
	@make -s -C costas USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

costas2:
	@make -s -C costas2 USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

debruijn:
	@make -s -C debruijn USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

eq20:
	@make -s -C eq20 USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

Euler:
	@make -s -C Euler USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

fdmul:
	@make -s -C fdmul USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

fdmul2:
	@make -s -C fdmul2 USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

fwarehouse:
	@make -s -C fwarehouse USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

golomb:
	@make -s -C golomb USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

grocery:
	@make -s -C grocery USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

knapsack:
	@make -s -C knapsack USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

knapsackOpt:
	@make -s -C knapsackOpt USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

langford:
	@make -s -C langford USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

latinSquare:
	@make -s -C latinSquare USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

magicserie:
	@make -s -C magicserie USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

magicseriesModel:
	@make -s -C magicseriesModel USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

magicsquareModel:
	@make -s -C magicsquareModel USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

market2s:
	@make -s -C market2s USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

marriage:
	@make -s -C marriage USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

minesweeper:
	@make -s -C minesweeper USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

nfraction:
	@make -s -C nfraction USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

nonogram:
	@make -s -C nonogram USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

order:
	@make -s -C order USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

paq:
	@make -s -C paq USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

partition:
	@make -s -C partition USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

perfect:
	@make -s -C perfect USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

progressive:
	@make -s -C progressive USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

qg7:
	@make -s -C qg7 USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

queens2:
	@make -s -C queens2 USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

queensAC:
	@make -s -C queensAC USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

queensACSem:
	@make -s -C queensACSem USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

queensMIP:
	@make -s -C queensMIP USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

queensModel:
	@make -s -C queensModel USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

queensNaive:
	@make -s -C queensNaive USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

regular:
	@make -s -C regular USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

slab:
	@make -s -C slab USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

slabLNSModel:
	@make -s -C slabLNSModel USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

slabModel:
	@make -s -C slabModel USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

slow_convergence:
	@make -s -C slow_convergence USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

sport:
	@make -s -C sport USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

sportModel:
	@make -s -C sportModel USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

stressLimit:
	@make -s -C stressLimit USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

Sudoku:
	@make -s -C Sudoku USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

TestAssignment:
	@make -s -C TestAssignment USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

testLPConcretization:
	@make -s -C testLPConcretization USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

testMIP:
	@make -s -C testMIP USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

testPacking:
	@make -s -C testPacking USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

warehouse:
	@make -s -C warehouse USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

wka:
	@make -s -C wka USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

clean:
	@make -s -C ais clean
	@make -s -C bacp clean
	@make -s -C bibd clean
	@make -s -C circle clean
	@make -s -C coloringModel clean
	@make -s -C costas clean
	@make -s -C costas2 clean
	@make -s -C debruijn clean
	@make -s -C eq20 clean
	@make -s -C Euler clean
	@make -s -C fdmul clean
	@make -s -C fdmul2 clean
	@make -s -C fwarehouse clean
	@make -s -C golomb clean
	@make -s -C grocery clean
	@make -s -C knapsack clean
	@make -s -C knapsackOpt clean
	@make -s -C langford clean
	@make -s -C latinSquare clean
	@make -s -C magicserie clean
	@make -s -C magicseriesModel clean
	@make -s -C magicsquareModel clean
	@make -s -C market2s clean
	@make -s -C marriage clean
	@make -s -C minesweeper clean
	@make -s -C nfraction clean
	@make -s -C nonogram clean
	@make -s -C order clean
	@make -s -C paq clean
	@make -s -C partition clean
	@make -s -C perfect clean
	@make -s -C progressive clean
	@make -s -C qg7 clean
	@make -s -C queens2 clean
	@make -s -C queensAC clean
	@make -s -C queensACSem clean
	@make -s -C queensMIP clean
	@make -s -C queensModel clean
	@make -s -C queensNaive clean
	@make -s -C regular clean
	@make -s -C slab clean
	@make -s -C slabLNSModel clean
	@make -s -C slabModel clean
	@make -s -C slow_convergence clean
	@make -s -C sport clean
	@make -s -C sportModel clean
	@make -s -C stressLimit clean
	@make -s -C Sudoku clean
	@make -s -C TestAssignment clean
	@make -s -C testLPConcretization clean
	@make -s -C testMIP clean
	@make -s -C testPacking clean
	@make -s -C warehouse clean
	@make -s -C wka clean
