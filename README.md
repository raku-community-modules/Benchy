[![Actions Status](https://github.com/raku-community-modules/Benchy/actions/workflows/test.yml/badge.svg)](https://github.com/raku-community-modules/Benchy/actions)

NAME
====

Benchy - Benchmark some code

SYNOPSIS
========

```raku
use Benchy;

b 20_000,  # number of times to loop
    { some-setup; my-old-code }, # your old version
    { some-setup; my-new-code }, # your new version
    { some-setup } # optional "bare" loop to eliminate setup code's time

# SAMPLE OUTPUT:
# Bare: 0.0606532677866851s
# Old:  2.170558s
# New:  0.185170s
# NEW version is 11.72x faster
```

DESCRIPTION
===========

Takes 2 `Callable`s and measures which one is faster. Optionally takes a 3rd `Callable` that will be run the same number of times as other two callables, and the time it took to run will be subtracted from the other results.

EXPORTED PRAGMAS
================

MONKEY
------

The `use` of this module enables `MONKEY` pragma, so you can augment, use NQP, EVAL, etc, without needing to specify those pragmas.

EXPORTED SUBROUTINES
====================

b(int $n, &old, &new, &bare = { $ = $ }, :$silent)
--------------------------------------------------

Benches the codes and prints the results. Will print in colour, if [`Terminal::ANSIColor`](https://modules.raku.org/repo/Terminal::ANSIColor) is installed.

### $n

How many times to loop.

Note that the exact number to loop will always be evened out, as the bench splits the work into two chunks that are measured at different times, so the total time is `2 × floor ½ × $n`.

### &old

Your "old" code; assumption is you have "old" code and you're trying to write some "new" code to replace it.

### &new

Your "new" code.

### &bare

Optional (defaults to `{ $ = $ }`). When specified, this `Callable` will be run same number of times as other code and the time it took to run will be subtracted from the `&new` and `&old` times. Use this to run some "setup" code. That is code that's used in `&new` and `&old` but should not be part of the benched times.

### :$silent

If set to a truthy value, the routine will not print anything.

### returns

Returns a hash with three keys - `bare`, `new`, and `old` — whose values are `Duration` objects representing the time it took the corresponding `Callable`s to run. **NOTE:** the `new` and `old` already have the duration of `bare` subtracted from them.

```raku
{
    :bare(Duration.new(<32741983139/488599474770>)),
    :new(Duration.new(<167/956>)),
    :old(Duration.new(<1280561957330937733/590077351150947660>))
}
```

AUTHOR
======

Zoffix Znet

COPYRIGHT AND LICENSE
=====================

Copyright 2017 Zoffix Znet

Copyright 2018 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

