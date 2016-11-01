include ../../setup.make

CFLAGS += -I../../ORFoundation \
	-I../../ORUtilities \
	-I../../objcp \
	-I../../ORModeling \
	-I../../CPUKernel \
	-I../ORScheduler \
	-I../CPScheduler \
	-I../..

LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L../../ORUtilities -Wl,-rpath=`pwd`/../../ORUtilities \
	-L../../ORFoundation -Wl,-rpath=`pwd`/../../ORFoundation \
	-L../../ORModeling -Wl,-rpath=`pwd`/../../ORModeling \
	-L../../CPUKernel -Wl,-rpath=`pwd`/../../CPUKernel \
	-L../../objcp -Wl,-rpath=`pwd`/../../objcp \
	-L../ORScheduler -Wl,-rpath=`pwd`/../ORScheduler \
	-L../CPScheduler -Wl,-rpath=`pwd`/../CPScheduler \
	-lORUtilities -lORFoundation -lCPUKernel -lobjcp -lORModeling -lORScheduler -lCPScheduler

SRCS = ORSchedulingProgram.m

# CPConcretizer.m   ==> Should go in CPScheduler

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libORSchedulerProgram.so.1 

all: $(LIBNAME)
	@echo "(ORSchedulerProgram) Done... ======================================================================" 
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

