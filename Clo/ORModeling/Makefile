#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang
GNUstep = /opt/kitkit-1.0-rc1

CFLAGS = -I$(GNUstep)/include -I.. -I. -fPIC -g -msse4.1 \
	-I../ORFoundation -I../ORUtilities \
	-fblocks -fobjc-nonfragile-abi $(USER_DEFINES)


LFLAGS = -L$(GNUstep)/lib $(USER_DEFINES) \
	-L../ORUtilities -L../ORFoundation \
	-lORUtilities -lORFoundation \
	-lgnustep-base -lobjc 	
SRCS = ORDecompose.m  ORFlatten.m  ORLinearize.m  ORIntLinear.m  \
	ORFloatLinear.m ORFloatDecompose.m  \
	ORLPFlatten.m  ORModelI.m  ORModeling.m  ORModelTransformation.m \
	ORMIPLinearize.m ORMIPFlatten.m 

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

