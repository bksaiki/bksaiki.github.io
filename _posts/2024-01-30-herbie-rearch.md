---
layout: posts
title: "Rearchitecting Herbie's improvement loop"
date: 2024-01-30
last_modified: 2024-01-30
categories: blog herbie
---

Herbie's improvement loop has five basic phases:

1. Expression selection
2. Local error analysis
3. Rewriting
    <ol type="a">
    <li>Taylor polynomial approximation ("taylor")</li>
    <li>rule-based rewriting ("rr")</li>
    </ol>
4. Simplify
5. Prune

First,
  Herbie selects a few expressions (1) from
  its database as a starting point for rewriting.
Then, 
  it analyzes (2) the expression to find AST nodes
  that exhibit high local error.
Based on the analysis,
  the tool utilizes a couple rewriting techniques
  including polynomial approximation and equality saturation
  via the [egg](https://egraphs-good.github.io/) library.
Finally,
  a second rewriting pass simplifies expressions using egg
  before merging the new expressions with the current set
  of alternative implementations, keeping only the best.

This sequential process is repeated for a fixed number
  of iterations before Herbie extracts and fuses expressions
  through an algorithm called regime inference.
All versions of Herbie utilize this architecture
  in one way or another.
In the last couple versions of the tool,
  I have noticed a tension building between
  the rewriting phases within the improve loop.

Herbie employs two primary IRs which we will call _SpecIR_
  (programs with real number semantics) and _ProgIR_
  (programs with floating-point semantics).
We can convert from ProgIR to SpecIR without additional information
  since we simply replace the rounding operation for every
  mathematical operator with the identity function.
However,
  translating from SpecIR to ProgIR requires assigning 
  a finite-precision rounding operation to each mathematical function.

Returning to Herbie's rewriting phases,
  observer the approximate type signatures of the three rewriting steps:

```ocaml
val taylor : SpecIR -> SpecIR list
val rr : ProgIR -> ProgIR list
val simplify : ProgIR -> ProgIR list
```

Why the difference? In truth, engineering challenges.
The egg-based rewriters _rr_ and _simplify_ are newer and
  an important part of the Pareto-Herbie (Pherbie) design from 2021.
On the other hand,
  the first version of Herbie included _taylor_ as far back as 2014.
Clearly,
  ProgIR is richer than SpecIR since it contains number format information.
For this reason,
  both rewriting and precision tuning and performed in _rr_
  (see [Pareto-Herbie](https://herbie.uwplse.org/arith21-paper.pdf))
  and a shim is required for _taylor_.

But in light of a recent conversation I had with a fellow PLSE member,
  I hypothesize that this architecture is likely incorrect,
  or at the least, problematic.
Of course,
  we could dream of the "sufficiently smart" numerical compiler
  that resembles the following architecture:

```
SpecIR, error bound ~~~~~~ magic ~~~~~~> C, machine code, etc.
```

But just as a compiler achieves its goal via numerous lowering passes,
  so too should a system like Herbie.
In fact,
  Herbie really is just a messy version of this compiler
  taking a mathematical specification and number representations
  producing floating-point code.
In light of these observations,
  I propose rearchitecting Herbie's improvement loop.
Expanding on the numerical compiler diagram,
  we would implement 

```
SpecIR ~~~~~~ rewrite ~~~~~~> SpecIR ~~~~~~ lowering ~~~~~~> ProgIR
```
There are two important phases:
 - _rewrite_: either equivalent rewrites or
    approximations producing a program over real numbers
 - _lowering_: assignment of rounding operations,
    e.g. precision tuning, and operator selection, and other decisions
    required for finite-precision computation.

Of course,
  just as in Herbie's current architecture,
  we use this process potentially multiple times with expression selection
  at the beginning and pruning at the end.
Therefore,
  the whole process looks something like the following:

1. Expression selection
2. Local error analysis
3. Lifting from ProgIR to SpecIR
4. Rewriting
    <ol type="a">
    <li>Taylor polynomial approximation ("taylor")</li>
    <li>equivalent (real-number semantics) rewrites ("rr")</li>
    </ol>
5. Lowering from SpecIR to ProgIR
    <ol type="a">
	<li>operator selection, e.g. reciprocal vs. division</li>
	<li>precision tuning</li>
    </ol>
6. Pruning

How (4) and (5) interact is an open question.
An interesting proposal would be to seed an egraph with
  the starting subexpressions from (3) and the approximations from (4a),
  run rewrites from (4b), and extract from the same egraph in (5a)
  and possibly (5b).
Additionally,
  it is unclear if separating (4) and (5) will prevent us from
  finding certain rewrites.

The new design requires that egg be used for both SpecIR and ProgIR
  which suggests splitting the rules into those over SpecIR and
  those over ProgIR.
The majority of rewriting will be done over the reals,
  but a small set of rewrites may be used in (5) for operator selection,
  e.g. posit-quire operations.
Constant folding should only be done over SpecIR
  since these programs are over the reals.
If rewriting ProgIR is done in a egraph,
  it will be minimal (no constant folding) and will just be
  for extraction via Herbie’s cost model.

Based on this new design,
  we have a number of insights and engineering improvements:
 - if we wish to rewrite expressions over the reals,
     then the rewrites should be performed over real number programs
 - operator (implementation) selection _is_ precision tuning;
     choosing to approximate `1/x` (real number program) with `recip_f64(x)`
     is both a choice of syntax and rounding.
 - _egg_ becomes a pure syntactic rewriter;
     it need not know about representations;
     Herbie's egg interface can be slimmed down,
     e.g. no rule expansion and a simpler _EggIR_.

To summarize,
  I propose a new design for Herbie's improvement loop.
Problematic expressions should be identified via
  the normal expression selection and local error analysis phases.
These expressions should be lifted to purely real-number programs
  and passed through two phases. 
The first phase applies equivalent rewrites (over the real numbers)
  and polynomial approximations.
The second phase lowers to actual floating-point operations
  via operator selection and precision tuning.
Finally,
  the same pruning operation is performed to shrink the set of
  useful alternative implementations.
