include ../make.in

BIN=../$(APP_BUILD_DIR)/$(APP_NAME)

all: $(APP_NAME).1.tex


.PHONY: $(APP_NAME).1.tex
txt2latex.1.tex: 
	$(BIN) --help | $(BIN) -a "User Commands" -t "$(APP_NAME)($(APP_MAN_SEC))" \
		   -I "OPTION" -I "ARGS" -I "FILE" \
		   -B "txt2latex" -B "txt2man(1)" --man > $@

.PHONY: pdf
pdf: $(APP_NAME).1.tex
	mkdir -p build
	pdflatex -output-dir=./build -sync=1 $(APP_NAME).1.tex
	cp -v ./build/$(APP_NAME).1.pdf ./$(APP_NAME).1.pdf

clean:
	rm -rfv ./build/*
	rm -fv $(APP_NAME)*
