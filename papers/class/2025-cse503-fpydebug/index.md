---
layout: single
title: "FPyDebug: Numerical Accuracy Profiling"
---

This paper describes our CSE 503 class project.

- Authors: Brett Saiki, Wei Jun Tan
- Date: December 2025
- Venue: N/A

Links: [PDF](paper.pdf)

## Abstract 

Floating-point rounding errors easily lead to unacceptable devia-
tions from the intended real number computation, yet they remain
difficult to debug. Current numerical accuracy debugging tools
suffer from two distinct problems: they are external from the lan-
guage ecosystem—users must cycle between the implementation
environment and the debugging environment—and they rely on
approximate methods—errors may not be caught or valid code is
falsely reported. Both of these issues discourage user of these tools
and decrease their reliability. Instead, we propose such debugging
should be lightweight—available within the environment itself—and
accurate—using exact oracles when possible.

We implemented our ideas in FPyDebug, a numerical accuracy
profiler that can detect if a function suffers from numerical error,
and if so, ranks the function’s expressions by the likelihood they
contribute to the observable error. To measure accuracy correctly,
FPyDebug provides real number computation, extending prior work
to work with statements and complex control flow. To be conve-
nient, FPyDebug is available as a library in Python for Python code.
We demonstrate FPyDebug on 134 benchmarks from across a wide
variety of domains. FPyDebug allows users to easily and accurately
identity numerical errors within their program. Moreover, its real
number evaluation strategy is more accurate than approximate
methods, incurring a 2.9× performance overhead.

```
@misc{fpydebug,
  author       = {Saiki, Brett and Tan, Wei Jun},
  title        = {FPyDebug: Numerical Accuracy Profiling},
  howpublished = {\url{https://bsaiki.com/papers/class/2025-cse503-fpydebug/paper.pdf}},
  year         = {2025},
  note         = {Unpublished manuscript}
}
```
