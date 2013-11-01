OC = clang
CFLAGS = `gnustep-config --objc-flags`  $(USER_DEFINES) -I. -I.. -I/opt/gurobi550/linux64/include \
	-msse4.1
LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-L../CPUKernel -Wl,-rpath=`pwd`/../CPUKernel \
	-L../objcp -Wl,-rpath=`pwd`/../objcp \
	-L../ORModeling -Wl,-rpath=`pwd`/../ORModeling \
	-L../ORProgram -Wl,-rpath=`pwd`/../ORProgram \
	-L../objmp -Wl,-rpath=`pwd`/../objmp \
	-L/opt/gurobi550/linux64/lib -Wl,-rpath=/opt/gurobi550/linux64/lib \
	-lORUtilities -lORFoundation -lCPUKernel -lobjcp -lORModeling -lORProgram -lobjmp -lgurobi55
OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(basename $(SRCS)))
