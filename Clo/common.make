OC = clang
CFLAGS = `gnustep-config --debug-flags` -msse4.1 -fblocks -fobjc-nonfragile-abi -fobjc-runtime=gnustep \
	$(USER_DEFINES) -I. -I.. \
	-msse4.1 

LFLAGS = \
	$(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-L../CPUKernel -Wl,-rpath=`pwd`/../CPUKernel \
	-L../objcp -Wl,-rpath=`pwd`/../objcp \
	-L../objls -Wl,-rpath=`pwd`/../objls \
	-L../ORModeling -Wl,-rpath=`pwd`/../ORModeling \
	-L../ORProgram -Wl,-rpath=`pwd`/../ORProgram \
	-L../objmp -Wl,-rpath=`pwd`/../objmp \
	-lobjc \
	-lORUtilities -lORFoundation -lCPUKernel -lobjcp -lobjls -lobjmp -lORModeling -lORProgram \
	`gnustep-config --base-libs` \
	-fobjc-runtime=gnustep

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(basename $(SRCS)))
