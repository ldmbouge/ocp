LOC=../
include $(LOC)setup.make

CFLAGS += -I../ORFoundation -I../ORUtilities -I../CPUKernel -I../Scheduler

LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-L../CPUKernel -Wl,-rpath=`pwd`/../CPUKernel \
	-L../objcp -Wl,-rpath=`pwd`/../objcp \
	-L../objmp -Wl,-rpath=`pwd`/../objmp \
	-L../ORModeling -Wl,-rpath=`pwd`/../ORModeling \
	-L../Scheduler/ORScheduler -Wl,-rpath=`pwd`/../Scheduler/ORScheduler \
	-L../Scheduler/CPScheduler -Wl,-rpath=`pwd`/../Scheduler/CPScheduler \
	-L../Scheduler/ORSchedulingProgram -Wl,-rpath=`pwd`/../Scheduler/ORSchedulingProgram \
	-lORUtilities -lORFoundation -lCPUKernel -lobjcp -lobjmp -lORModeling \
	-lORScheduler -lCPScheduler -lORSchedulerProgram

SRCS = CPABS.m CPConcretizer.m  CPFirstFail.m  CPMultiStartSolver.m  \
	CPSolver.m  ORSolution.m LPConcretizer.m  ORCPParSolver.m CPBaseHeuristic.m  \
	CPDeg.m CPDDeg.m CPIBS.m CPFDS.m CPParallel.m  CPWDeg.m  LPSolver.m ORProgramFactory.m \
	MIPConcretizer.m MIPSolver.m \
	CPBitVarBaseHeuristic.m CPBitVarFirstFail.m CPBitVarIBS.m CPBitVarABS.m \
	CPRunnable.m   ORColumnGeneration.m     ORLogicBenders.m        ORRunnable.m \
	LPRunnable.m   ORLagrangeRelax.m        ORParallelCombinator.m  ORRunnablePiping.m \
	MIPRunnable.m  ORLagrangianTransform.m  ORParallelRunnable.m    ORSignature.m


OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libORProgram.so.1 
all: runnable $(LIBNAME)
	@echo "(ORProgram) Done... ======================================================================" 
	@if [ ! -f $(basename $(LIBNAME)) ];  \
	then \
	  ln -s $(LIBNAME) $(basename $(LIBNAME)); \
	fi

$(LIBNAME): $(OFILES)
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)


runnable:
	$(shell for f in ORRunnable/*.[mh]; do \
		ln -sf $$f $${f##ORRunnable/}; \
	done)

%.$(OBJEXT): %.m
	@echo "compiling m" $(USER_DEFINES) $<
	$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

