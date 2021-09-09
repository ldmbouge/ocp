LIBS    = ORUtilities ORFoundation CPUKernel objcp ORModeling ORProgram objls objmp
TARGETS = $(LIBS) 
PAR=3
VIEWS=1
#CFL= -O3 -g0
CFL=-g

.PHONY: $(TARGETS)

all: $(TARGETS) 
	@mkdir -p bin
	@cp -ar ../data/* bin
	@python bench.py
	+@$(MAKE) -s -j$(PAR) -f bench.make
	@echo "Done all..."

objcp:
	$(MAKE) -s -C objcp -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
objls:
	$(MAKE) -s -C objls -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
objmp:
	$(MAKE) -s -C objmp -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
ORUtilities:
	$(MAKE) -s -C ORUtilities -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS)  $(CFL)'
ORFoundation:
	$(MAKE) -s -C ORFoundation -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
ORModeling:
	$(MAKE) -s -C ORModeling -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
CPUKernel:
	$(MAKE) -s -C CPUKernel -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'
ORProgram:
	+$(MAKE) -s -C ORProgram -j$(PAR) USER_DEFINES='-DUSEVIEWS=$(VIEWS) $(CFL)'

clean:
	@$(MAKE) -C objcp clean
	@$(MAKE) -C ORUtilities clean
	@$(MAKE) -C ORFoundation clean
	@$(MAKE) -C ORModeling clean
	@$(MAKE) -C ORProgram clean
	@$(MAKE) -C CPUKernel clean
	@$(MAKE) -f bench.make clean
	rm -rf bin
