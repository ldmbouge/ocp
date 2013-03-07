#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = ~/clang32/bin/clang
CFLAGS = -g -I/usr/GNUstep/System/Library/Headers -I.. -I. -I../ORUtilities \
	-fblocks -fobjc-nonfragile-abi 

LFLAGS = -g -L/usr/GNUstep/System/Library/Libraries \
	-L../ORUtilities -L../ORFoundation \
	-lORUtilities -lORFoundation \
	-lgnustep-base -lobjc 

SRCS = CPConstraintI.m  CPEngineI.m  CPGroup.m  CPTrigger.m  CPTypes.m  CPUKernel.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libCPUKernel.so.1 
all: $(LIBNAME)
	@echo "Done..."

$(LIBNAME): $(OFILES)
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

