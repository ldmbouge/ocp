#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang-3.5

CFLAGS = `gnustep-config --objc-flags`  $(USER_DEFINES) -I. -I.. \
	-I../ORFoundation -I../ORUtilities -I../CPUKernel \
	-msse4.1  -fblocks -fobjc-nonfragile-abi -DUSEVIEWS=1

LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-L../CPUKernel -Wl,-rpath=`pwd`/../CPUKernel \
	-lORUtilities -lORFoundation -lCPUKernel 

# CFLAGS = -I$(GNUstep)/include -I. -I.. -I../CPUKernel -I../ORFoundation \
# 	-msse4.1 \
# 	-fPIC -fblocks -fobjc-nonfragile-abi $(USER_DEFINES)

# LFLAGS = -L$(GNUstep)/lib $(USER_DEFINES) \
# 	-L../ORUtilities -L../ORFoundation -L../CPUKernel \
# 	-lORUtilities -lORFoundation -lCPUKernel \
# 	-lgnustep-base -lobjc 

SRCS = CPAllDifferentDC.m   CPBitArrayDom.m    CPBitVarI.m CPConstraint.m  \
	CPEvent.m  CPKnapsack.m CPTableI.m CPAssignmentI.m CPBitArray.m  \
	CPCardinalityDC.m  CPElement.m     CPExprI.m    \
	CPLexConstraint.m  CPValueConstraint.m \
	CPBasicConstraint.m  CPRealConstraint.m \
	CPBitConstraint.m  CPCardinality.m    CPEquationBC.m  \
	CPFactory.m  CPObjectQueue.m CPWatch.m CPBinPacking.m CPBitDom.m \
	CPRealDom.m    \
	CPCircuitI.m CPError.m  CPIntVarI.m CPRealVarI.m CPISVarI.m CPIntSetConstraint.m \
	CPTrailIntSet.m CPStatisticsMonitor.m 

#	./NSBoardController.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libobjcp.so.1 
all: $(LIBNAME)
	@echo "Done... " 
	@if [ ! -f $(basename $(LIBNAME)) ];  \
	then \
	  ln -s $(LIBNAME) $(basename $(LIBNAME)); \
	fi


$(LIBNAME): $(OFILES)
	@$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	@$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

