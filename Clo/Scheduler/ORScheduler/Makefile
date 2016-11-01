include ../../setup.make

CFLAGS += -I../../ORFoundation \
	-I../../ORUtilities \
	-I../../objcp \
	-I../../ORModeling \
	-I../../CPUKernel \
	-I../..

LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L../../ORUtilities -Wl,-rpath=`pwd`/../../ORUtilities \
	-L../../ORFoundation -Wl,-rpath=`pwd`/../../ORFoundation \
	-L../../ORModeling -Wl,-rpath=`pwd`/../../ORModeling \
	-L../../CPUKernel -Wl,-rpath=`pwd`/../../CPUKernel \
	-L../../objcp -Wl,-rpath=`pwd`/../../objcp \
	-lORUtilities -lORFoundation -lCPUKernel -lobjcp -lORModeling

SRCS = ORActivity.m  ORConstraintI.m  ORFlatten.m  \
	ORSchedFactory.m  ORSchedLinearize.m  ORTaskI.m  ORVisit.m

# CPConcretizer.m   ==> Should go in CPScheduler

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libORScheduler.so.1 

all: $(LIBNAME)
	@echo "(ORScheduler) Done... ======================================================================" 
	@if [ ! -f $(basename $(LIBNAME)) ];  \
	then \
	  ln -s $(LIBNAME) $(basename $(LIBNAME)); \
	fi


$(LIBNAME): $(OFILES)
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m" $(USER_DEFINES) $<
	$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

