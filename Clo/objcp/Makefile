#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang
CFLAGS = -g -I/usr/GNUstep/System/Library/Headers -I. -fblocks -fobjc-nonfragile-abi
LFLAGS = -g -L/usr/GNUstep/System/Library/Libraries -lgnustep-base -lobjc 
SRCS =./CPFactory.m ./SemBDSController.m ./CPCardinality.m ./CPBitArray.m ./CPCommand.m \
	./CPParallel.m ./CPCreateI.m ./CPSelector.m ./CPTrigger.m ./CPObjectQueue.m ./CPLabel.m \
	./CPWatch.m ./CPAllDifferentDC.m ./CPExplorerI.m ./CPSolverI.m ./CPCrFactory.m ./CPSetI.m \
	./CPConstraintI.m ./CPConstraint.m ./CPTracer.m ./CPValueConstraint.m ./CPError.m \
	./CPFactoryI.m ./CPAVLTree.m ./CPBitDom.m ./CPEvents.m ./CPTrail.m ./CPWDeg.m \
	./CPEquationBC.m ./CPI.m ./cont.m ./CPExprI.m ./CPBitVarI.m ./CPIntVarI.m ./context.m \
	./CPBasicConstraint.m ./CPController.m  ./CPLimit.m ./DFSController.m \
	./CPBitArrayDom.m ./CPArrayI.m ./CPConcurrencyI.m ./CPDataI.m ./CPBitConstraint.m \
	./SemDFSController.m 
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

