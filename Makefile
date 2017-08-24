TEXGENEXT=aux dvi pdf fdb_latexmk fls log out pdf
COURSELIST=$(wildcard cse/*.md)



.PHONY: all clean course-details.tex

export TEXGENEXT

all: syllabus.tex course-details.tex
	latexmk -pdf syllabus.tex
clean:
	$(foreach dir, ${SUBDIRS}, make -C ${dir} clean; )
	rm -f $(addprefix syllabus., ${TEXGENEXT})
	stack clean
build:
	stack build

course-details.tex: build
	stack exec compilelatex refs ${COURSELIST} > latex.refs
	stack exec compilelatex latex latex.refs ${COURSELIST} > course-details.tex
