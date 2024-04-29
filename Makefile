all: index.html

index.html: index.tex
	pandoc --embed-resources --standalone --from latex --to html5 --output $@ --metadata pagetitle="Page personnelle - Romuald THION" --css=./cv.css $<


CV.pdf: CV.tex
	latexmk -v --warn all --force --pdf $<

CV.html: CV.tex
	pandoc --self-contained -f latex -t html5 -o $@ --metadata pagetitle="Curriculum Vitae - Romuald THION" --css=./cv.css $<


clean:
	latexmk -c
	rm -f *.aux *.log *.out *~ 
