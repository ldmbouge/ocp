include ../setup.make

LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-L../CPUKernel -Wl,-rpath=`pwd`/../CPUKernel \
	-L../objcp -Wl,-rpath=`pwd`/../objcp \
	-L../ORModeling -Wl,-rpath=`pwd`/../ORModeling \
	-L../ORProgram -Wl,-rpath=`pwd`/../ORProgram \
	-L../objmp -Wl,-rpath=`pwd`/../objmp \
	-L../Scheduler/ORScheduler -Wl,-rpath=`pwd`/../Scheduler/ORScheduler \
	-L../Scheduler/CPScheduler -Wl,-rpath=`pwd`/../Scheduler/CPScheduler \
	-L../Scheduler/ORSchedulingProgram -Wl,-rpath=`pwd`/../Scheduler/ORSchedulingProgram \
	-L../objmp -Wl,-rpath=`pwd`/../objmp \
	-L/opt/gurobi752/linux64/lib -Wl,-rpath=/opt/gurobi752/linux64/lib \
	-L../../lib/linux -Wl \
	-lORUtilities -lORFoundation -lCPUKernel -lobjcp -lORModeling -lORProgram \
	-lORScheduler -lCPScheduler -lORSchedulerProgram \
	-lobjmp -lgurobi75 -lfpi -ldispatch \
	-fobjc-runtime=gnustep

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(basename $(SRCS)))
