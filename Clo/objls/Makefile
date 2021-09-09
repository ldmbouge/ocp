#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang

CFLAGS = `gnustep-config --debug-flags` -fobjc-runtime=gnustep $(USER_DEFINES) -I. -I.. \
	-I../ORFoundation -I../ORUtilities -I../CPUKernel \
	-msse4.1  -fblocks 
LFLAGS = `gnustep-config --base-libs`  -fobjc-runtime=gnustep $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-L../CPUKernel -Wl,-rpath=`pwd`/../CPUKernel \
	-lORUtilities -lORFoundation -lCPUKernel 


SRCS = LSAllDifferent.m  LSConstraint.m  LSExactly.m      LSGlobalInvariants.m  LSPriority.m    LSSystem.m         objls.m\
	LSBasic.m         LSCount.m       LSFactory.m      LSIntVar.m            LSPropagator.m  LSVar.m\
	LSCardinality.m   LSEngineI.m     LSFunVariable.m  LSLinear.m            LSSolver.m      ORLSConcretizer.m


OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libobjls.so.1 
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

