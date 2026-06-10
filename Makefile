include make.in

SRC=$(APP_SRC_DIR)/$(APP_NAME).sh
BIN=$(APP_BUILD_DIR)/$(APP_NAME)

MAN=$(APP_MAN_DIR)/$(APP_MAN_NAME)
MANGZ=$(APP_MAN_DIR)/$(APP_MAN_NAME).gz
PDF=$(APP_MAN_DIR)/$(APP_MAN_NAME).pdf
TXT=$(APP_MAN_DIR)/$(APP_MAN_NAME).txt
HTML=$(APP_MAN_DIR)/$(APP_MAN_NAME).html

prefix ?= $(HOME)/.local

all: $(BIN)

.PHONY: $(BIN)
$(BIN): $(SRC)
	mkdir -p build
	cp $< $@
	chmod +x $@

.PHONY: docs
docs:
	txt2man -s 1 -t $(APP_NAME) -v "User commands" -r $(APP_VERSION) $(MAN).man > $(MAN)
	man -Thtml -l $(MAN) > $(HTML) 
	gzip -k -f $(MAN)
	man -Tpdf -l $(MAN) > $(PDF) 
	man -l $(MAN) > $(TXT) 

.PHONY: test
test: $(BIN)
	make -C test

.PHONY:
testpdf: test
	make -C test pdf

.PHONY: install
install: $(BIN)
	mkdir -p $(DESTDIR)$(prefix)/bin
	mkdir -p $(DESTDIR)$(prefix)/share/man/man$(APP_MAN_SEC)
	cp $(BIN) $(DESTDIR)$(prefix)/bin/
	cp $(MANGZ) $(DESTDIR)$(prefix)/share/man/man$(APP_MAN_SEC)/

.PHONY: uninstall
uninstall: $(BIN)
	rm $(DESTDIR)$(prefix)/bin/$(APP_NAME)
	rm $(DESTDIR)$(prefix)/share/man/man$(APP_MAN_SEC)/$(APP_NAME)*

.PHONY: clean
clean:
	rm -rf $(APP_BUILD_DIR)/*
