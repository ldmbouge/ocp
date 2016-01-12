include ../setup.make

CFLAGS +=  -I../ORFoundation -I../ORUtilities 

LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-lORUtilities -lORFoundation

SRCS = CPConstraintI.m  CPEngineI.m  CPGroup.m  CPTrigger.m  CPTypes.m  CPUKernel.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libCPUKernel.so.1 
all: $(LIBNAME)
	@echo "(CPUKernel) Done... ======================================================================" 
	@if [ ! -f $(basename $(LIBNAME)) ];  \
	then \
	  ln -s $(LIBNAME) $(basename $(LIBNAME)); \
	fi

$(LIBNAME): $(OFILES)
	@$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m"  $(USER_DEFINES) $<
	@$(OC) $(CFLAGS) -c $< 

clean:
	@rm -rf *.o *~

