include ../setup.make

CFLAGS += -I../ORFoundation -I../ORUtilities 

LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES) \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation \
	-lORUtilities -lORFoundation

SRCS = ORDecompose.m  ORFlatten.m  ORIntLinear.m  \
	ORRealLinear.m ORRealDecompose.m  \
	ORLPFlatten.m ORLSFlatten.m   ORMIPFlatten.m  \
	ORLinearize.m  ORMIPLinearize.m  \
	ORModelI.m  ORModelTransformation.m ORModeling.m  


OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libORModeling.so.1 

all: $(LIBNAME)
	@echo "(ORModeling) Done... ======================================================================" 
	@if [ ! -f $(basename $(LIBNAME)) ];  \
	then \
	  ln -s $(LIBNAME) $(basename $(LIBNAME)); \
	fi


$(LIBNAME): $(OFILES)
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m" $(USER_DEFINES) $<
	@$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

