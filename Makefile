include make.in

SRC=$(APP_SRC_DIR)/$(APP_NAME).sh
BIN=$(APP_BUILD_DIR)/$(APP_NAME)
MAN=$(APP_MAN_DIR)/$(APP_MAN_NAME)
MANGZ=$(APP_MAN_DIR)/$(APP_MAN_NAME).gz
HTML=$(APP_MAN_DIR)/$(APP_MAN_NAME).html
PDF=$(APP_MAN_DIR)/$(APP_MAN_NAME).pdf

prefix ?= $(HOME)/.local

.PHONY: clean doc

all: $(BIN)

$(BIN): $(SRC)
	mkdir -p build
	cp $< $@
	chmod +x $@

doc: $(BIN) 
	$(BIN) --help > README
	txt2man -s 1 -t $(APP_NAME) -v "User commands" -r $(APP_VERSION) README > $(MAN)
	man -Thtml -l $(MAN) > $(HTML) 
	gzip -f $(MAN)

docs: doc
	rm -fv docs/$(HTML)
	mv -fv $(HTML) docs/index.html

show_man: doc
	man $(MANGZ)
	
test: $(BIN)
	$(BIN) --version
	$(BIN) --help
	make -C test

install: $(BIN)
	mkdir -p $(DESTDIR)$(prefix)/bin
	mkdir -p $(DESTDIR)$(prefix)/share/man/man$(APP_MAN_SEC)
	cp $(BIN) $(DESTDIR)$(prefix)/bin/
	cp $(MANGZ) $(DESTDIR)$(prefix)/share/man/man$(APP_MAN_SEC)/

uninstall: $(BIN)
	rm $(DESTDIR)$(prefix)/bin/$(APP_NAME)
	rm $(DESTDIR)$(prefix)/share/man/man$(APP_MAN_SEC)/$(APP_NAME)*

clean:
	rm -rf $(APP_BUILD_DIR)/*
	rm -f man/man1/$(APP_NAME)*
