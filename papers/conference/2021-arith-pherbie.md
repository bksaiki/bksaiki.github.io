---
layout: single
title: "Combining Precision Tuning and Rewriting"
permalink: /papers/conference/2021-arith-pherbie/
---

Authors: **Brett Saiki**, Oliver Flatt, Chandrakana Nandi, Pavel Panchekha, Zachary Tatlock

Venue: IEEE Symposium on Computer Arithmetic (ARITH) 2021

Links:
[Paper](https://herbie.uwplse.org/arith21-paper.pdf) |
[Talk](https://youtu.be/ytWhp0I8KVw)

## Abstract

Precision tuning and rewriting can improve both
the accuracy and speed of floating point expressions, yet these
techniques are typically applied separately. This paper explores
how finer-grained interleaving of precision tuning and rewriting
can help automatically generate a richer set of Pareto-optimal
accuracy versus speed trade-offs.

We introduce Pherbie (pareto Herbie), a tool providing both
precision tuning and rewriting, and evaluate interleaving these
two strategies at different granularities. Our results demonstrate
that finer-grained interleavings improve both the Pareto curve
of candidate implementations and overall optimization time. On
a popular set of tests from the FPBench suite, Pherbie finds
both implementations that are significantly more accurate for
a given cost and significantly faster for a given accuracy bound
compared to baselines using precision tuning and rewriting alone
or in sequence.


```
@INPROCEEDINGS{9603367,
  author={Saiki, Brett and Flatt, Oliver and Nandi, Chandrakana and Panchekha, Pavel and Tatlock, Zachary},
  booktitle={2021 IEEE 28th Symposium on Computer Arithmetic (ARITH)}, 
  title={Combining Precision Tuning and Rewriting}, 
  year={2021},
  volume={},
  number={},
  pages={1-8},
  keywords={Costs;Tools;Digital arithmetic;Tuning;Optimization;precision tuning;term rewriting;optimization},
  doi={10.1109/ARITH51176.2021.00013}}
```
