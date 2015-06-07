#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang-3.5
GNUstep = /opt/kitkit-1.0-rc1

CFLAGS = `gnustep-config --objc-flags`  $(USER_DEFINES) -I. -I.. -msse4.1 -fblocks -fobjc-nonfragile-abi
LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities -lORUtilities


# CFLAGS = -I$(GNUstep)/include -I. -I.. -fPIC -g -msse4.1 \
# 	-fblocks -fobjc-nonfragile-abi  $(USER_DEFINES)
# LFLAGS = -dynamic -g -L$(GNUstep)/lib -lgnustep-base -lobjc $(USER_DEFINES) \
# 	-L../ORUtilities \
# 	-lORUtilities $(USER_DEFINES)

SRCS =  ORAVLTree.m     ORControl.m  OREngine.m     ORExprI.m     \
	ORFoundation.m  ORObject.m     ORSemBDSController.m  ORTracer.m \
	ORCommand.m     ORDataI.m    ORError.m      ORFactoryI.m  \
	ORLimit.m       ORParallel.m   ORSemDFSController.m  ORTrailI.m \
	ORArrayI.m  ORController.m  ORData.m     ORExplorerI.m  ORFactory.m  \
	ORSelectorI.m  ORSetI.m ORVisit.m   ORVarI.m ORConstraintI.m \
	ORAnnotation.m


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
	@echo "compiling m" $<
	@$(OC) $(CFLAGS) -c $< 

%.$(OBJEXT): %.mm
	@echo "compiling C++ / m"  $<
	@$(OC) $(CFLAGS) -ObjC++ -c $< 

clean:
	rm -rf *.o *~

