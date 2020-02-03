######### binaries 
BINS=$(foreach binext, $(BINEXT), $(wildcard *$(binext)))
GENSOURCES=$(foreach binext,$(BINEXT),$(patsubst %$(binext),%.cpp,$(filter %$(binext),$(BINS))))
GENHEADERS=$(subst .cpp,.h,$(GENSOURCES))
SOURCES+= $(GENSOURCES)

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
