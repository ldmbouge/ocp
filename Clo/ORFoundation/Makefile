#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang
GNUstep = /opt/kitkit-1.0-rc1
CFLAGS = -I$(GNUstep)/include -I. -I.. -fPIC -g -msse4.1 \
	-fblocks -fobjc-nonfragile-abi  $(USER_DEFINES)
LFLAGS = -dynamic -g -L$(GNUstep)/lib -lgnustep-base -lobjc $(USER_DEFINES) \
	-L../ORUtilities \
	-lORUtilities $(USER_DEFINES)

SRCS = context.m   ORAVLTree.m     ORControl.m  OREngine.m     ORExprI.m     \
	ORFoundation.m  ORObject.m     ORSemBDSController.m  ORTracer.m \
	cont.m      ORCommand.m     ORDataI.m    ORError.m      ORFactoryI.m  \
	ORLimit.m       ORParallel.m   ORSemDFSController.m  ORTrailI.m \
	ORArrayI.m  ORController.m  ORData.m     ORExplorerI.m  ORFactory.m  \
	ORSelectorI.m  ORSetI.m ORVisit.m   ORVarI.m ORConstraintI.m \
	ORInterval.mm


OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libORFoundation.so.1 
all: $(LIBNAME)
	@echo "Done..."
	@if [ ! -f $(basename $(LIBNAME)) ];  \
	then \
	  ln -s $(LIBNAME) $(basename $(LIBNAME)); \
	fi

$(LIBNAME): $(OFILES)
	@echo "Linking..." $<
	@$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	@$(OC) $(CFLAGS) -c $< 

%.$(OBJEXT): %.mm
	@echo "compiling C++ / m"  $<
	@$(OC) $(CFLAGS) -ObjC++ -c $< 

clean:
	rm -rf *.o *~

