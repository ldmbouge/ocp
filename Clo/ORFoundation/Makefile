#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = ~/clang32/bin/clang
CFLAGS = -g -I/usr/GNUstep/System/Library/Headers -I.. -I. -I../ORUtilities \
	-fblocks -fobjc-nonfragile-abi 

LFLAGS = -g -L/usr/GNUstep/System/Library/Libraries -L../ORUtilities \
	-lgnustep-base -lobjc \
	-lORUtilities

SRCS = context.m   ORAVLTree.m     ORControl.m  OREngine.m     ORExprI.m     \
	ORFoundation.m  ORObject.m     ORSemBDSController.m  ORTracer.m \
	cont.m      ORCommand.m     ORDataI.m    ORError.m      ORFactoryI.m  \
	ORLimit.m       ORParallel.m   ORSemDFSController.m  ORTrailI.m \
	ORArrayI.m  ORController.m  ORData.m     ORExplorerI.m  ORFactory.m  \
	ORModelI.m      ORSelectorI.m  ORSetI.m              ORVarI.m


OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libORFoundation.so.1 
all: $(LIBNAME)
	@echo "Done..."

$(LIBNAME): $(OFILES)
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	@$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

