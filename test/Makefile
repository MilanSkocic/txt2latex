all: out.tex

out.tex:
	chmod +x ./runtest
	./runtest

pdf: dout.pdf

dout.pdf: dout.tex
	pdflatex dout.tex

clean:
	rm -fv out.tex dout*.*
