OC = clang
CFLAGS = `gnustep-config --objc-flags` -msse4.1 -fblocks -fobjc-nonfragile-abi -fobjc-runtime=gnustep \
	$(USER_DEFINES) -I. -I.. \
	-msse4.1 

#-I/opt/gurobi550/linux64/include

LFLAGS = `gnustep-config --base-libs` \
	$(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-L../CPUKernel -Wl,-rpath=`pwd`/../CPUKernel \
	-L../objcp -Wl,-rpath=`pwd`/../objcp \
	-L../objls -Wl,-rpath=`pwd`/../objls \
	-L../ORModeling -Wl,-rpath=`pwd`/../ORModeling \
	-L../ORProgram -Wl,-rpath=`pwd`/../ORProgram \
	-L../objmp -Wl,-rpath=`pwd`/../objmp \
	-lORUtilities -lORFoundation -lCPUKernel -lobjcp -lobjls -lORModeling -lORProgram \
	-lORFoundation -lORUtilities -lobjc \
	`gnustep-config --base-libs` \
	-fobjc-runtime=gnustep

#	-L$(HOME)/gurobi550/linux64/lib -Wl,-rpath=$(HOME)/gurobi550/linux64/lib \
#	-lobjmp -lgurobi55 \

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(basename $(SRCS)))
