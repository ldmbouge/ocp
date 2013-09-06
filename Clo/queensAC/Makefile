#GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
#include $(GNUSTEP_MAKEFILES)/common.make

OC = clang
CFLAGS = -g -I/usr/GNUstep/System/Library/Headers -I. -I../objcp -fblocks -fobjc-nonfragile-abi -msse4.1 
LFLAGS = -g -L../objcp -lobjcp `/usr/GNUstep/System/Tools/gnustep-config --base-libs`  -L../objcp \
	-lobjcp 
SRCS = main.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libobjcp.so.1 
EXE = queensAC

all: $(EXE)
	@echo "Done..."

$(EXE): $(OFILES) ../objcp/libobjcp.so.1
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) -o $(EXE)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	@$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

