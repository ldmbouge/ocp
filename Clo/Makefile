TARGETS = ORUtilities ORFoundation CPUKernel objcp ORProgram ORModeling \
	queens2 

	# queensAC Sudoku magicserie queensACSem

.PHONY: $(TARGETS)

all: $(TARGETS)
	@echo "Done..."

objcp:
	@make -C objcp
ORUtilities:
	@make -C ORUtilities
ORFoundation:
	@make -C ORFoundation
ORModeling:
	@make -C ORModeling
CPUKernel:
	@make -C CPUKernel
ORProgram:
	@make -C ORProgram

queens2: 
	echo $< 
	make -C queens2

queensAC:  objcp
	make -C queensAC all

queensACSem:  objcp
	make -C queensACSem

Sudoku: objcp
	make -C Sudoku

magicserie: objcp
	make -C magicserie

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
