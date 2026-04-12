include make.in

SRC=$(APP_SRC_DIR)/$(APP_NAME).sh
BIN=$(APP_BUILD_DIR)/$(APP_NAME)
MAN=$(APP_MAN_DIR)/$(APP_MAN_NAME)
MANGZ=$(APP_MAN_DIR)/$(APP_MAN_NAME).gz
HTML=$(APP_MAN_DIR)/$(APP_MAN_NAME).html
PDF=$(APP_MAN_DIR)/$(APP_MAN_NAME).pdf

prefix ?= $(HOME)/.local


all: $(BIN)

.PHONY:
$(BIN): $(SRC)
	mkdir -p build
	cp $< $@
	chmod +x $@

.PHONY:
doc: $(BIN) 
	$(BIN) --help > README
	txt2man -s 1 -t $(APP_NAME) -v "User commands" -r $(APP_VERSION) README > $(MAN)
	man -Thtml -l $(MAN) > $(HTML) 
	gzip -f $(MAN)
	rm -fv docs/$(HTML)
	mv -fv $(HTML) docs/index.html

.PHONY:
show_man: doc
	man $(MANGZ)

.PHONY:
test: $(BIN)
	make -C test

.PHONY:
pdf: test
	make -C test pdf

.PHONY:
install: $(BIN)
	mkdir -p $(DESTDIR)$(prefix)/bin
	mkdir -p $(DESTDIR)$(prefix)/share/man/man$(APP_MAN_SEC)
	cp $(BIN) $(DESTDIR)$(prefix)/bin/
	cp $(MANGZ) $(DESTDIR)$(prefix)/share/man/man$(APP_MAN_SEC)/

.PHONY:
uninstall: $(BIN)
	rm $(DESTDIR)$(prefix)/bin/$(APP_NAME)
	rm $(DESTDIR)$(prefix)/share/man/man$(APP_MAN_SEC)/$(APP_NAME)*

.PHONY:
clean:
	rm -rf $(APP_BUILD_DIR)/*
	make -C test clean
