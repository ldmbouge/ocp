OC = clang-3.6

CFLAGS = `gnustep-config --objc-flags`  $(USER_DEFINES) -I. -I.. -fPIC -msse4.1 -fblocks -fobjc-nonfragile-abi
LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES)

SRCS = ORConcurrencyI.m  ORCrFactory.m  ORMallocWatch.m  ORInterval.mm cont.m context.m ORUtilities.m \
	ORPQueue.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libORUtilities.so.1 
#LIBNAME = libORUtilities.a
all: $(LIBNAME)
	@echo "Done...  $(USER_DEFINES)"
	@if [ ! -f $(basename $(LIBNAME)) ];  \
	then \
	  ln -s $(LIBNAME) $(basename $(LIBNAME)); \
	fi

$(LIBNAME): $(OFILES)
	$(OC) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)
#	ar  -cvq $(LIBNAME) $(OFILES)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	$(OC) $(CFLAGS) -c $< 

%.$(OBJEXT): %.mm
	@echo "compiling m"  $<
	$(OC) $(CFLAGS) -ObjC++ -c $< 

clean:
	rm -rf *.o *~

