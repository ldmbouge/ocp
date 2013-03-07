#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = ~/clang32/bin/clang

CFLAGS = -g -I/usr/GNUstep/System/Library/Headers -I. -I.. \
	-fblocks -fobjc-nonfragile-abi 
	
LFLAGS = -g `/usr/GNUstep/System/Tools/gnustep-config --base-libs`  \
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
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) -o $(EXE)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	@$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

