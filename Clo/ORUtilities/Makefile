#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang
GNUstep = /opt/kitkit-1.0-rc1
CFLAGS = -I$(GNUstep)/include -I. -I.. \
	-fblocks -fobjc-nonfragile-abi  $(USER_DEFINES)
LFLAGS = -dynamic -g -L$(GNUstep)/lib -lgnustep-base -lobjc $(USER_DEFINES)

SRCS = ORConcurrencyI.m  ORCrFactory.m  ORMallocWatch.m  ORUtilities.m

#	./NSBoardController.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libORUtilities.so.1 
#LIBNAME = libORUtilities.a
all: $(LIBNAME)
	@echo "Done..."
	@if [ ! -f $(basename $(LIBNAME)) ];  \
	then \
	  ln -s $(LIBNAME) $(basename $(LIBNAME)); \
	fi

$(LIBNAME): $(OFILES)
	@$(OC) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)
#	ar  -cvq $(LIBNAME) $(OFILES)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	@$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

