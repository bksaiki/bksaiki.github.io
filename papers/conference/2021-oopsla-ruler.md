---
layout: single
title: "Rewrite Rule Inference Using Equality Saturation"
permalink: /papers/conference/2021-oopsla-ruler/
---

Authors: Chandrakana Nandi, Max Willsey, Amy Zhu, Brett Saiki, Yisu Wang,
Adam Anderson, Adriana Schulz, Dan Grossman, Zachary Tatlock

Venue: Object-Oriented Programming, Systems, Languages & Applications (OOPSLA) 2021

Links:
[Paper](https://arxiv.org/pdf/2108.10436.pdf)

## Abstract

Many compilers, synthesizers, and theorem provers rely on rewrite rules to simplify expressions or prove
equivalences. Developing rewrite rules can be difficult: rules may be subtly incorrect, profitable rules are easy
to miss, and rulesets must be rechecked or extended whenever semantics are tweaked. Large rulesets can also
be challenging to apply: redundant rules slow down rule-based search and frustrate debugging.

This paper explores how equality saturation, a promising technique that uses e-graphs to apply rewrite
rules, can also be used to infer rewrite rules. E-graphs can compactly represent the exponentially large sets of
enumerated terms and potential rewrite rules. We show that equality saturation efficiently shrinks both sets,
leading to faster synthesis of smaller, more general rulesets.

We prototyped these strategies in a tool dubbed Ruler. Compared to a similar tool built on CVC4, Ruler
synthesizes 5.8× smaller rulesets 25× faster without compromising on proving power. In an end-to-end
case study, we show Ruler-synthesized rules which perform as well as those crafted by domain experts, and
addressed a longstanding issue in a popular open source tool.

```
@article{10.1145/3485496,
author = {Nandi, Chandrakana and Willsey, Max and Zhu, Amy and Wang, Yisu Remy and Saiki, Brett and Anderson, Adam and Schulz, Adriana and Grossman, Dan and Tatlock, Zachary},
title = {Rewrite rule inference using equality saturation},
year = {2021},
issue_date = {October 2021},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
volume = {5},
number = {OOPSLA},
url = {https://doi.org/10.1145/3485496},
doi = {10.1145/3485496},
abstract = {Many compilers, synthesizers, and theorem provers rely on rewrite rules to simplify expressions or prove equivalences. Developing rewrite rules can be difficult: rules may be subtly incorrect, profitable rules are easy to miss, and rulesets must be rechecked or extended whenever semantics are tweaked. Large rulesets can also be challenging to apply: redundant rules slow down rule-based search and frustrate debugging. This paper explores how equality saturation, a promising technique that uses e-graphs to apply rewrite rules, can also be used to infer rewrite rules. E-graphs can compactly represent the exponentially large sets of enumerated terms and potential rewrite rules. We show that equality saturation efficiently shrinks both sets, leading to faster synthesis of smaller, more general rulesets. We prototyped these strategies in a tool dubbed Ruler. Compared to a similar tool built on CVC4, Ruler synthesizes 5.8\texttimes{} smaller rulesets 25\texttimes{} faster without compromising on proving power. In an end-to-end case study, we show Ruler-synthesized rules which perform as well as those crafted by domain experts, and addressed a longstanding issue in a popular open source tool.},
journal = {Proc. ACM Program. Lang.},
month = oct,
articleno = {119},
numpages = {28},
keywords = {Equality Saturation, Program Synthesis, Rewrite Rules}
}
```
