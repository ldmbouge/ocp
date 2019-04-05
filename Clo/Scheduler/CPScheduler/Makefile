LOC=../../
include $(LOC)setup.make

CFLAGS += -I../../ORFoundation \
	-I../../ORUtilities \
	-I../../objcp \
	-I../../ORModeling \
	-I../../CPUKernel \
	-I../ORScheduler \
	-I../..

LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L../../ORUtilities -Wl,-rpath=`pwd`/../../ORUtilities \
	-L../../ORFoundation -Wl,-rpath=`pwd`/../../ORFoundation \
	-L../../ORModeling -Wl,-rpath=`pwd`/../../ORModeling \
	-L../../CPUKernel -Wl,-rpath=`pwd`/../../CPUKernel \
	-L../../objcp -Wl,-rpath=`pwd`/../../objcp \
	-L../ORScheduler -Wl,-rpath=`pwd`/../ORScheduler \
	-lORUtilities -lORFoundation -lCPUKernel -lobjcp -lORModeling -lORScheduler

SRCS = CPConstraint.m  CPDifference.m   CPFactory.m  CPTaskCumulative.m   CPTaskI.m \
	CPCumulative.m  CPDisjunctive.m  CPMisc.m     CPTaskDisjunctive.m  CPTaskSequence.m \
	CPConcretizer.m


# CPConcretizer.m   ==> Should go in CPScheduler

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libCPScheduler.so.1 

all: $(LIBNAME)
	@echo "(CPScheduler) Done... ======================================================================" 
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

