#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang
GNUstep = /opt/kitkit-1.0-rc1

CFLAGS = -I$(GNUstep)/include -I. -I.. \
	-fblocks -fobjc-nonfragile-abi $(USER_DEFINES)

LFLAGS = -L$(GNUstep)/lib $(USER_DEFINES) \
	-L../objcp -L../ORFoundation -L../ORUtilities -L../ORModeling \
	-L../CPUKernel -L../ORProgram \
	-lobjcp -lORUtilities -lORFoundation -lORModeling \
	-lCPUKernel -lORProgram \
	-lgnustep-base -lobjc

SRCS = main.m ../ORCmdLineArgs.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(basename $(SRCS)))
EXE = sudoku

all: $(EXE)
	@echo "Done..." $(EXE)

$(EXE):  $(OFILES)
	@echo "Linking $(EXE)"
	@$(OC) $(CFLAGS) $(notdir $(OFILES)) $(LFLAGS) -o $(EXE)

%.$(OBJEXT): %.m
	@echo "Compiling m"  $<
	@$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

