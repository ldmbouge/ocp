#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang
GUROBI = /opt/gurobi912/linux64
CFLAGS = `gnustep-config --objc-flags` -fobjc-runtime=gnustep $(USER_DEFINES) -I. -I.. \
	-I../ORFoundation -I../ORUtilities -I../CPUKernel \
	-I$(GUROBI)/include \
	-msse4.1  -fblocks 
LFLAGS = `gnustep-config --base-libs`  -fobjc-runtime=gnustep $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-L../CPUKernel -Wl,-rpath=`pwd`/../CPUKernel \
	-L$(GUROBI)/lib -Wl,-rpath=$(GUROBI)/lib \
	-lORUtilities -lORFoundation -lCPUKernel -lgurobi91


SRCS = LPGurobi.m  LPSolverI.m  MIPGurobi.m  MIPSolverI.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libobjmp.so.1

all: $(LIBNAME)
	@echo "Done... " 
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

