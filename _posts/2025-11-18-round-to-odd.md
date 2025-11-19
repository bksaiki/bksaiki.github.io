---
layout: posts
title: "Round to Odd"
date: 2025-11-19
last_modified_at: 2025-11-19
categories: blog
tags:
 - floating-point
 - rounding
---

When rounding real numbers to floating-point,
  fixed-point, or integer numbers,
  _rounding modes_ determine how to handle cases
  where the real number cannot be represented exactly.
Changing the rounding mode
  can have significantly change
  the accuracy and numerical stability
  of a numerical computation.
Due to the nuanced effects rounding modes,
  they are almost never exposed to programmers
  in general purpose programming languages,
  with rare exceptions:
  C (and C++) provide some support via
  the `<fenv.h>` (`<cfenv>` in C++) header,
  through functions like `fesetround` and `fegetround`.

There are several rounding modes in use today.
For example,
  the IEEE 754 standard [1] defines five rounding modes:
  round to nearest, ties to even (RNE),
  round to nearest, ties away from zero (RNA),
  round to positive infinity (RTP),
  round to negative infinity (RTN), and
  round toward zero (RTZ).
In most programming environments,
  the default rounding mode is RNE.
However,
  across the literature on floating-point arithmetic,
  one rounding mode stands out:
  round to odd (RTO).

This blog post intends to explain
  common rounding modes and
  the round to odd,
  building towards the essential property
  of round to odd: safe re-rounding.

## Floating-Point Numbers

As is customary,
  I'll briefly review floating-point numbers.
Floating-point numbers
  are numbers represented in the form:

$$
(-1)^s * c * 2^{exp}
$$

where $$s \in \{0, 1\}$$ is the sign,
  $$c \in \mathbb{N}$$ is the significand,
  and $$exp \in \mathbb{Z}$$ is the (unnormalized) exponent.
The smallest number of digits
  used to represent $$c$$ is called
  the _precision_, $$p$$, of the number.
Alternatively,
  we can represent floating-point numbers
  in normalized form:

$$
(-1)^s * m * 2^e
$$

where $$1 \leq m < 2$$ is the mantissa
  and $$e \in \mathbb{Z}$$ is the (normalized) exponent.
The relationship between the two forms
  is given by the equations:

$$
c = m * 2^{p - 1}
$$

and

$$
exp = e - (p - 1).
$$

The IEEE 754 standard
  extends floating-point numbers
  to include special values:
  including negative zero, $$-0$$;
  positive infinity, $$+ \infty$$;
  negative infinity, $$- \infty$$;
  and Not a Number, $$\mathrm{NaN}$$.

Number formats define
  discrete sets of floating-point numbers
  that approximate real numbers [^1].
A _rounding_ operation
  maps real numbers to representable values
  of a number format according to rules,
  called the rounding mode.

<!-- When every value in the number format
  is represented by a fixed exponent,
  we say that the values are _fixed-point_ numbers. -->

## Correctly-Rounded Functions

Rounding extends naturally to real-valued functions
  through _correctly-rounded_ functions.
We say that an implementation of
  a real-valued function $$f$$, say $$f^{*}$$,
  is correctly-rounded if its result is the infinitely precise
  result of $$f$$, rounded to the target number format
  according to a specified rounding mode.
We'll only consider floating-point numbers
  with a fixed precision of $$p$$ digits,
  so I'll denote the rounding operation in the style
  of Boldo and Melquiond [2] as $$\mathrm{rnd}^{p}_{rm}$$.
Using this notation,
  the correctly-rounded implementation of $$f$$
  in precision $$p$$ under rounding mode $$rm$$
  can be expressed as:

$$
f^{*} = \mathrm{rnd}^{p}_{rm} \circ f.
$$

Requiring correct rounding has strong arguments [3]:
  it provides a clear specification for
  the behavior of $$f^{*}$$;
  it ensures reproducibility of results
  across different implementations of $$f^{*}$$;
  and it bounds the numerical error
  introduced by rounding.

## Rounding Modes

Once we compute
  the infinitely precise result of $$f(x)$$
  for a real number $$x$$,
  we need to round the result to get
  $$f^{*}(x) = \mathrm{rnd}^{p}_{rm}(f(x))$$.
To illustrate the different rounding modes,
  we'll consider three rounding modes:
  round to nearest, ties to even (RNE),
  round toward zero (RTZ), and
  round away from zero (RAZ).

If $$f(x)$$ is representable in the target number format,
  then no more work is needed: $$f^{*}(x) = f(x)$$.
Otherwise,
  $$f(x)$$ lies between two representable floating-point numbers,
  which we'll denote as $$y_1 < f(x) < y_2$$.
To simplify the discussion,
  let's assume that $$y_1$$ and $$y_2$$ are both positive,
  and that $$y_1$$ has an even significand $$1\ldots0$$
  and $$y_2$$ has an odd significand $$1\ldots1$$.

The rules for each rounding mode are as follows:

- RNE: round to the _nearest_ representable number;
  if $$f(x)$$ is exactly halfway between $$y_1$$ and $$y_2$$,
  round to the one with an _even_ significand $$c$$.
- RTZ: round toward zero, round to $$y_1$$.
- RAZ: round away from zero, round to $$y_2$$.

Let's first assume that $$f(x)$$ is closer to $$y_1$$
  than to $$y_2$$.

![rounding when $$f(x)$$ is closer to $$y_1$$](/assets/posts/2025-11-18-round-to-odd/round-1.png){:style="display:block; margin-left:auto; margin-right:auto"}

In this case,
  $$f(x)$$ rounds to
- RNE: $$y_1$$ since $$y_1$$ is the nearest representable number,
- RTZ: $$y_1$$ since $$y_1$$ is in the direction of zero,
- RAZ: $$y_2$$ since $$y_1$$ is in the opposite direction.

Now, let's assume that $$f(x)$$ is closer to $$y_2$$
  than to $$y_1$$.

![rounding when $$f(x)$$ is closer to $$y_2$$](/assets/posts/2025-11-18-round-to-odd/round-2.png){:style="display:block; margin-left:auto; margin-right:auto"}

The only difference is that $$f(x)$$ rounds to $$y_2$$
  under RNE, since $$y_2$$ is now the nearest representable number.

Finally,
  let's consider the case where $$f(x)$$
  is exactly halfway between $$y_1$$ and $$y_2$$.

![rounding when $$f(x)$$ is equidistant to $$y_1$$ and $$y_2$$](/assets/posts/2025-11-18-round-to-odd/round-3.png){:style="display:block; margin-left:auto; margin-right:auto"}

Rounding under RNE
  will tie-break to the even significand,
  in this case, $$y_1$$.
Under RTZ and RAZ,
  the result is the same as before:
  RTZ rounds to $$y_1$$ and RAZ rounds to $$y_2$$.

Other rounding modes like
  round to nearest, ties away from zero (RNA),
  round to positive infinity (RTP),
  and round to negative infinity (RTN)
  can be analyzed similarly.
RNA is similar to RNE,
  except that it tie-breaks to the representable
  value away from zero.
RTP rounds towards positive infinity:
  it is the same as RAZ for positive numbers,
  and RTN is the same as RTZ for positive numbers.
RTN is the opposite of RTP.

## Round-to-Odd

Round to odd is only a slight adaptation
  of the rounding modes we've seen so far.
Like before,
  if $$f(x)$$ is representable in the target number format,
  then no rounding is required: $$f^{*}(x) = f(x)$$.
Otherwise,
  $$f(x)$$ lies between two representable floating-point numbers,
  which we'll again denote as $$y_1 < f(x) < y_2$$.
Under RTO,
  we round to the representable number
  with an _odd_ significand $$c$$.
In our example,
  this means that we always round to $$y_2$$.

![rounding $$f(x)$$ under RTO](/assets/posts/2025-11-18-round-to-odd/round-4.png){:style="display:block; margin-left:auto; margin-right:auto"}

Like RTZ and RAZ,
  any value between $$y_1$$ and $$y_2$$
  rounds to the same result,
  in this case, $$y_2$$.
On this example,
  round to odd doesn't seem too interesting.

However,
  examining its behavior on a different
  example reveals a key property of RTO.
Let's zoom out
  and consider the next representable floating-point number
  after $$y_2$$, which we'll denote as $$y_3$$.
In a floating-point number format
  with one fewer bits of precision $$p - 1$$,
  $$y_1$$ and $$y_3$$ would be adjacent representable numbers,
  and $$y_2$$ would be the midpoint between them.
Rounding with the original precision $$p$$,
  _any_ $$f(x)$$ between $$y_1$$ and $$y_3$$,
  rounds to $$y_2$$ under RTO.

![rounding $$f(x)$$ between $$y_1$$ and $$y_3$$ under RTO](/assets/posts/2025-11-18-round-to-odd/round-5.png){:style="display:block; margin-left:auto; margin-right:auto"}

Notice that under precision $$p$$,
  $$y_1$$ and $$y_3$$ have even significands,
  while $$y_2$$ has an odd significand.
Thus,
  the parity of the significand encodes
  whether the infinitely precise result $$f(x)$$
  is representable in the lower precision $$p - 1$$:
  the significand of $$f^{*}(x)$$ is odd if and only if
  $$f(x)$$ is not representable in precision $$p - 1$$.
In floating-point literature,
  the lowest significant bit of the significand
  is often called the _sticky bit_.

There are a few interpretations of the sticky bit.
If we expand the (possibly infinite) significand
  of $$f(x)$$ as $$1X\ldots XYYY\ldots$$
  where $$1X\ldots X$$ are the first $$p - 1$$ bits
  and $$YYY\ldots$$ are the trailing digits,
  then the sticky bit $$S$$ summarizes the trailing digits:

$$
S = \begin{cases}
0 & \text{if } YYY\ldots = 0, \\
1 & \text{if } YYY\ldots \neq 0;
\end{cases}
$$

and the significand
  may be written as $$1X\ldots XS$$,
  which is the significand of either
  $$y_1$$ (if $$S = 0$$) or $$y_2$$ (if $$S = 1$$).
Alternatively,
  we may view the simplified significand as an interval $$I$$:
  if $$S = 0$$, then $$c = 1X\ldots X0$$
  and $$I = [c, c]$$;
  if $$S = 1$$, then $$c = 1X\ldots X1$$
  and $$I = (c, c + \varepsilon)$$,
  where $$\varepsilon$$ is the distance to
  the next representable floating-point number
  with precision $$p - 1$$.
Or,
  rather than an interval,
  we can choose an unknown real value $$c \in I$$;
  we cannot capture the exact value of $$f(x)$$
  since the sticky bit destructively summarizes
  the trailing digits.

This sticky bit is essential
  when implementing correct rounding
  in both hardware and software.
Depending on the rounding mode,
  we must _approximate_ the infinitely precise result $$f(x)$$
  with $$p$$ significant digits;
  sufficiently many additional digits,
  usually one or two extra digits;
  and a sticky bit to summarize
  the remaining trailing digits.
Notice that the initial truncation
  with a sticky bit may be viewed
  as a round to odd operation with higher precision;
  this observation hints at a key property
  of round to odd, highlighted in the next section.

## Properties of Round-to-Odd

Boldo at Melquiond [2]
  identify several properties of round to odd.
It's worth summarizing them here.
The first four are properties shared
  with other standard rounding modes:

- round to odd is _entire_ - every real number can be rounded to odd;
- round to odd is _unique_ - every real number has a unique rounding to odd;
- round to odd is _monotonic_ - if $$x_1 < x_2$$,
  then $$\mathrm{rnd}^{p}_{\text{RTO}}(x_1) \leq \mathrm{rnd}^{p}_{\text{RTO}}(x_2)$$;
- round to odd is _faithful_ - if $$y_1 < x < y_2$$
  are the two representable numbers of precision $$p$$ surrounding $$f(x)$$,
  then $$\mathrm{rnd}^{p}_{\text{RTO}}(x)$$ is either $$y_1$$ or $$y_2$$;

The first three properties are fairly straightforward:
  we want to round any real number;
  we want the rounding to be deterministic;
  and we want rounding to preserve order.
The fourth property, faithfulness,
  ensures that rounding does not introduce
  large errors:
  if $$\varepsilon$$ is the distance
  between $$y_1$$ and $$y_2$$,
  then the rounding error is at most $$\varepsilon$$;
  for nearest rounding modes,
  the rounding error is at most $$\varepsilon / 2$$.

Additionally,
  round to odd is _symmetric_ :
  for any real number $$x$$,

$$
\mathrm{rnd}^{p}_{\text{RTO}}(-x) = -\mathrm{rnd}^{p}_{\text{RTO}}(x).
$$


Boldo and Melquiond's key observation
  is that round to odd is _safe for re-rounding_
  at lower precision.
To understand this finding,
  we return to the previous examples.




## References

[1] IEEE. 2019. IEEE Standard for Floating-Point Arithmetic. IEEE Std 754-2019 (Revision of IEEE 754-2008), 1–84. DOI: [https://doi.org/10.1109/IEEESTD.2019.8766229](https://doi.org/10.1109/IEEESTD.2019.8766229).

[2] Sylvie Boldo, Guillaume Melquiond. When double rounding is odd. 17th IMACS World Congress,
Jul 2005, Paris, France. pp.11. ffinria-00070603v2f.

[3] Nicolas Brisebarre, Guillaume Hanrot, Jean-Michel Muller, and Paul Zimmermann. 2025. Correctly Rounded
Evaluation of a Function: Why, How, and at What Cost?. ACM Comput. Surv. 58, 1, Article 27 (September 2025),
34 pages. [https://doi.org/10.1145/3747840](https://doi.org/10.1145/3747840).
