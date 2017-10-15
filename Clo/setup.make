SHELL=/bin/bash
OC = clang-3.6  # clang 3.8 is broken. Code crashes before startup.
CFL=-g
ifeq ($(findstring -g,$(CFL)),-g)
GSC=`gnustep-config --debug-flags`
else
GSC=`gnustep-config --objc-flags`
endif
USER_DEFINES += $(CFL)

CFLAGS =$(GSC) -msse4.1 -fblocks -fobjc-nonfragile-abi \
	-DUSEVIEWS=1 \
	$(USER_DEFINES) -I. -I.. -I../Scheduler 

