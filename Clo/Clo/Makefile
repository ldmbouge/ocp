CFLAGS= -Os 
CC = clang
LD = clang
OFILES= SillyVar.o rectest.o
LFLAGS= -framework Foundation

all: rectest

%.o %.d : %.m
	$(CC) -c -x objective-c $(CFLAGS) $< -MD 

rectest: $(OFILES)
	$(LD) -o rectest $(OFILES) $(CFLAGS) $(LFLAGS)

clean:
	rm -rf *.o *.d *~ rectest

include $(addsuffix .d ,$(basename $(OFILES)))
