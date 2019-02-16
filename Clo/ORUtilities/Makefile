LOC=../
include $(LOC)setup.make

LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES)

SRCS = ORConcurrencyI.m  ORCrFactory.m  ORMallocWatch.m  ORInterval.mm cont.m context.m ORUtilities.m \
	ORPQueue.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libORUtilities.so.1 
#LIBNAME = libORUtilities.a
all: $(LIBNAME)
	@echo "(ORUtilities) Done... ======================================================================" 
	@if [ ! -f $(basename $(LIBNAME)) ];  \
	then \
	  ln -s $(LIBNAME) $(basename $(LIBNAME)); \
	fi

$(LIBNAME): $(OFILES)
	$(OC) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)
#	ar  -cvq $(LIBNAME) $(OFILES)

%.$(OBJEXT): %.m
	@echo "compiling m" $(USER_DEFINES) $<
	$(OC) $(CFLAGS) -c $< 

%.$(OBJEXT): %.mm
	@echo "compiling m++"  $(USER_DEFINES) $<
	$(OC) $(CFLAGS) -ObjC++ -c $< 

clean:
	rm -rf *.o *~

