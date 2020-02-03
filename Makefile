######### config begin
PROJECTNAME=mytest
TARGETDIR=bin
EXECUTABLE=$(TARGETDIR)/$(PROJECTNAME)
BINEXT=.hex .xsvf
VERBOSITY = 1
# config end



SOURCES=$(sort $(filter-out $(IGNORE_FILES),$(wildcard *.cpp)))
OBJECTS=$(addprefix $(TARGETDIR)/,$(subst .c,.o,$(subst .cpp,.o,$(SOURCES))))

BINS=$(foreach binext, $(BINEXT), $(wildcard *$(binext)))
GENSOURCES=$(foreach binext,$(BINEXT),$(patsubst %$(binext),%.cpp,$(filter %$(binext),$(BINS))))
GENHEADERS=$(subst .cpp,.h,$(GENSOURCES))
SOURCES+= $(GENSOURCES)

all : build

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

######### binaries 

clean::
	$(V_AT)$(RM) $(GENSOURCES) $(GENHEADERS)

######### binary convertion ################

define BIN_CONVERT_H= 
	@echo "#ifndef __$(shell basename $@ .h | tr a-z A-Z )_H__" > $@      
	@echo "#define __$(shell basename $@ .h | tr a-z A-Z )_H__" >> $@     
	@echo >> $@                                                           
	@echo "extern size_t $(shell basename $@ .h)_size;">> $@ 
	@echo "extern unsigned char $(shell basename $@ .h)[];" >> $@             
	@echo >> $@                                                           
	@echo "#endif" >> $@                                                  
	@echo  >> $@                                   
endef

define BIN_CONVERT_C=
	@echo "#include \"StdAfx.h\""> $@      
	@echo "#include \"$(shell basename $@ .cpp).h\"" >> $@
	@echo >> $@                                                           
	@echo "size_t $(shell basename $@ .cpp)_size=$(shell stat -L -c '%s' $< );">> $@ 
	@echo "unsigned char $(shell basename $@ .cpp)[] = {" >> $@             
	@xxd -i < $< >> $@                                                    
	@echo "};" >> $@                                                      
	@echo >> $@                                                           
endef

%.h: %.hex
	@echo " =====> convert $< to $@"
	$(V_AT)$(BIN_CONVERT_H)

%.h: %.xsvf
	@echo " =====> convert $< to $@"
	$(V_AT)$(BIN_CONVERT_H)

%.cpp : %.hex
	@echo " =====> convert $< to $@"
	$(V_AT)$(BIN_CONVERT_C)

%.cpp : %.xsvf
	@echo " =====> convert $< to $@"
	$(V_AT)$(BIN_CONVERT_C)
