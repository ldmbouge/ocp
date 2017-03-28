all: $(EXE) ../bin/$(EXE)
	@echo "Done building " $(EXE) "..."

ORCmdLineArgs.m : ../ORCmdLineArgs.m
	cp $< .

$(EXE): $(OFILES) 
#	@echo "Linking " $(EXE)
	$(OC) $(CFLAGS) $(LFLAGS) $(notdir $(OFILES)) -o $(EXE)

../bin/$(EXE): $(EXE)
	@echo "Copy -> bin..." $(EXE)
	@mkdir -p ../bin
	@cp $(EXE) ../bin

%.$(OBJEXT): %.m
#	@echo "compiling m"  $<
	$(OC) $(CFLAGS) -c $< 

%.$(OBJEXT): %.mm
#	@echo "compiling m"  $<
	$(OC) $(CFLAGS) -ObjC++ -c $< 

clean:
	rm -rf *.o *~ ORCmdLineArgs.* $(EXE)  *.d

