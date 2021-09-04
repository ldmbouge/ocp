#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang

CFLAGS = `gnustep-config --debug-flags` -fobjc-runtime=gnustep  $(USER_DEFINES) -I. -I.. -msse4.1 -fblocks 
LFLAGS = `gnustep-config --base-libs` -fobjc-runtime=gnustep   $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities -lORUtilities

SRCS = ORAVLTree.m     ORConstraintI.m  ORDataI.m      ORExprI.m       ORFunc.m      ORSelectorI.m         ORTracer.m \
	ORAnnotation.m  ORControl.m      OREngine.m     ORFactory.m     ORLimit.m     ORSemBDSController.m  ORTrailI.m \
	ORArrayI.m      ORController.m   ORError.m      ORFactoryI.m    ORObject.m    ORSemDFSController.m  ORVarI.m \
	ORCommand.m     ORData.m         ORExplorerI.m  ORFoundation.m  ORParallel.m  ORSetI.m              ORVisit.m

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
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m" $<
	$(OC) $(CFLAGS) -c $< 

%.$(OBJEXT): %.mm
	@echo "compiling C++ / m"  $<
	$(OC) $(CFLAGS) -ObjC++ -c $< 

clean:
	rm -rf *.o *~

