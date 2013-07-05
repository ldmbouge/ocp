#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang
GNUstep = /opt/kitkit-1.0-rc1


CFLAGS = -I$(GNUstep)/include -I. -I.. \
	-fblocks -fobjc-nonfragile-abi $(USER_DEFINES)

#### `$(GNUstep)/bin/gnustep-config --base-libs` 

LFLAGS = -rdynamic -pthread -fexceptions -fgnu-runtime \
	-L$(GNUstep)/lib -lgnustep-base -lobjc -lm \
	$(USER_DEFINES)\
	-L../objcp -L../ORFoundation -L../ORUtilities -L../ORModeling \
	-L../CPUKernel -L../ORProgram \
	-lobjcp -lORUtilities -lORFoundation -lORModeling -lCPUKernel \
	-lORProgram 
SRCS = main.m ../ORCmdLineArgs.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(basename $(SRCS)))
LIBNAME = libobjcp.so.1 
EXE = knapsack

all: $(EXE) data
	@echo "Done..." $(EXE)

$(EXE):  $(OFILES)
	@echo "Linking $(EXE)"
	@$(OC) $(CFLAGS) $(notdir $(OFILES)) $(LFLAGS) -o $(EXE)

data:
	@cp -r ../../data/MKNAP .

%.$(OBJEXT): %.m
	@echo "Compiling m"  $<
	@$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~ $(EXE)

