TEXGENEXT=aux dvi pdf fdb_latexmk fls log out pdf
SUBDIRS=cse

.PHONY: all clean

export TEXGENEXT

all:
	$(foreach dir, ${SUBDIRS}, make -C ${dir} all; \
		echo > ${dir}.tex; \
		awk ' { printf "\input{${dir}/%s}\n", $$0}' < ${dir}/texindex > ${dir}.tex; \
	)
	latexmk -pdf syllabus.tex
clean:
	$(foreach dir, ${SUBDIRS}, make -C ${dir} clean; )
	rm -f $(addprefix syllabus., ${TEXGENEXT})
