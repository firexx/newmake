######### config begin
PROJECTNAME=mytest
TARGETDIR=bin
EXECUTABLE=$(TARGETDIR)/$(PROJECTNAME)
BINEXT=.hex .xsvf
VERBOSITY = 1
# config end


all : build

include bins.mk


SOURCES+=$(sort $(filter-out $(IGNORE_FILES),$(wildcard *.cpp)))
OBJECTS=$(addprefix $(TARGETDIR)/,$(subst .c,.o,$(subst .cpp,.o,$(SOURCES))))


######### debug control
V_AT = $(V_AT_$(V))
V_AT_ = $(V_AT_$(VERBOSITY))
V_AT_0 = @
V_AT_1 =

########## main rules

.PHONY : build
build : compile link
	@echo " =====> build"

compile: $(GENHEADERS) $(GENSOURCES) $(OBJECTS)
	@echo " =====> compile"

link : $(EXECUTABLE) $(DYNAMICLIB) $(STATICLIB)
	@echo " =====> link"

$(EXECUTABLE) : $(OBJECTS)
	@echo " =====> linking an executable $(EXECUTABLE)"
	$(V_AT)$(CXX) -o $@ $(OBJECTS) $(addsuffix /$(TARGETDIR),$(LIBRARY_PATH)) $(EXT_LIBRARY_PATH) $(LDFLAGS)

$(DYNAMICLIB) : $(OBJECTS)

$(STATICLIB) : $(OBJECTS)

######### rules to build
$(TARGETDIR)/%.o : %.cpp
	@echo " =====> compile $< to $@"
	$(V_AT)mkdir -p $(TARGETDIR)
	$(V_AT)$(CXX) $(CXXFLAGS) $< -o $@ -c

#	$(V_AT)$(CXX) -MM $(CXXFLAGS) $< >$(TARGETDIR)/$*.d


######### help rules 
.PHONY: clean
clean::
	@echo " =====> clean"
	$(V_AT)$(RM) -r $(TARGETDIR)



.PHONY : show
show-all:
	@echo " =====> show-all"
	$(foreach var,$(.VARIABLES),$(info $(var) = $($(var))))

SHOWVARS=OBJECTS SOURCES BINS GENSOURCES GENHEADERS

.PHONY: show
show:
	$(foreach var,$(SHOWVARS),$(info $(var) = $($(var))))
