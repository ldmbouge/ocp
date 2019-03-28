LOC=../
include $(LOC)setup.make

LFLAGS = `gnustep-config --base-libs` $(USER_DEFINES)  \
	-L../ORUtilities -Wl,-rpath=`pwd`/../ORUtilities -lORUtilities \
	-L../ORFoundation -Wl,-rpath=`pwd`/../ORFoundation -lORFoundation \
	-L../ORModeling -Wl,-rpath=`pwd`/../ORModeling -lORModeling \
	-L../CPUKernel -Wl,-rpath=`pwd`/../CPUKernel -lCPUKernel \
	-L../ORProgram -Wl,-rpath=`pwd`/../ORProgram -lORProgram \
	-L../objcp -Wl,-rpath=`pwd`/../objcp -lobjcp

SRCS = smtlib2utils.c smtlib2termparser.c smtlib2stream.c \
	smtlib2scanner.c smtlib2hashtable.c smtlib2flexlexer.c \
	smtlib2charbuf.c smtlib2bisonparser.c smtlib2abstractparser.c \
	smtlib2vector.c smtlib2objcp.m ExprSimplifier.m objcpgateway.m

OBJEXT=o
OFILES=$(addsuffix .$(OBJEXT),$(notdir $(basename $(SRCS))))
LIBNAME = libVerification.so.1 
all: $(LIBNAME)
	@echo "(Verification) Done... ======================================================================" 
	@if [ ! -f $(basename $(LIBNAME)) ];  \
	then \
	  ln -s $(LIBNAME) $(basename $(LIBNAME)); \
	fi

$(LIBNAME): $(OFILES)
	@echo "Linking..." $^
	$(OC) $(CFLAGS) $(OFILES) $(LFLAGS) --shared  -o $(LIBNAME)

%.$(OBJEXT): %.c
	@echo "compiling c" $(USER_DEFINES) $<
	$(OC) -fPIC -c $< 

%.$(OBJEXT): %.m
	@echo "compiling m" $(USER_DEFINES) $<
	$(OC) $(CFLAGS) -c $< 

clean:
	rm -rf *.o *~

