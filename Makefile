all: CV.pdf index.html

CV.pdf: CV.tex
	rubber -v --warn all --force --pdf $<

CV.html: CV.tex
	pandoc --self-contained -f latex -t html5 -o $@ --metadata pagetitle="Curriculum Vitae - Romuald THION" --css=./cv.css $<

index.html: index.tex
	pandoc --self-contained -f latex -t html5 -o $@ --metadata pagetitle="Page personnelle - Romuald THION" --css=./cv.css $<

clean:
	rm -f *.aux *.log *.out *~ 
