---
layout: single
title: "Odyssey: An Interactive Workbench for Expert-Driven Floating-Point Expression Rewriting"
permalink: /papers/conference/2023-uist-odyssey/
---

Authors: Edward Misback, Caleb C. Chan, **Brett Saiki**, Eunice Jun, Zachary Tatlock, Pavel Panchekha

Venue: ACM Symposium on User Interface Software and Technology (UIST) 2023

Links:
[Paper](https://arxiv.org/pdf/2305.10599.pdf)

## Abstract

In recent years, researchers have proposed a number of automated
tools to identify and improve floating-point rounding error in mathematical expressions. However, users struggle to effectively apply
these tools. In this paper, we work with novices, experts, and tool developers to investigate user needs during the expression rewriting
process. We find that users follow an iterative design process. They
want to compare expressions on multiple input ranges, integrate
and guide various rewriting tools, and understand where errors
come from. We organize this investigation’s results into a threestage workflow and implement that workflow in a new, extensible
workbench dubbed Odyssey. Odyssey enables users to: (1) diagnose
problems in an expression, (2) generate solutions automatically or
by hand, and (3) tune their results. Odyssey tracks a working set of
expressions and turns a state-of-the-art automated tool “inside out,”
giving the user access to internal heuristics, algorithms, and functionality. In a user study, Odyssey enabled five expert numerical
analysts to solve challenging rewriting problems where state-ofthe-art automated tools fail. In particular, the experts unanimously
praised Odyssey’s novel support for interactive range modification
and local error visualization.

```
@inproceedings{10.1145/3586183.3606819,
author = {Misback, Edward and Chan, Caleb C. and Saiki, Brett and Jun, Eunice and Tatlock, Zachary and Panchekha, Pavel},
title = {Odyssey: An Interactive Workbench for Expert-Driven Floating-Point Expression Rewriting},
year = {2023},
isbn = {9798400701320},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
url = {https://doi.org/10.1145/3586183.3606819},
doi = {10.1145/3586183.3606819},
abstract = {In recent years, researchers have proposed a number of automated tools to identify and improve floating-point rounding error in mathematical expressions. However, users struggle to effectively apply these tools. In this paper, we work with novices, experts, and tool developers to investigate user needs during the expression rewriting process. We find that users follow an iterative design process. They want to compare expressions on multiple input ranges, integrate and guide various rewriting tools, and understand where errors come from. We organize this investigation’s results into a three-stage workflow and implement that workflow in a new, extensible workbench dubbed Odyssey. Odyssey enables users to: (1) diagnose problems in an expression, (2) generate solutions automatically or by hand, and (3) tune their results. Odyssey tracks a working set of expressions and turns a state-of-the-art automated tool “inside out,” giving the user access to internal heuristics, algorithms, and functionality. In a user study, Odyssey enabled five expert numerical analysts to solve challenging rewriting problems where state-of-the-art automated tools fail. In particular, the experts unanimously praised Odyssey’s novel support for interactive range modification and local error visualization.},
booktitle = {Proceedings of the 36th Annual ACM Symposium on User Interface Software and Technology},
articleno = {77},
numpages = {15},
keywords = {Debugging, Developer Tools, Dynamic Analysis, Expert Programming, Floating Point, Term Rewriting},
location = {San Francisco, CA, USA},
series = {UIST '23}
}
```
