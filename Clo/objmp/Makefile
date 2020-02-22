include ../setup.make

CFLAGS = `gnustep-config --objc-flags`  $(USER_DEFINES) -I. -I.. \
	-I../ORFoundation -I../ORUtilities -I../CPUKernel \
	-I/opt/gurobi810/linux64/include \
	-msse4.1  -fblocks -fobjc-nonfragile-abi
LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-L/opt/gurobi810/linux64/lib -Wl,-rpath=/opt/gurobi810/linux64/lib \
	-lORUtilities -lORFoundation -lgurobi81


SRCS = LPGurobi.m    LPSolverI.m   MIPGurobi.m   MIPSolverI.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libobjmp.so.1 
all: $(LIBNAME)
	@echo "Done... " 
	@if [ ! -f $(basename $(LIBNAME)) ];  \
	then \
	  ln -s $(LIBNAME) $(basename $(LIBNAME)); \
	fi


$(LIBNAME): $(OFILES)
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

