#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang
GNUstep = /opt/kitkit-1.0-rc1

CFLAGS = `gnustep-config --objc-flags`  $(USER_DEFINES) -I. -I.. \
	-I../ORFoundation -I../ORUtilities -msse4.1
LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-lORUtilities -lORFoundation

# CFLAGS = -I$(GNUstep)/include -I.. -I. -I../ORUtilities -msse4.1 \
# 	-fPIC -fblocks -fobjc-nonfragile-abi $(USER_DEFINES)

# LFLAGS = -L$(GNUstep)/lib $(USER_DEFINES) \
# 	-L../ORUtilities -L../ORFoundation \
# 	-lORUtilities -lORFoundation \
# 	-lgnustep-base -lobjc 

SRCS = CPConstraintI.m  CPEngineI.m  CPGroup.m  CPTrigger.m  CPTypes.m  CPUKernel.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libCPUKernel.so.1 
all: $(LIBNAME)
	@echo "Done..."
	@if [ ! -f $(basename $(LIBNAME)) ];  \
	then \
	  ln -s $(LIBNAME) $(basename $(LIBNAME)); \
	fi

$(LIBNAME): $(OFILES)
	@$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	@$(OC) $(CFLAGS) -c $< 

clean:
	@rm -rf *.o *~

