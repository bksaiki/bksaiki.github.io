---
layout: posts
title: "Composable, Correctly-Rounded Numbers Libraries"
date: 2025-11-12
last_modified_at: 2025-11-12
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
- often serve as reference implementations for
  testing correctness of other systems,
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
  is the composition of
  (i) a round-to-odd implementation of $$f$$; followed by
  (ii) re-rounding under the desired rounding mode:

$$
f^{*} = \mathrm{rnd}^{p}_{rm} \circ f
= (\mathrm{rnd}^{p}_{rm} \circ \mathrm{rnd}^{p+k}_{RTO}) \circ f
= \mathrm{rnd}^{p}_{rm} \circ (\mathrm{rnd}^{p+k}_{RTO} \circ f).
= \mathrm{rnd}^{p}_{rm} \circ f_{RTO}^{*}.
$$

This result is not novel.
One successful application is found in the RLibm project [4]
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

To illustrate this approach in practice,
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
  assume that floating-point numbers in our library
  has the following structure:

```python
class Float: # (-1)^sign * c * 2^exp
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

Notice that this implementation does not perform any rounding.
The result is guaranteed to be round-to-odd for any
  precision greater than the sum of the precisions of `x` and `y`.
Extending this implementation to handle special values
  is left as an exercise for the reader.

For the `Round` module,
  we need to implement two functions:
- `rto_prec(p)` computes the precision required
  for safe re-rounding to precision `p`; and

- `round(x, p, rm)` rounds `x` to precision `p`
  using the specified rounding mode `rm`.

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
Since `hi` represents the round-towards-zero result,
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

While separating rounding from arithmetic
  allows developers to split the number library
  into two independent components,
  the rounding library must support a large number
  of number formats and rounding behaviors.
To manage this complexity,
  we can organize the rounding library
  into _rounding contexts_.

A rounding context encapsulates all information
  required to round a number correctly:
  the number format (precision, exponent range, etc.),
  the rounding mode,
  overflow behavior (saturating, wrapping, exceptions, etc.),
  and special value handling (NaN, infinity, etc.).
Rather than having a single `round` function
  that consumes all rounding information as
  a exhaustive list of parameters,
  we convert `Round` into an interface;
  each rounding context will implement the interface.

```python
interface Round:
  def rto_prec():
    ...

  def round(x):
    ...

  def round_core(x, p, rm):
     ...


def mul(x, y, ctx):
  rto_p = ctx.rto_prec()
  result = Engine.rto_mul(x, y, rto_p)
  return ctx.round(result)
```

The two interface methods are similar to before:
- `rto_prec` computes the precision required to safely re-round
  a number _under_ the instance of the rounding context; and
- `round` rounds `x` _under_ the instance of the rounding context.

The previous `round` implementation is now `round_core`,
  which can be reused as the core rounding primitive
  by each rounding context implementation.
The `mul` function now accepts
  a rounding context instance rather than explicit rounding parameters:
  its implementation must be adapted slightly.
A sensible strategy is to organize
  the different implementations of `Round`
  based on families of _number formats_.
For example,
  we can implement `p`-digit floating-point numbers,
  as a family of rounding contexts.

```python
class MPFloat(Round):
  p: int # p >= 1
  rm: RoundingMode

  def rto_prec(self):
    return self.p + k  # k is a constant for safe re-rounding

  def round(self, x):
    return self.round_core(x, self.p, self.rm)
```

Notice that we completely
  reuse the `round_core` implementation for the rounding logic.

Critically,
  we add support for new number formats
  by simply implementing a new class that
  implements the `Round` interface.
For example,
  consider supporting the IEEE 754 floating-point numbers
  parameterized by `es`, the size of the exponent field,
  and `nbits`, the total number of bits of the representation.
While IEEE 754 numbers have restrictions
  on exponent ranges, its core rounding behavior
  is similar to `p`-digit floating-point numbers:
  we can reuse the `MPFloat` rounding logic.
The exact implementation is too verbose,
  but an outline of the implementation is as follows:

```python
class IEEEFloat(Round):
  es: int  # exponent size (es >= 2)
  nbits: int  # total number of bits (nbits >= es + 2)
  rm: RoundingMode

  def mp_ctx(self): # corresponding MPFloat context
    return MPFloat(nbits - es, rm)

  def emin(self): # minimum (normalized) exponent
    return 1 - (1 << (es - 1))

  def rto_prec(self):
    p = self.nbits - self.es
    return MPFloat(p, self.rm).rto_prec() # need at least this much precision

  def round(self, x):
    max_p = self.nbits - self.es # maximum allowable precision
    e_diff = x.e - self.emin() # e_diff < 0 if subnormal
    p = min(max_p, max_p + e_diff + 1) # adjust precision for subnormals
    r = MPFloat(p, rm).round(x) # re-use rounding logic
    # handle overflow based on rounding mode
    ...
    return r
```

The implementation of `round` is more complicated.
First,
  we must deal with subnormal numbers,
  i.e., numbers with magnitude below $$2^{emin}$$
  which have reduced precision: `max_p + e_diff`,
  adding 1 to allocate precision for the next
  power of two.
We adjust the precision accordingly,
  construct the appropriate `MPFloat` context,
  and reuse its `round` method to round
  without exponent bounds.
Finally,
  we handle overflow based on the specified rounding mode:
  the exact implementation is left as an exercise for the reader.

What about fixed-point formats?
To support fixed-point numbers,
  we first alter `round_core` to accept a parameter `n`
  which sets `n` directly:

```python
def round_core(x, p, n, rm): # added n parameter
  ...
```

The caller must specify either `p` or `n`.
If both are specified, then the option
  that will preserve the fewest digits is chosen.

We must also alter the arithmetic engine
  to request a stopping point `n` rather than
  precision `p` when performing round-to-odd operations.
For example,
  if we want to round with `n=-1`, keeping only
  integer digits, then the arithmetic engine must produce
  a round-to-odd result with enough arbitrary precision
  to preserve all integer digits plus extra digits
  for safe re-rounding.
One method of supporting fixed-point style computation
  is making an initial precision guess,
  re-computing with the correct precision based
  on the result only when needed.
Like before,
  one of `p` or `n` must be specified.

```python
module Engine:
  def rto_mul(x, y, p, n):
    ...

def mul(x, ctx):
  p, n = ctx.rto_params()
  result = Engine.rto_mul(x, y, p, n)
  return ctx.round(result)
```

Consider implementing a rounding context
  for an arbitrary-precision fixed-point number
  that must round any digit less significant than
  the `n+1`-th digit:

```python
class MPFixed(Round):
  n: int  # first insignificant digit (drop digits <= n)
  rm: RoundingMode

  def rto_params(self):
    return None, self.n - k  # k is a constant for safe re-rounding

  def round(self, x):
    return self.round_core(x, None, self.n, self.rm)

```

I could continue to list implementations of
  rounding contexts for other number formats,
  but I believe the pattern is clear:
  to support new number formats, we implement
  a rounding context class that can often reuse
  existing rounding logic.
Machine integers and fixed-point formats
  can compose `MPFixed` and apply the appropriate
  overflow behavior.
Floating-point formats like those
  described in the OCP MX standard [5] might
  benefit from a similar approach to
  IEEE 754 floating-point numbers.
Posit numbers [6] are floating-point numbers
  with _tapered_ precision;
  one approach might be to use `MPFloat`
  with variable precision based on the magnitude of the number.

Organizing the rounding library into rounding contexts achieves the following benefits:

- _Maintainability:_ Rounding contexts encapsulate
  rounding logic and often compose together existing
  rounding contexts to implement its rounding behavior.

- _Extensibility:_ Implementing a new number format
  only requires implementing a new rounding context class,
  often reusing existing rounding logic; any instance
  of the new rounding context can be used with
  all existing mathematical operations.

- _Correctness:_ Rounding can be decomposed
  into many smaller, often reusable components;
  verifying each component in isolation
  increases confidence in the correctness
  of each rounding context implementation.

## Evaluation

To demonstrate the benefits of these design principles,
  I applied these principles to the number library
  that supports the FPy language [7].
FPy is an embedded Python DSL for specifying numerical algorithms,
  with explicit control over rounding via rounding contexts,
  including first-class rounding context values.
The number library supports many families of number formats
  from IEEE 754 floating-point numbers,
  OCP MX floating-point numbers,
  fixed-point numbers, and more.

### Maintainability

Outline:
- show code size
- show comparison to softfloat or Universal?

### Extensibility

To demonstrate extensibility,
  I implemented support for an additional operator ???,
  and an additional number format ???.


Outline:
 - additional operator
 - additional number format

### Correctness

To demonstrate correctness,
  I'll describe the testing strategy for FPy.

Outline:
 - show PBT tests for core methods


## Conclusion

Number libraries face an explosion of complexity
  with new formats, rounding modes, and operations.
The two design principles presented here ---
  separating arithmetic from rounding via round-to-odd,
  and organizing rounding logic into composable contexts ---
  offer a practical solution to this challenge.
By decoupling these concerns,
  number library developers can achieve
  smaller, more maintainable codebases
  that are more extensible and easier to verify
  compared to traditional monolithic designs.
As the numerical computing landscape continues to evolve,
  these principles are one such approach to provide a foundation
  for building maintainable, correct, and extensible
  number libraries that can adapt to future requirements
  without overwhelming their maintainers.

## References

1. Sylvie Boldo, Guillaume Melquiond. When double rounding is odd. 17th IMACS World Congress,
Jul 2005, Paris, France. pp.11. ffinria-00070603v2f

2. Bill Zorn. 2021. Rounding. Ph.D. Dissertation. University of Washington, USA.
[https://hdl.handle.net/1773/48230](https://hdl.handle.net/1773/48230)

3. Bill Zorn. 2017. Titanic [GitHub]. Accessed on November 11, 2025, from
[https://github.com/billzorn/titanic](https://github.com/billzorn/titanic).

4. Jay P. Lim and Santosh Nagarakatte. 2022. One Polynomial Approximation to Produce Correctly Rounded
Results of an Elementary Function for Multiple Representations and Rounding Modes. Proc. ACM Program.
Lang. 6, POPL, Article 3 (January 2022), 28 pages.
[https://doi.org/10.1145/3498664](https://doi.org/10.1145/3498664).

5. Bita Darvish Rouhani, Ritchie Zhao, Ankit More, Mathew Hall, Alireza Khodamoradi, Summer Deng,
Dhruv Choudhary, Marius Cornea, Eric Dellinger, Kristof Denolf, Stosic Dusan, Venmugil Elango, Maximilian Golub,
Alexander Heinecke, Phil James-Roxby, Dharmesh Jani, Gaurav Kolhe, Martin Langhammer, Ada Li, Levi Melnick,
Maral Mesmakhosroshahi, Andres Rodriguez, Michael Schulte, Rasoul Shafipour, Lei Shao, Michael Siu, Pradeep Dubey,
Paulius Micikevicius, Maxim Naumov, Colin Verrilli, Ralph Wittig, Doug Burger, and Eric Chung. 2023.
Microscaling Data Formats for Deep Learning. arXiv preprint arXiv:2310.10537 (2023).
[https://arxiv.org/abs/2310.10537](https://arxiv.org/abs/2310.10537)

6. John L. Gustafson. 2017. Beating Floating Point at its Own Game: Posit Arithmetic. Supercomputing Frontiers and Innovations 4, 2 (2017), 71–86.
[https://doi.org/10.14529/jsfi170206](https://doi.org/10.14529/jsfi170206)

7. Brett Saiki. 2025. FPy [GitHub]. Accessed on November 12, 2025, from
[https://github.com/bksaiki/fpy](https://github.com/bksaiki/fpy).
