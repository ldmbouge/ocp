LIBS    = ORUtilities ORFoundation CPUKernel objcp ORModeling ORProgram 
TARGETS = $(LIBS) 
PAR=2
VIEWS=1
#CFL= -O3 -g0
CFL=-g -O0

.PHONY: $(TARGETS)

all: $(TARGETS) 
	@mkdir -p bin
	@cp -ar ../data/* bin
	@python bench.py
	@make -s -j$(PAR) -f bench.make
	@echo "Done all..."

objcp:
	@make -s -C objcp -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
ORUtilities:
	@make -s -C ORUtilities -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS)  $(CFL)'
ORFoundation:
	@make -s -C ORFoundation -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
ORModeling:
	@make -s -C ORModeling -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
CPUKernel:
	@make -s -C CPUKernel -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
ORProgram:
	@make -s -C ORProgram -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

clean:
	@make -C objcp clean
	@make -C ORUtilities clean
	@make -C ORFoundation clean
	@make -C ORModeling clean
	@make -C ORProgram clean
	@make -C CPUKernel clean
	@make -f bench.make clean
	rm -rf bin
