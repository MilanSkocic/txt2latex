include ../make.in

BIN=../$(APP_BUILD_DIR)/$(APP_NAME)

all: $(APP_NAME).1.tex version


.PHONY: $(APP_NAME).1.tex
txt2latex.1.tex: 
	$(BIN) -a "User Commands" -t "$(APP_NAME)($(APP_MAN_SEC))" \
		   -I "OPTION" -I "ARGS" -I "FILE" \
		   -B "txt2latex" -B "[A-Za-z0-9]+\\\([0-9]*\\\)" \
		   -M "man -Tpdf" \
		   --man ../docs/txt2latex.1.man > $@

.PHONY: pdf
pdf: $(APP_NAME).1.tex
	mkdir -p build
	pdflatex -output-dir=./build -sync=1 $(APP_NAME).1.tex
	cp -v ./build/$(APP_NAME).1.pdf ./$(APP_NAME).1.pdf

.PHONY: version
version: 
	./test_version

clean:
	rm -rfv ./build/*
	rm -fv $(APP_NAME)*
