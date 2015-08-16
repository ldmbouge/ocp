#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang-3.5

CFLAGS = `gnustep-config --objc-flags`  $(USER_DEFINES) -I. -I.. \
	-I../ORFoundation -I../ORUtilities -msse4.1 \
	-fblocks -fobjc-nonfragile-abi -DUSEVIEWS=1

LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-lORUtilities -lORFoundation

# CFLAGS = -I$(GNUstep)/include -I.. -I. -fPIC -g -msse4.1 \
# 	-I../ORFoundation -I../ORUtilities \
# 	-fblocks -fobjc-nonfragile-abi $(USER_DEFINES)
# LFLAGS = -L$(GNUstep)/lib $(USER_DEFINES) \
# 	-L../ORUtilities -L../ORFoundation \
# 	-lORUtilities -lORFoundation \
# 	-lgnustep-base -lobjc 	
SRCS = ORDecompose.m  ORFlatten.m  ORLinearize.m  ORIntLinear.m  \
	ORFloatLinear.m ORFloatDecompose.m  \
	ORLPFlatten.m  ORModelI.m  ORModeling.m  ORModelTransformation.m \
	ORMIPLinearize.m ORMIPFlatten.m ORLSFlatten.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libORModeling.so.1 

all: $(LIBNAME)
	@echo "Done..."
	@if [ ! -f $(basename $(LIBNAME)) ];  \
	then \
	  ln -s $(LIBNAME) $(basename $(LIBNAME)); \
	fi


$(LIBNAME): $(OFILES)
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) -g --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	@$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

