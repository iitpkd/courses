# Give the list of courses for inclusion here.
COURSES= cs3300-Compiler-Design \


###################################################################
#   From now own these are things that are for developers.  These #
#   should be edited only if you know what you are doing.         #
###################################################################

TEXSOURCES=$(addsuffix .tex, ${COURSES})



.PHONY: all clean

%.tex: %.md
	pandoc $< -o $@

all: ${TEXSOURCES}
	cat /dev/null > texindex
	$(foreach file, ${COURSES}, echo ${file} >> texindex;)

clean:
	rm -f ${TEXSOURCES}
	rm -f $(foreach ext, ${TEXGENEXT}, $(addsuffix .${ext}, ${COURSES}))
