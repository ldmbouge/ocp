#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang-3.5

CFLAGS = `gnustep-config --objc-flags`  $(USER_DEFINES) -I. -I.. \
	-I../ORFoundation -I../ORUtilities -I../CPUKernel \
	-msse4.1 -fblocks -fobjc-nonfragile-abi
LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-L../CPUKernel -Wl,-rpath=`pwd`/../CPUKernel \
	-L../objcp -Wl,-rpath=`pwd`/../objcp \
	-L../ORModeling -Wl,-rpath=`pwd`/../ORModeling \
	-lORUtilities -lORFoundation -lCPUKernel -lobjcp -lORModeling

# CFLAGS = -I$(GNUstep)/include -I.. -I. -I../CPUKernel -fPIC -msse4.1 \
# 	-fblocks -fobjc-nonfragile-abi $(USER_DEFINES)

# LFLAGS = -L$(GNUstep)/lib $(USER_DEFINES) \
# 	-L../ORUtilities -L../ORFoundation -L../CPUKernel -L../ORModeling -L../objcp \
# 	-lORUtilities -lORFoundation -lCPUKernel -lORModeling -lobjcp \
# 	-lgnustep-base -lobjc 

SRCS = CPABS.m CPConcretizer.m  CPFirstFail.m  CPMultiStartSolver.m  \
	CPSolver.m  ORSolution.m LPConcretizer.m  ORCPParSolver.m CPBaseHeuristic.m  \
	CPDeg.m CPDDeg.m CPIBS.m CPParallel.m  CPWDeg.m  LPSolver.m ORProgramFactory.m \
	MIPConcretizer.m MIPSolver.m



OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libORProgram.so.1 
all: $(LIBNAME)
	@echo "Done..."
	@if [ ! -f $(basename $(LIBNAME)) ];  \
	then \
	  ln -s $(LIBNAME) $(basename $(LIBNAME)); \
	fi

$(LIBNAME): $(OFILES)
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

