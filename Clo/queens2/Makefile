#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = ~/clang32/bin/clang
OC = clang
GNUstep = /opt/kitkit-1.0-rc1

CFLAGS = -I$(GNUstep)/include -I. -I.. \
	-fblocks -fobjc-nonfragile-abi $(USER_DEFINES)

LFLAGS = `$(GNUstep)/bin/gnustep-config --base-libs` $(USER_DEFINES) \
	-L../objcp -L../ORFoundation -L../ORUtilities -L../ORModeling -L../CPUKernel -L../ORProgram \
	-lobjcp -lORUtilities -lORFoundation -lORModeling -lCPUKernel -lORProgram 
SRCS = main.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libobjcp.so.1 
EXE = queens2

all: $(EXE)
	@echo "Done..."

$(EXE): $(OFILES) ../objcp/libobjcp.so.1
	@$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) -o $(EXE)

%.$(OBJEXT): %.m
	@echo "Compiling m"  $<
	@$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~ $(EXE)

