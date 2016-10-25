include ../setup.make

LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES)  \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities -lORUtilities

SRCS =  ORAVLTree.m     ORControl.m  OREngine.m     ORExprI.m     \
	ORFoundation.m  ORObject.m     ORSemBDSController.m  ORSemFDSController.m ORTracer.m \
	ORCommand.m     ORDataI.m    ORError.m      ORFactoryI.m  \
	ORLimit.m       ORParallel.m   ORSemDFSController.m  ORTrailI.m \
	ORArrayI.m  ORController.m  ORData.m     ORExplorerI.m  ORFactory.m  \
	ORSelectorI.m  ORSetI.m ORVisit.m   ORVarI.m ORConstraintI.m \
	ORAnnotation.m ORParameterI.m ORBackjumpingDFSController.m


OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libORFoundation.so.1 
all: $(LIBNAME)
	@echo "(ORFoundation) Done... ======================================================================" 
	@if [ ! -f $(basename $(LIBNAME)) ];  \
	then \
	  ln -s $(LIBNAME) $(basename $(LIBNAME)); \
	fi

$(LIBNAME): $(OFILES)
	@echo "Linking..." $<
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m" $(USER_DEFINES) $<
	$(OC) $(CFLAGS) -c $< 

%.$(OBJEXT): %.mm
	@echo "compiling C++ / m"  $<
	$(OC) $(CFLAGS) -ObjC++ -c $< 

clean:
	rm -rf *.o *~

