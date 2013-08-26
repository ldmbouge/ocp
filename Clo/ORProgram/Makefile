#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang
GNUstep = /opt/kitkit-1.0-rc1

CFLAGS = -I$(GNUstep)/include -I.. -I. -I../CPUKernel -fPIC \
	-fblocks -fobjc-nonfragile-abi $(USER_DEFINES)

LFLAGS = -L$(GNUstep)/lib $(USER_DEFINES) \
	-L../ORUtilities -L../ORFoundation -L../CPUKernel -L../ORModeling -L../objcp \
	-lORUtilities -lORFoundation -lCPUKernel -lORModeling -lobjcp \
	-lgnustep-base -lobjc 

SRCS = CPABS.m CPConcretizer.m  CPFirstFail.m  CPMultiStartSolver.m  \
	CPSolver.m  LPConcretizer.m  ORCPParSolver.m CPBaseHeuristic.m  \
	CPDDeg.m CPIBS.m CPParallel.m  CPWDeg.m  LPSolver.m ORProgramFactory.m \
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
	@$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	@$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

