include $(LOC)setup.make

LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L$(LOC)ORUtilities -Wl,-rpath=$(realpath $(LOC)ORUtilities) \
	-L$(LOC)ORFoundation -Wl,-rpath=$(realpath $(LOC)ORFoundation) \
	-L$(LOC)CPUKernel -Wl,-rpath=$(realpath $(LOC)CPUKernel) \
	-L$(LOC)objcp -Wl,-rpath=$(realpath $(LOC)objcp) \
	-L$(LOC)ORModeling -Wl,-rpath=$(realpath $(LOC)ORModeling) \
	-L$(LOC)ORProgram -Wl,-rpath=$(realpath $(LOC)ORProgram) \
	-L$(LOC)objmp -Wl,-rpath=$(realpath $(LOC)objmp) \
	-L$(LOC)Scheduler/ORScheduler -Wl,-rpath=$(realpath $(LOC)Scheduler/ORScheduler) \
	-L$(LOC)Scheduler/CPScheduler -Wl,-rpath=$(realpath $(LOC)Scheduler/CPScheduler) \
	-L$(LOC)Scheduler/ORSchedulingProgram -Wl,-rpath=$(realpath $(LOC)Scheduler/ORSchedulingProgram) \
	-L$(LOC)objmp -Wl,-rpath=$(realpath $(LOC)objmp) \
	-L$(LOC)Verification -Wl,-rpath=$(realpath $(LOC)Verification) \
	-L/opt/gurobi752/linux64/lib -Wl,-rpath=/opt/gurobi752/linux64/lib \
	-L$(LOC)$(LOC)lib/linux -Wl \
	-lORUtilities -lORFoundation -lCPUKernel -lobjcp -lORModeling -lORProgram \
	-lORScheduler -lCPScheduler -lORSchedulerProgram -lVerification\
	-lobjmp -lgurobi75 -lfpi -ldispatch \
	-fobjc-runtime=gnustep

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(basename $(SRCS)))
