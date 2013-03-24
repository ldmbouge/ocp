LIBS    = ORUtilities ORFoundation CPUKernel objcp ORModeling ORProgram 
TARGETS = $(LIBS) queens2 knapsack

# queensAC Sudoku magicserie queensACSem

VIEWS=1
CFL= -O3

.PHONY: $(TARGETS)

all: $(TARGETS) queens2
	@echo "Done all..."

objcp:
	@make -C objcp USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
ORUtilities:
	@make -C ORUtilities USER_DEFINES='-DUSEVIEWS=$(VIEWS)  $(CFL)'
ORFoundation:
	@make -C ORFoundation USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
ORModeling:
	@make -C ORModeling USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
CPUKernel:
	@make -C CPUKernel USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
ORProgram:
	@make -C ORProgram USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
queens2: 
	@make -C queens2 USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

knapsack: 
	make -C knapsack USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

queensAC:  $(LIBS)
	@make -C queensAC all USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

queensACSem:  $(LIBS)
	@make -C queensACSem USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

Sudoku: $(LIBS)
	@make -C Sudoku USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

magicserie: $(LIBS)
	@make -C magicserie USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

clean:
	@make -C objcp clean
	@make -C ORUtilities clean
	@make -C ORFoundation clean
	@make -C ORModeling clean
	@make -C ORProgram clean
	@make -C CPUKernel clean
	@make -C Sudoku clean
	@make -C queens2 clean
	@make -C queensAC clean
	@make -C queensACSem clean
	@make -C magicserie clean
