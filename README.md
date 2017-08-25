# Courses taught at IIT Palakkad.

This repository contains details regarding various courses taught at
IIT Palakkad. For a new course, create a markdown file. We suggest
using the naming convention coursecode-hyphenated-title.md, for
example consider `cs3300-Compiler-Design.md`. There is a yaml preamble
for these files that contains meta information like title, code
etc. You can look at the file `cse/cs3300-Compiler-Design.md` as a
sample format.


## Setting up the environment.

The dependencies for building the pdf document are the following

- make
- latex
- latexmk
- curl


I would recommend using a modern linux distribution say Debian or
Ubuntu where pre-build packages are available for al these programs.
The driver script is a small haskell program that uses the pandoc
library. It is best to use [haskell stack][stack] to build it. If you
do not have [haskell stack][stack] around you can install it with the
command

```
make install-stack

```

You might need super user permissions for this and a suitable
system. It should work with reasonable Unix systems
(Debian/Ubuntu/CentOS) etc.

This is a one time job and _do not_ need to be repeated where ever you
change the contents of courses or add new courses.


## Building the pdf


The pdf file can be built by typing the following command.


```
make

```
If you need to add a new course to the list edit the variable
`COURSELIST` in the `Makefile`. You can use wild card patterns as
well.

[stack]: <https://docs.haskellstack.org/> "The haskell stack"
