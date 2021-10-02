---
Date: 2021-10-01
Title: "A one year retrospective on Minim"
Last: 2021-10-01
Tags: minim
---

September 20th marked the one year anniversary of Minim's creation.
It initially started as an pandemic-fueled side project based on
  an online guide of making a small Lisp language.
Since then, Minim has undergone significant changes in design
  and scope.
Today Minim is a fully-interpreted language, complete with a small
  standard library, syntax macros (not quite R6RS compliant),
  and many more features.

#### The Early Days

The initial versions of Minim were hacky at best.
The goal of development during Minim 0.1.x was expanding
  the number of available types.
By version 0.1.2, the language supported booleans, exact
  and inexact numbers, symbols, strings, pairs, lists,
  user-defined functions, hash tables, vectors,
  and sequences.
Nearly all of these types since then have undergone
  structural changes since then.
The set of procedures to create and modify these
  procedures was minimal at the time, just enough
  to be useful.

The worst feature of this era was the owner-reference
  system in order to know when to free objects when they
  went out of scope.
Initially, new copied were created every time they were
  referenced, but with an "improvement", objects
  could be set as owners of their data of references
  of another object's data.
This required unnecessary amounts of copying objects when,
  annoying equality checks, and hours of debugging
  segmentation faults.
What I didn't know at the time was Scheme implementations
  usually never copy immutable objects and use
  garbage collectors to know when to free memory.
This issue was not fixed until I finally added my own
  garbage collector in version 0.3.0.

#### Expansion

With a plethora of types in the language, the focus for
  Minim 0.2.x shifted to increasing the number of
  procedures available.
First, file reading was added to support a standard
  library that was not hard-coded in C.
In these versions, file reading occured separately
  from the existing parser, tracking parentheses
  and ignoring comments to extract a hopefully
  parsable string.
Initially, reading source code was rough
  since the reader would spontaneously fail, leading
  to hours of searching for and fixing bugs, and often
  to my frustration, the creation of new bugs.
In the same release, I added errors with backtracing
  and syntax with source locations which proved to be
  helpful in the future with debugging.

Minim 0.2.1 and 0.2.2 were expansions of the math
  and list libraries.
I put as many of the new procedures to the standard
  library as I could rather to the already large
  set of primitive procedures.
I also added arity and type errors so that these new
  procedures could reject arguments upfront and
  print a more descriptive error.
By then, issues with parsing motivated me to remake the
  parser from scratch which turned out to be a huge
  improvement for the language.
Since then the parser has barely changed and no longer
  hinders development.

#### Standardization and Maturation

Development of Minim 0.3.x felt quite different from the
  previous versions.
Primarily, I began reading the existing standards on Scheme
  including R4RS, R5RS, and R6RS.
For the most part, I ignored these standards before because
  I wasn't interested in sticking to an existing blueprint
  for Minim.
However, my design choices began to feel flawed and haphazard
  and the way forward was becoming unclear.
Implementing procedures and features described in the standards
  became the main goal during this era of development.

The first few changes were performance-related changes: the
  addition of a garbage collector and the implementation
  of tail calling.
I detailed the design of the garbage collector in
  my previous blog post which you can read [here](./2021-07-14-minim-gc.html).
These changes caused a significant slow down in performance,
  but accelerated the pace of development since I didn't have to
  worry about memory management, aside from a few bugs that
  needed patching.

With garbage collection in place, I turned to important features
  of any Scheme language: quoting and syntax macros.
Quoting in Minim is handled within the C layer rather than
  the standard library like Racket.
The first attempt at syntax macros was extremely hacky,
  not hygenic, and really broken (although I didn't know
  it at the time).

I moved on to exporting symbols and importing files
  which was an interesting experience trying
  to implement.
Perhaps I will mention the design for that in a future post.
I continued to add more features from the standards:
  characters, additional string procedures,
  multi-valued expressions, additional list functions,
  and more.
All was going smoothly until I began implementing SRFI
  features like `case-lambda` and records.
  


Following the Scheme standards made Minim a much more robust and
  sensical language and taught me that standards are an important
  part of language design.

#### The Future
