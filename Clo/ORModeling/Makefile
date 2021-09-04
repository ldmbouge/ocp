#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang

CFLAGS = `gnustep-config --debug-flags` -fobjc-runtime=gnustep  $(USER_DEFINES) -I. -I.. \
	-I../ORFoundation -I../ORUtilities -msse4.1 \
	-fblocks

LFLAGS = `gnustep-config --base-libs` -fobjc-runtime=gnustep $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-lORUtilities -lORFoundation

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
	$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

