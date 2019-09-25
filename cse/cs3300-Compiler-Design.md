---
title: Compiler Design
code: CS3300
category: PMT
credits: 3-0-0-3
prereq: [CS2200, CS2800]
---

A compiler is program that convert high level (human understandable)
language to low level (machine understandable) code. Compilers are
what makes writing modern software possible and their study has been
one of the classical topics in an Undergraduate Computer Science
curriculum. The objective of the course is to introduce the basic
theory underlying the different components and phases of a compiler
like parsing, code generation etc. Simultaneously, we familiarise the
students to the various tools that are used for building modern
compilers.

# Learning outcome:

At the end of the course we expect the student to know enough of the
theory (Parsing, Code generation, optimisation) and tools (parser
generators, code generators) so that they can build a compiler that
converts from a non-trivial high level language to machine code.


# Syllabus

* Introduction to language translators and overview of the compilation
  process.

* Lexical analysis: specification of tokens, token recognition,
  conflict resolution.

* Parsing: Overview of CFG, Parse trees and derivations, left
  recursion, left factoring, top-down parsing, LALR parsing, conflict
  resolution, dangling-else.

* Syntax directed translation. Semantic analysis, Type checking,
  intermediate code generation.

* Runtime environments: activation records, heap management

* Code optimization: basic blocks, liveness, register allocation.

* Advanced topics: Overview of machine dependent and independent optimizations.


# Textbook(s)

1. Compilers: Principles, Techniques, and Tools, Alfred Aho, Monica
   Lam, Ravi Sethi, Jeffrey D. Ullman, Addison-Wesley, 2007

2. [Modern Compiler Implementation in ML][appel], Andrew W Appel,
   Cambridge University Press.  [ISBN 0 521 58274 1][isbn-hard]
   (hardback) ISBN 0 521 58274 1

3. Compiler Construction: Principles and Practice, 1st Edition,
   Kenneth C. Louden, Cengage Learning; 1 edition (January 24, 1997),
   ISBN-13: 978-0534939724


Websites of some previous offerings of this course.

1. [July-December, 2017](https://bitbucket.org/piyush-kurur/compilers)

[appel]: <https://www.cs.princeton.edu/~appel/modern/ml/>
[isbn-hard]: <http://www.worldcat.org/isbn/0521582741>
