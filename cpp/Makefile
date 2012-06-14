OFILES = context.o cont.o DFSController.o CPIVar.o main.o
CFLAGS = -Os -std=c++0x # -gstabs+
LFLAGS = 
CC = /opt/bin/g++
LD = /opt/bin/g++

all: trytest

%.o %.d : %.C
	$(CC) -c -x c++ $(CFLAGS) $< -MD 

trytest: $(OFILES)
	$(LD) -o trytest $(OFILES) $(CFLAGS) $(LFLAGS)

clean:
	rm -rf *.o

include $(addsuffix .d ,$(basename $(OFILES)))
