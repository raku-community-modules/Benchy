sub EXPORT {
    $*W.do_pragma(Match.new, 'MONKEY', 1, []);
    Map.new: '&b' => &b
}

my &colored = Nil === (try require Terminal::ANSIColor)
  ?? sub (Str:D $s, $) { $s }
  !! ::('Terminal::ANSIColor::EXPORT::DEFAULT::&colored');

my sub nano2Duration(Int:D $value is raw --> Nil) {
    $value = Duration.new($value / 1_000_000_000);
}

sub b(int $full-n, &old, &new, &bare = { $ = $ }, :$silent) {
    use nqp;

    my int $n = floor ½ × $full-n;
    my int $i;
    my int $now;
    my %times;

    $i = -1; $now = nqp::time();
    nqp::until(nqp::islt_i($n, $i = nqp::add_i($i, 1)), bare, :nohandler);
    %times<bare> = nqp::time() - $now;

    $i = -1; $now = nqp::time();
    nqp::until(nqp::islt_i($n, $i = nqp::add_i($i, 1)), old, :nohandler);
    %times<old> = nqp::time() - $now;

    $i = -1; $now = nqp::time();
    nqp::until(nqp::islt_i($n, $i = nqp::add_i($i, 1)), new, :nohandler);
    %times<new> = nqp::time() - $now;

    $i = -1; $now = nqp::time();
    nqp::until(nqp::islt_i($n, $i = nqp::add_i($i, 1)), bare, :nohandler);
    %times<bare> += nqp::time() - $now;

    $i = -1; $now = nqp::time();
    nqp::until(nqp::islt_i($n, $i = nqp::add_i($i, 1)), new, :nohandler);
    %times<new> += nqp::time() - $now;

    $i = -1; $now = nqp::time();
    nqp::until(nqp::islt_i($n, $i = nqp::add_i($i, 1)), old, :nohandler);
    %times<old> += nqp::time() - $now;

    with %times {
        .<bare> max= 0;
        .<new> -= .<bare>;
        .<old> -= .<bare>;
        .<new> max= 0;
        .<old> max= 0;

        # normalize from nano secs to seconds
        nano2Duration .<bare>;
        nano2Duration .<new>;
        nano2Duration .<old>;
    }

    unless $silent {
        say "Bare: %times<bare>s";
        say "Old:  %times<old>s";
        say "New:  %times<new>s";

        sub dif {
            my $d = [/] @_;
            $d >= 2
              ?? sprintf('%.2fx', $d)
              !! ($d = Int(100*($d-1)))
                ?? sprintf('%d%%', $d)
                !! 'slightly (<1%)'
        }
        say .<old>/.<new> > 1
          ?? colored("NEW version is &dif(.<old new>) faster", 'green')
          !! colored("OLD version is &dif(.<new old>) faster", 'red'  )
        with %times;
    }

    %times
}

=begin pod

=head1 NAME

Benchy - Benchmark some code

=head1 SYNOPSIS

=begin code :lang<raku>

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

=end code

=head1 DESCRIPTION

Takes 2 C<Callable>s and measures which one is faster. Optionally takes a 3rd
C<Callable> that will be run the same number of times as other two callables,
and the time it took to run will be subtracted from the other results.

=head1 EXPORTED PRAGMAS

=head2 MONKEY

The C<use> of this module enables C<MONKEY> pragma, so you can augment, use NQP,
EVAL, etc, without needing to specify those pragmas.

=head1 EXPORTED SUBROUTINES

=head2 b(int $n, &old, &new, &bare = { $ = $ }, :$silent)

Benches the codes and prints the results. Will print in colour, if
L<C<Terminal::ANSIColor>|https://modules.raku.org/repo/Terminal::ANSIColor>
is installed.

=head3 $n

How many times to loop.

Note that the exact number to loop will always be evened out, as the bench
splits the work into two chunks that are measured at different times, so
the total time is C<2 × floor ½ × $n>.

=head3 &old

Your "old" code; assumption is you have "old" code and you're trying
to write some "new" code to replace it.

=head3 &new

Your "new" code.

=head3 &bare

Optional (defaults to C<{ $ = $ }>). When specified, this C<Callable>
will be run same number of times as other code and the time it took to
run will be subtracted from the `&new` and `&old` times. Use this to
run some "setup" code. That is code that's used in C<&new> and C<&old>
but should not be part of the benched times.

=head3 :$silent

If set to a truthy value, the routine will not print anything.

=head3 returns

Returns a hash with three keys - C<bare>, C<new>, and C<old> — whose
values are C<Duration> objects representing the time it took the
corresponding C<Callable>s to run. B<NOTE:> the C<new> and C<old>
already have the duration of C<bare> subtracted from them.

=begin code :lang<raku>

{
    :bare(Duration.new(<32741983139/488599474770>)),
    :new(Duration.new(<167/956>)),
    :old(Duration.new(<1280561957330937733/590077351150947660>))
}

=end code

=head1 AUTHOR

Zoffix Znet

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Zoffix Znet

Copyright 2018 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
