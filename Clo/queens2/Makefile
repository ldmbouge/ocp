OC = clang
GNUstep = /opt/kitkit-1.0-rc1

CFLAGS = -I$(GNUstep)/include -I. -I.. \
	-fblocks -fobjc-nonfragile-abi -msse4.1 $(USER_DEFINES)

LFLAGS = -L$(GNUstep)/lib $(USER_DEFINES) \
	-L../objcp -L../ORFoundation -L../ORUtilities -L../ORModeling \
	-L../CPUKernel -L../ORProgram \
	-lobjcp -lORUtilities -lORFoundation -lORModeling \
	-lCPUKernel -lORProgram \
	-lgnustep-base -lobjc

SRCS = main.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libobjcp.so.1 
EXE = queens2

all: $(EXE)
	@echo "Done" $(EXE) " ..."

$(EXE): $(OFILES) ../objcp/libobjcp.so.1
	@$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) -o $(EXE)

%.$(OBJEXT): %.m
	@echo "Compiling m"  $<
	@$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~ $(EXE)

