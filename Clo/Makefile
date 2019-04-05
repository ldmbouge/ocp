LIBS    = ORUtilities ORFoundation CPUKernel objcp objmp ORModeling \
	ORScheduler CPScheduler ORSchedulerProgram \
	ORProgram Verification

TARGETS = $(LIBS) 
PAR=2
VIEWS=1
#CFL= -O3 -g0
CFL=-g -O0
#CFL=-O2

.PHONY: $(TARGETS)

all: links $(TARGETS) 
	@mkdir -p bin
	@cp -ar ../data/* bin
	@python bench.py CFL='$(CFL)'
	$(MAKE) -s -j$(PAR) -f bench.make
	@echo "Done all..."

links:
	make -s -C ORProgram runnable USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
	mkdir -p jobshop
	(cd jobshop; ln -sf ../Scheduler/Tests/jobshop/* .)


objcp:
	make -s -C objcp -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
objmp:
	make -s -C objmp -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
ORUtilities:
	make -s -C ORUtilities -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS)  $(CFL)'
ORFoundation:
	make -s -C ORFoundation -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
ORModeling:
	make -s -C ORModeling -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
CPUKernel:
	make -s -C CPUKernel -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
ORProgram:
	make -s -C ORProgram -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
ORScheduler:
	make -s -C Scheduler/ORScheduler -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
CPScheduler:
	make -s -C Scheduler/CPScheduler -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)' 
ORSchedulerProgram:
	make -s -C Scheduler/ORSchedulingProgram -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
Verification:
	make -s -C Verification -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

clean:
	@make -C objcp clean
	@make -C ORUtilities clean
	@make -C ORFoundation clean
	@make -C ORModeling clean
	@make -C ORProgram clean
	@make -C CPUKernel clean
	@make -C Scheduler/ORScheduler clean
	@make -C Scheduler/CPScheduler clean
	@make -C Scheduler/ORSchedulingProgram clean
	@make -C Verification clean
	@make -f bench.make clean
	rm -rf bin
