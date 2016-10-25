SHELL=/bin/bash
OC = clang
CFL=-g -O0
ifeq ($(findstring -g,$(CFL)),-g)
GSC=`gnustep-config --debug-flags`
else
GSC=`gnustep-config --objc-flags`
endif
USER_DEFINES += $(CFL)

CFLAGS =$(GSC) -msse4.1 -fblocks -fobjc-nonfragile-abi \
	-DUSEVIEWS=1 \
	$(USER_DEFINES) -I. -I.. -I/home/ldm/ocp/gurobi550/linux64/include 

