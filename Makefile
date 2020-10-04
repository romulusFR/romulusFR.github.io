PUBLISHSRV=rthion@connect.liris.cnrs.fr
PUBLISHPATH=/home-membres/rthion/files/

all: CV.pdf index.html

CV.pdf: CV.tex
	rubber -v --warn all --force --pdf $<

index.html: CV.tex
	pandoc --self-contained -f latex -t html5 -o $@ --metadata pagetitle="Curriculum Vitae - Romuald THION" --css=./cv.css $<

clean:
	rm -f *.aux *.log *.out *~ 
