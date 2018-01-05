GENERATED=pdf fdb_latexmk fls log aux out tex toc
.PHONY: clean all tarball

%.tex : %.org
	emacs $< --batch -f org-latex-export-to-latex --kill

%.pdf: %.tex
	latexmk -pdf $<

.DEFAULT_GOAL = all
all: working.pdf

clean:
	rm -f $(addprefix working., ${GENERATED})
