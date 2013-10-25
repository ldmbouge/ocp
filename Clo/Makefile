LIBS    = ORUtilities ORFoundation CPUKernel objcp ORModeling ORProgram 
TARGETS = $(LIBS) 

VIEWS=1
CFL= -g

.PHONY: $(TARGETS)

all: $(TARGETS) 
	@make -s -f bench.make
	@echo "Done all..."

objcp:
	@make -s -C objcp USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
ORUtilities:
	@make -s -C ORUtilities USER_DEFINES='-DUSEVIEWS=$(VIEWS)  $(CFL)'
ORFoundation:
	@make -s -C ORFoundation USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
ORModeling:
	@make -s -C ORModeling USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
CPUKernel:
	@make -s -C CPUKernel USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
ORProgram:
	@make -s -C ORProgram USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

clean:
	@make -C objcp clean
	@make -C ORUtilities clean
	@make -C ORFoundation clean
	@make -C ORModeling clean
	@make -C ORProgram clean
	@make -C CPUKernel clean
	@make -f bench.make clean
