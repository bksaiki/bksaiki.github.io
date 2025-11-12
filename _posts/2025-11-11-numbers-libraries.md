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
  I want to highlight two key principles that have helped mitigate
  these challenges.

First, 
  the _round-to-odd_ rounding mode [1] allows decoupling
  of arithmetic operations from rounding.
Applying this insight to number libraries,
  a number library may consist of two independent parts:
  a core arithmetic engine performing round-to-odd operations,
  and a core rounding library that safely re-rounds under
  the desired number format or rounding mode.
This trick was pioneered by Bill Zorn [2]
  in his numbers library found in the Titanic repo [3].

Second,
  the core rounding library should be organized
  into _rounding contexts_ which encapsulate number format,
  rounding mode, and other rounding information,
  and provide a single `round` method.
These rounding contexts are often composable:
  a rounding context for an IEEE 754 floating-point number
  can reuse the same logic as a rounding context for
  a `p`-bit floating-point number,
  with added checks for overflow.
As a result,
  each operation provided by the number library
  is the composition of an operation in the arithmetic engine
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
  in the arithmetic engine,
  while adding a new format or rounding mode
  requires implementing it only once in the rounding library.
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

## Separating Rounding from Arithmetic

### Theory

To begin,
  I'll cover why round-to-odd arithmetic
  enables separating rounding from arithmetic operations.
For a real number function $$f$$,
  we say that an implementation of $$f$$, say $$f^{*}$$,
  is _correctly-rounded_ if its result is the infinitely precise
  result of $$f$$ rounded to the target number format.
This rounding operation is usually parameterized
  by a _rounding mode_ that specifies how to round
  when the result is not exactly representable
  in the target number format.
IEEE 754 specifies several rounding modes:
  round to nearest, ties to even (RNE),
  round to positive infinity (RTP),
  round to negative infinity (RTN),
  round toward zero (RTZ), and
  round to nearest, ties away from zero (RNA).

For this section,
  we'll only consider floating-point numbers
  with a fixed precision of $$p$$ digits,
  so I'll denote the rounding operation in the style
  of Boldo and Melquiond [1] as $$\mathrm{rnd}^{p}_{rm}$$.
Using this notation,
  the correctly-rounded implementation of $$f$$
  in precision $$p$$ under rounding mode $$rm$$
  can be expressed as:

$$
f^{*} = \mathrm{rnd}^{p}_{rm} \circ f.
$$

Other rounding modes exist beyond those specified by IEEE 754.
The most notable is round to odd (RTO),
  which rounds an unrepresentable number to the nearest
  representable number with an odd least significant digit.
An important result from Boldo and Melquiond [1]
  states that round to odd permits _safe re-rounding_:
  rounding with round to odd first, then re-rounding
  under any standard rounding mode at lower precision
  yields the same result as rounding directly
  under that standard rounding mode at lower precision.

**Theorem 1.**
Let $$x \in \mathbb{R}$$ be a real number;
  $$p, k \geq 2$$ be integers;
 and $$rm$$ be a standard rounding mode.
Then,

$$
\mathrm{rnd}^{p}_{rm}(x) = \mathrm{rnd}^{p}_{rm}(\mathrm{rnd}^{p+k}_{RTO}(x)).
$$

Applying this theorem to our definition of $$f^{*}$$,
  we conclude that a correctly-rounded implementation of $$f$$
  is the composition of a round-to-odd implementation of $$f$$
  followed by re-rounding under the desired rounding mode:

$$
f^{*} = \mathrm{rnd}^{p}_{rm} \circ f
= (\mathrm{rnd}^{p}_{rm} \circ \mathrm{rnd}^{p+k}_{RTO}) \circ f
= \mathrm{rnd}^{p}_{rm} \circ (\mathrm{rnd}^{p+k}_{RTO} \circ f).
= \mathrm{rnd}^{p}_{rm} \circ f_{RTO}^{*}.
$$

This result is not novel.
One successful application of this result is found in the RLibm project [4]
  which automatically generates efficient, correctly-rounded elementary functions
  by generating a polynomial approximation with additional bits
  of precision using round-to-odd arithmetic that will be correctly rounded
  when re-rounded under the desired rounding mode.

For number libraries,
  the result has significant implications:
  it suggests that we can build a number library
  with two _independent_ components:
  an _arithmetic engine_ that implements each
  mathematical operation using round-to-odd arithmetic,
  and a _rounding library_ that implements
  rounding operations for various number formats
  and rounding modes.
The only interaction between the two components
  is that the rounding library must provide the precision $$p + k$$
  required for safe re-rounding.
In a program,
  we may write `f<p, rm>(x)` to evaluate $$f^{*}$$
  on an input $$x$$ with precision $$p$$ and rounding mode $$rm$$.

Building a number library this way achieves the benefits mentioned earlier:

- _Maintainability:_ The arithmetic engine implements each operation only once,
  while the rounding library implements rounding logic separately.

- _Extensibility:_ Implementing a new mathematical operation
  inherits the rounding capabilities of the rounding library,
  and implementing a new number format or rounding mode
  inherits all mathematical operations available.

- _Correctness:_ Once a mathematical operation is verified
  in the arithmetic engine, its correctness applies to any
  composition with the rounding library.
  Similarly, once a rounding context is verified,
  its correctness applies to any mathematical operation.
  Thus, testing can be done modularly and the results reused.

### Application

To illustrate this design,
  consider a number library providing
  an implementation of multiplication.

```python
module Numbers:
    module Engine:
        def rto_mul(x, y, p):
            ...

    module Round:
        def round(x, p, rm):
            ...

        def rto_prec(p):
            ...

    def mul(x, y, p, rm):
        rto_p = Round.rto_prec(p)
        result = Engine.rto_mul(x, y, rto_p)
        return Round.round(result, p, rm)
```

The `Engine` module implements arithmetic operations
  that produce round-to-odd results with at least precision `p`.
The `Round` module handles rounding operations
  and precision calculations:
  `round` rounds `x` to precision `p` using the specified rounding mode,
  while `rto_prec` calculates the precision needed for safe re-rounding.
The `mul` function provided by the number library
  composes these functions by
  performing round-to-odd multiplication,
  and re-rounding to the desired precision and rounding mode.

To implement `rto_mul`,
  we can use existing libraries like MPFR
  that have been extensively tested.
MPFR provides a narrower interface
  that perform floating-point arithmetic at
  a specified precision and rounding mode.
Although MPFR does not directly support round-to-odd,
  we can implement it as described by Boldo and Melquiond [1]:
  we use MPFR's implementation at precision `p - 1` with
  round towards zero, followed by an additional step to adapt
  the result to be round-to-odd at precision `p`.

```python
def rto_mul(x, y, p):
  r = MPFR.mul(x, y, p - 1, MPFR.RTZ)
  return rto_fixup(r)
```

Note by Theorem 1,
  we can request higher precision than `p` for safe re-rounding.

Since the arithmetic engine and rounding library are separate,
  the exact implementation of `rto_mul` can be changed
  without affecting the correctness of any `mul` implementation,
  as long as it produces correct round-to-odd results.
For example,
  if we assume that floating-point numbers in our library
  has the following structure:

```python
class Float: # (-1)^sign}* c * 2^exp
  sign: bool # sign
  exp: int # exponent
  c: int # significand (c >= 0)
```

We can implement `rto_mul` manually as follows:

```python
def rto_mul(x, y, p):
  s = x.sign != y.sign
  exp = x.exp + y.exp
  c = x.c * y.c
  return Float(s, exp, c)
```

Notice that this implementation does not perform any rounding;
  it simply multiplies the significands and adds the exponents.
The result is guaranteed to be round-to-odd for any
  precision greater than the sum of the precisions of `x` and `y`.
Extending this implementation to handle special values
  is left as an exercise for the reader.

For the `Round` module,
  we need to implement `rto_prec` to request enough precision
  to re-round results from the `Engine` safely.
The implementation of `rto_prec` is straightforward:
  it simply adds a constant number of bits
  required for safe re-rounding to the target precision.

Implementing the `round` function,
  requires care as it's the core method of the rounding library.
The exact implementation is too verbose
  to include here, but I'll outline its basic structure.
For this example,
  we'll ignore special values like NaN and infinity.

```python
def round(x, p, rm):
  n = x.e - p  # compute where to round off digits
  hi, lo = x.split(n) # split into significant and leftover digits
  rbits = lo.round_bits(n) # summarize leftover digits for rounding decision
  increment = decide_increment(hi, rbits, rm) # round away from zero based on rounding mode?
  if increment: # adjust hi if needed
    hi = hi.increment()
  return hi
```

The `round` function first determines
  where to round off digits based on the normalized exponent
  of the argument and the target precision.
Any digit above this point is significant
  while digits below must be rounded off.
A method `split` divides the number based on this point,
  and the lower part is summarized into rounding bits,
  using a round-sticky (RS) or round-guard-sticky (RGS) scheme.
Since `hi` represents the round towards zero result,
  we decide whether to round away from zero to the next representable
  value based on the rounding bits and the specified rounding mode.
The correctly-rounded result is `hi`.

Importantly,
  when implementing additional implementation,
  we must only provide the round to odd implementation,
  either from existing libraries or directly;
  the `round` function can be reused as-is
  assuming the safe re-rounding contract is met.

## Rounding Contexts


## Benefits


## References

1. Sylvie Boldo, Guillaume Melquiond. When double rounding is odd. 17th IMACS World Congress,
Jul 2005, Paris, France. pp.11. ffinria-00070603v2f

2. Bill Zorn. 2021. Rounding. Ph.D. Dissertation. University of Washington, USA. https://hdl.handle.net/1773/48230

3. Bill Zorn. 2025. Titanic [GitHub]. Accessed on November 11, 2025, from https://github.com/billzorn/titanic.

4. Jay P. Lim and Santosh Nagarakatte. 2022. One Polynomial Approximation to Produce Correctly Rounded
Results of an Elementary Function for Multiple Representations and Rounding Modes. Proc. ACM Program.
Lang. 6, POPL, Article 3 (January 2022), 28 pages. https://doi.org/10.1145/3498664.
