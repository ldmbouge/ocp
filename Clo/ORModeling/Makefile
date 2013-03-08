#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = ~/clang32/bin/clang
CFLAGS = -I/usr/GNUstep/System/Library/Headers -I.. -I. \
	-fblocks -fobjc-nonfragile-abi $(USER_DEFINES)

LFLAGS = -L/usr/GNUstep/System/Library/Libraries $(USER_DEFINES) \
	-L../ORUtilities -L../ORFoundation \
	-lORUtilities -lORFoundation \
	-lgnustep-base -lobjc 	
SRCS = ORDecompose.m  ORFlatten.m  ORLinearize.m  ORLinear.m  ORLPDecompose.m  \
	ORLPFlatten.m  ORModelI.m  ORModeling.m  ORModelTransformation.m


OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libORModeling.so.1 
all: $(LIBNAME)
	@echo "Done..."

$(LIBNAME): $(OFILES)
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	@$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

