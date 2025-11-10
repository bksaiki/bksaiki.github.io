---
layout: single
title: "Target-Aware Implementation of Real Expressions"
permalink: /papers/conference/2025-asplos-chassis/
---

Authors: **Brett Saiki**, Jackson Brough, Jonas Regehr, Jesús Ponce, Varun Pradeep, Aditya Akhileshwaran, Zachary Tatlock, Pavel Panchekha

Venue: Architectural Support for Programming Languages and Operating Systems (ASPLOS) 2025

Links:
[Paper](https://arxiv.org/pdf/2410.14025.pdf) |
[Slides](https://docs.google.com/presentation/d/1pvysk84nVQlLdLAhwoHSfIgp6QoL6NL6Uk5GvmtjHvg) |
[Poster](https://docs.google.com/presentation/d/1j2rfyNgRH9_XIUSdaMi50BzP4dmSsihRcIifH_oauUg)

## Abstract

New low-precision accelerators, vector instruction sets, and
library functions make maximizing accuracy and performance of numerical code increasingly challenging. Two lines
of work—traditional compilers and numerical compilers—
attack this problem from opposite directions. Traditional
compiler backends optimize for specific target environments
but are limited in their ability to balance performance and
accuracy. Numerical compilers trade off accuracy and performance, or even improve both, but ignore the target environment. We join aspects of both to produce Chassis, a
target-aware numerical compiler.

Chassis compiles mathematical expressions to operators
from a target description, which lists the real expressions
each operator approximates and estimates its cost and accuracy. Chassis then uses an iterative improvement loop
to optimize for speed and accuracy. Specifically, a new instruction selection modulo equivalence algorithm efficiently
searches for faster target-specific programs, while a new
cost-opportunity heuristic supports iterative improvement.
We demonstrate Chassis’ capabilities on 9 different targets,
including hardware ISAs, math libraries, and programming
languages. Chassis finds better accuracy and performance
trade-offs than both Clang (by 3.5×) or Herbie (by up to
2.0×) by leveraging low-precision accelerators, accuracyoptimized numerical helper functions, and library subcomponents.


```
@inproceedings{10.1145/3669940.3707277,
author = {Saiki, Brett and Brough, Jackson and Regehr, Jonas and Ponce, Jesus and Pradeep, Varun and Akhileshwaran, Aditya and Tatlock, Zachary and Panchekha, Pavel},
title = {Target-Aware Implementation of Real Expressions},
year = {2025},
isbn = {9798400706981},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
url = {https://doi.org/10.1145/3669940.3707277},
doi = {10.1145/3669940.3707277},
abstract = {New low-precision accelerators, vector instruction sets, and library functions make maximizing accuracy and performance of numerical code increasingly challenging. Two lines of work---traditional compilers and numerical compilers---attack this problem from opposite directions. Traditional compiler backends optimize for specific target environments but are limited in their ability to balance performance and accuracy. Numerical compilers trade off accuracy and performance, or even improve both, but ignore the target environment. We join aspects of both to produce Chassis, a target-aware numerical compiler.Chassis compiles mathematical expressions to operators from a target description, which lists the real expressions each operator approximates and estimates its cost and accuracy. Chassis then uses an iterative improvement loop to optimize for speed and accuracy. Specifically, a new instruction selection modulo equivalence algorithm efficiently searches for faster target-specific programs, while a new cost-opportunity heuristic supports iterative improvement. We demonstrate Chassis capabilities on 9 different targets, including hardware ISAs, math libraries, and programming languages. Chassis finds better accuracy and performance trade-offs than both Clang (by 3.5\texttimes{}) or Herbie (by up to 2.0\texttimes{}) by leveraging low-precision accelerators, accuracy-optimized numerical helper functions, and library subcomponents.},
booktitle = {Proceedings of the 30th ACM International Conference on Architectural Support for Programming Languages and Operating Systems, Volume 1},
pages = {1069–1083},
numpages = {15},
keywords = {domain-specific compilation, equality saturation, floating point, optimization},
location = {Rotterdam, Netherlands},
series = {ASPLOS '25}
}
```
