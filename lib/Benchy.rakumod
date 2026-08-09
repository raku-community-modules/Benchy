my &colored = Nil === (try require Terminal::ANSIColor)
  ?? sub (Str:D $s, $) { $s }  # UNCOVERABLE
  !! ::('Terminal::ANSIColor::EXPORT::DEFAULT::&colored');  # UNCOVERABLE

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

sub EXPORT {
    with $*LANG {
        .set_pragma('MONKEY-GUTS',        1);
        .set_pragma('MONKEY-SEE-NO-EVAL', 1);
        .set_pragma('MONKEY-TYPING',      1);
    }
    Map.new: '&b' => &b
}

# vim: expandtab shiftwidth=4
