---
layout: posts
title: "Composable, Correctly-Rounded Numbers Libraries"
date: 2025-11-11
last_modified_at: 2025-11-11
categories: blog
tags:
 - floating-point
 - rounding
---

Number libraries are essential tools
  for simulating number systems, like floating-point
  and fixed-point numbers, and operations on them,
  including rounding modes and special value handling.
These libraries are used for analyzing
  multi-precision numerical algorithms,
  and verifying the correctness of
  numerical hardware and software.

Maintainers of these libraries face significant challenges
  ensuring usable and correct implementations,
  as these libraries:

- must support many number formats and operations,
- often serve as reference implementations for testing correctness,
- must be efficient enough for simulation and verification tasks.

As new number formats and rounding behaviors proliferate,
  developers are faced with an explosion of different
  combinations of operations, formats, rounding modes,
  overflow behavior, special value handling, and more.
Each new feature requires careful implementation and testing,
  multiplying the complexity, verification effort,
  and maintenance burden.

Reflecting on the number libraries I have built and maintained,
  I want to highlight key principles that have helped mitigate
  these challenges.

First, 
  the _round-to-odd_ rounding mode allows decoupling
  of arithmetic operations from rounding.
Applying this insight to number libraries,
  a number library may consist of two independent parts:
  a core arithmetic engine performing round-to-odd operations,
  and a core rounding library that safely re-rounds under
  the desired number format or rounding mode.

Second,
  the core rounding library should be organized
  into _rounding contexts_ which encapsulate number format,
  rounding mode, and other rounding information,
  and provide a single `round` method.
Moreover rounding contexts are often composable:
  a rounding context for an IEEE 754 floating-point number
  can reuse much of use the same logic as a rounding context for
  a `p`-bit floating-point number with added
  checks for overflow.
As a result,
  each operation provided by the number library
  is the composition of an operation in the core arithmetic engine
  and the `round` method of a rounding context instance from
  the core rounding library.

Put together,
  these two design principles enable significant
  modularity and code reuse within number libraries,
  resulting in several benefits.
First,
  it dramatically improves _maintainability:_
  the library is smaller;
  the amount of code is proportional to the sum of
  the number of operations and the number of rounding contexts,
  rather than their product.
Second,
  it ensures _extensibility:_
  adding features is easier and less error-prone;
  adding a new operation requires implementing it only once
  in the core arithmetic engine,
  while adding a new format or rounding mode
  requires implementing it only once in the rounding module.
Third,
  it improves _correctness:_
  testing can be done compositionally;
  components can be extensively tested in isolation,
  and their composition is thus more likely to be correct.

I will explore these two design principles in greater detail
  and illustrate their benefits through examples.
Research on number libraries is rarely published,
  and principles behind their design are rarer still.
As someone working in this space,
  I hope this blog post provides some insight
  into the challenges and solutions in this domain.
