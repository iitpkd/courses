# Courses taught at IIT Palakkad.

[![Build Staus][travis-status]][travis-courses]

This repository contains details regarding various courses taught at
IIT Palakkad. For a new course, create a markdown file. We suggest
using the naming convention coursecode-hyphenated-title.md, for
example consider `CS3300-Compiler-Design.md`. There is a yaml preamble
for these files that contains meta information like title, code
etc. You can look at the file `cse/cs3300-Compiler-Design.md` as a
sample format.

The fields in the metadata are the following.

1. title: The title of the course (required)
2. code : The course code (required)
3. credits: in L-T-P-C format (required)
4. prereq: List of course codes which are prerequisites. If the course
   does not have a set of prerequisites or it requires a more verbose
   prerequisites like "mathematical maturity" *do not* not have this
   field, instead put it somewhere in the body of the syllabus.
5. consent: Have this field if the instructors consent is required for
   registration (typically for electives).

## Setting up the environment.

You need cabal-install-3.0 or later for building the haskell driver
program. If you are starting with a modern linux distribution, you can
install cabal using the package manager. If the cabal install is older
then perform the following

```
sudo apt install cabal-install # install the platform specific cbal
cabal --version                # check if the version is at least 3.0
# if not then do the following commands.
cabal update
cabal install cabal-install
export PATH="$HOME/.cabal/bin/:$PATH"  # Set up your path appropriately

```
You are now ready to build the course related pdf and other files.

## Building the pdf

The course related information is stored as markdown files with a
metadata header. This needs to be compiled into latex which is
achieved by the haskell program `src/build.hs`. The cabal install
program will take care of building all the dependencies required for
this program.

```
cabal build       # build the driver program.
cabal exec driver # execute the driver program.
cd artefact/latex # move into the directory that contains the tex source.
pdflatex all.tex  # compile it using pdflatex.

```


[travis-status]: <https://secure.travis-ci.org/iitpkd/courses.png> "Build status"
[travis-courses]: <https://travis-ci.org/iitpkd/courses>
