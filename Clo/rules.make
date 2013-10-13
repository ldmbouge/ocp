all: $(EXE)
	@echo "Done building " $(EXE) "..."

ORCmdLineArgs.m : ../ORCmdLineArgs.m
	cp $< .

$(EXE): $(OFILES) 
	@echo "Linking " $(EXE)
	$(OC) $(CFLAGS) $(notdir $(OFILES)) $(LFLAGS) -o $(EXE)

%.$(OBJEXT): %.m
	@echo "compiling m"  $<
	$(OC) $(CFLAGS) -c $< 

%.$(OBJEXT): %.mm
	@echo "compiling m"  $<
	$(OC) $(CFLAGS) -ObjC++ -c $< 

clean:
	rm -rf *.o *~ ORCmdLineArgs.* $(EXE)  *.d
	
