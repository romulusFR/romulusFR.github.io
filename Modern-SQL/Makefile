METADATA=./meta.yaml 
PANDOC=pandoc --metadata-file=$(METADATA)

all: Modern-SQL.pdf
# Modern-SQL.html

Modern-SQL.pdf: Modern-SQL.md $(METADATA)
	$(PANDOC) --to=pdf --number-sections --shift-heading-level-by=-1 --pdf-engine=pdflatex -o $@ $<

Modern-SQL.html: Modern-SQL.md $(METADATA)
	$(PANDOC) --to=html --number-sections --shift-heading-level-by=-1 -o $@ $<
