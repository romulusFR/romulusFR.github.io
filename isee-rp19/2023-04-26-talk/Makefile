SLIDES = talk.html
METADATA = meta.yaml
PANDOC = pandoc --metadata-file=$(METADATA)
HTML_OPT = --mathjax --standalone --slide-level=3 -V theme:"solarized"

$(SLIDES): %.html : %.md $(METADATA)
	$(PANDOC) --to=revealjs  $(HTML_OPT) -o $@ $<
