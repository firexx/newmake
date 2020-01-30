#config begin
PROJECTNAME=mytest
EXECUTABLE=$(PROJECTNAME)
# config end

TARGETDIR=bin
SOURCES=$(sort $(filter-out $(GENSOURCES),$(filter-out $(IGNORE_FILES),$(wildcard *.cpp))))
OBJECTS=$(addprefix $(TARGETDIR)/,$(subst .c,.o,$(subst .cpp,.o,$(SOURCES))))
BINS+=$(sort $(filter-out $(IGNORE_FILES),$(wildcard *.hex)))
BINS+=$(sort $(filter-out $(IGNORE_FILES),$(wildcard *.xsvf)))
GENSOURCES=$(subst .xsvf,.cpp, $(subst .hex,.cpp,$(BINS)))
GENHEADERS=$(subst .xsvf,.h, $(subst .hex,.h,$(BINS)))
SOURCES += $(GENSOURCES)

all : build
	@echo " =====> all"

.PHONY : show
show:
	@echo " =====> show"
	$(foreach var,$(.VARIABLES),$(info $(var) = $($(var))))

.PHONY : clean
clean:
	@echo " =====> clean"
	$(RM) -r $(TARGETDIR) $(GENSOURCES) $(GENHEADERS)

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

# rules to build
$(TARGETDIR)/%.o : %.cpp
	@echo " =====> compile $< to $@"
	$(V_AT)mkdir -p $(TARGETDIR)
	$(V_AT)$(CXX) $(CXXFLAGS) $< -o $@ -c

#	$(V_AT)$(CXX) -MM $(CXXFLAGS) $< >$(TARGETDIR)/$*.d

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
