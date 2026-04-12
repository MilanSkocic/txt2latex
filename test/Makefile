all: t002.txt out.tex

t002.txt:
	../build/txt2latex --help > $@

out.tex:
	chmod +x ./runtest
	./runtest

pdf: out.tex
	pdflatex t001.txt_doc.tex
	pdflatex t002.txt_doc.tex

clean:
	rm -fv *.pdf *.txt.tex *.txt_doc.*
