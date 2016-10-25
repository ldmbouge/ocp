include ../setup.make

LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-L../CPUKernel -Wl,-rpath=`pwd`/../CPUKernel \
	-L../objcp -Wl,-rpath=`pwd`/../objcp \
	-L../ORModeling -Wl,-rpath=`pwd`/../ORModeling \
	-L../ORProgram -Wl,-rpath=`pwd`/../ORProgram \
	-L../objmp -Wl,-rpath=`pwd`/../objmp \
	-L/opt/gurobi652/linux64/lib -Wl,-rpath=/opt/gurobi652/linux64/lib \
	-lORUtilities -lORFoundation -lCPUKernel -lobjcp -lORModeling -lORProgram \
	-lobjmp -lgurobi65 \
	-fobjc-runtime=gnustep

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(basename $(SRCS)))
