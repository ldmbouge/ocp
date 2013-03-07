LIBS    = ORUtilities ORFoundation CPUKernel objcp ORProgram ORModeling
TARGETS = $(LIBS) queens2 

	# queensAC Sudoku magicserie queensACSem

VIEWS=1

.PHONY: $(TARGETS) $(LIBS)

all: $(TARGETS)
	@echo "Done all..."

objcp:
	@make -C objcp USER_DEFINES='-DUSEVIEWS=$(VIEWS)'
ORUtilities:
	@make -C ORUtilities USER_DEFINES='-DUSEVIEWS=$(VIEWS)'
ORFoundation:
	@make -C ORFoundation USER_DEFINES='-DUSEVIEWS=$(VIEWS)'
ORModeling:
	@make -C ORModeling USER_DEFINES='-DUSEVIEWS=$(VIEWS)'
CPUKernel:
	@make -C CPUKernel USER_DEFINES='-DUSEVIEWS=$(VIEWS)'
ORProgram:
	@make -C ORProgram USER_DEFINES='-DUSEVIEWS=$(VIEWS)'

queens2: 
	@make -C queens2 USER_DEFINES='-DUSEVIEWS=$(VIEWS)'

queensAC:  $(LIBS)
	@make -C queensAC all USER_DEFINES='-DUSEVIEWS=$(VIEWS)'

queensACSem:  $(LIBS)
	@make -C queensACSem USER_DEFINES='-DUSEVIEWS=$(VIEWS)'

Sudoku: $(LIBS)
	@make -C Sudoku USER_DEFINES='-DUSEVIEWS=$(VIEWS)'

magicserie: $(LIBS)
	@make -C magicserie USER_DEFINES='-DUSEVIEWS=$(VIEWS)'

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
