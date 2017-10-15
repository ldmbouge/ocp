include ../setup.make

LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES)  \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities -lORUtilities

SRCS = ORError.m  ORObject.m ORAVLTree.m ORFactoryI.m ORSetI.m  ORFunc.m OREngine.m \
	ORTrailI.m ORCommand.m ORFoundation.m ORTracer.m  ORVisit.m   ORParameterI.m \
	ORData.m ORDataI.m ORExprI.m  ORArrayI.m ORVarI.m  \
	ORAnnotation.m ORSelectorI.m \
	ORConstraintI.m ORFactory.m \
	ORControl.m ORLimit.m  ORParallel.m ORController.m ORExplorerI.m  \
	ORSemDFSController.m ORSemBDSController.m  ORSemFDSController.m ORSemBFSController.m ORBackjumpingDFSController.m


# ORAVLTree.m
# ORAnnotation.m
# ORArrayI.m
# ORBackjumpingDFSController.m
# ORCommand.m
# ORConstraintI.m
# ORControl.m
# ORController.m
# ORData.m
# ORDataI.m
# OREngine.m
# ORError.m
# ORExplorerI.m
# ORExprEval.m
# ORExprI.m
# ORFactory.m
# ORFactoryI.m
# ORFoundation.m
# ORFunc.m
# ORLimit.m
# ORObject.m
# ORParallel.m
# ORParameterI.m
# ORSelectorI.m
# ORSemBDSController.m
# ORSemBFSController.m
# ORSemDFSController.m
# ORSemFDSController.m
# ORSetI.m
# ORTracer.m
# ORTrailI.m
# ORVarI.m
# ORVisit.m


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
	@echo "Linking..." $^
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.m
	@echo "compiling m" $(USER_DEFINES) $<
	$(OC) $(CFLAGS) -c $< 

%.$(OBJEXT): %.mm
	@echo "compiling C++ / m"  $<
	$(OC) $(CFLAGS) -ObjC++ -c $< 

clean:
	rm -rf *.o *~

