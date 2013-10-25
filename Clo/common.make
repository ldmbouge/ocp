OC = clang
CFLAGS = `gnustep-config --objc-flags`  $(USER_DEFINES) -I. -I.. \
	-msse4.1
LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-L../CPUKernel -Wl,-rpath=`pwd`/../CPUKernel \
	-L../objcp -Wl,-rpath=`pwd`/../objcp \
	-L../ORModeling -Wl,-rpath=`pwd`/../ORModeling \
	-L../ORProgram -Wl,-rpath=`pwd`/../ORProgram \
	-lORUtilities -lORFoundation -lCPUKernel -lobjcp -lORModeling -lORProgram
OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(basename $(SRCS)))
