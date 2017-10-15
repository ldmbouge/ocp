CFL=-O2
USER_DEFINES=$(CFL)
include ../common.make
SRCS = main.m Cnode.m  SecurityTech.m  Service.m  XMLReader.m 
EXE  = comcast
include ../rules.make

test: comcast
	./comcast model2.xml LNS -print -time240000
