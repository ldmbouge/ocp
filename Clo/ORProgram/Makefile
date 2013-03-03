#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = ~/clang32/bin/clang
CFLAGS = -g -I/usr/GNUstep/System/Library/Headers -I.. -I. \
	-I../ORUtilities -I../ORFoundation -I../CPUKernel \
	-fblocks -fobjc-nonfragile-abi

LFLAGS = -g -L/usr/GNUstep/System/Library/Libraries -lgnustep-base -lobjc 
SRCS = CPABS.m CPConcretizer.m  CPFirstFail.m  CPMultiStartSolver.m  \
	CPSolver.m  LPConcretizer.m  ORCPParSolver.m CPBaseHeuristic.m  CPDDeg.m    \
	CPIBS.m CPParallel.m  CPWDeg.m  LPSolver.m ORProgramFactory.m



OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libORProgram.so.1 
all: $(LIBNAME)
	@echo "Done..."

$(LIBNAME): $(OFILES)
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

