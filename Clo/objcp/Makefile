#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = ~/clang32/bin/clang

CFLAGS = -g -I/usr/GNUstep/System/Library/Headers -I. -I.. -I../CPUKernel -fblocks -fobjc-nonfragile-abi
LFLAGS = -g -L/usr/GNUstep/System/Library/Libraries \
	-L../ORUtilities -L../ORFoundation -L../CPUKernel \
	-lORUtilities -lORFoundation -lCPUKernel \
	-lgnustep-base -lobjc 

SRCS = CPAllDifferentDC.m   CPBitArrayDom.m    CPBitVarI.m        CPConstraint.m  \
	CPEvent.m    CPKnapsack.m           CPTableI.m CPAssignmentI.m      CPBitArray.m  \
	CPCardinalityDC.m  CPElement.m     CPExprI.m    CPLexConstraint.m  CPValueConstraint.m \
	CPBasicConstraint.m  CPBitConstraint.m  CPCardinality.m    CPEquationBC.m  \
	CPFactory.m  CPObjectQueue.m CPWatch.m CPBinPacking.m CPBitDom.m    \
	CPCircuitI.m CPError.m  CPIntVarI.m  CPStatisticsMonitor.m 

#	./NSBoardController.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libobjcp.so.1 
all: $(LIBNAME)
	@echo "Done..."

$(LIBNAME): $(OFILES)
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

