use Lingua::EN::Numbers::Ordinal;

class Lingua::EN::Inflect does Callable;
has %.config is rw = :names;
has $.number is rw = 2;

method modern {
    %!config = :names
}
method classical {
    %!config = :all, :zero, :herd, :names, :persons, :ancient
}

## Standard ways to use Lingua::EN::Inflect
method invoke (|p) { $.inflect(|p) }

proto infix:<pl-eq>  ($a, $b) is equiv(&[eq])  is export { * }
proto infix:<pl-cmp> ($a, $b) is equiv(&[cmp]) is export { * }

# XXX Chaining ops can't have adverbs in Rakudo
multi infix:<eq>  ($a, $b, :plural(:$pl)!, |p) is export { &[pl-eq]\($a, $b, |p) }
multi infix:<cmp> ($a, $b, :plural(:$pl)!, |p) is export { &[pl-cmp]($a, $b, |p) }

# 0. PERFORM GENERAL INFLECTIONS IN A STRING

# Assume pluralization is meant
method inflect (Lingua::EN::Inflect:D:
                $str as Str, Int $count = $.number,
                :plural(:$pl), :verb(:$v),
                :adjective(:$adj), :noun(:$n))
{
    die "Too many parts of speech!" if any($v, $adj, $n) and not one($v, $adj, $n);

    $str ~~ /^ (\s*) (.+?) (\s*) $/;
    my ($pre, $word, $post) = @();
    return $str unless $word;

    my $plural = postprocess $word, do {
        if $n {
            $.noun($word, $count)
        } elsif $adj {
            $.special-adjective($word,$count)
        } elsif $v {
               $.special-verb($word,$count)
            || $.general-verb($word,$count)
        } else {
               $.special-adjective($word,$count)
            || $.special-verb($word,$count)
            || $.noun($word,$count)
        }
    }
    return $pre ~ $plural ~ $post;

    #| FIX PEDANTRY AND CAPITALIZATION :-)
    my sub postprocess ($orig, $inflected) {
        $inflected ~~ s[(<-[|]>+) \| (.+)] = $/[so %!config<all>];
        given $orig {
            when /^I$/         { $inflected } # XXX What?
            when /^<:Upper>+$/ { uc $inflected }
            when /^<:Upper>/   { tc $inflected }
            default { $inflected }
        }
    }
}

## Infixes (move to own file?)

multi infix:<pl-eq> ($a, $b) { pl_eq($a, $b, :n) || pl_eq($a, $b, :v) || pl_eq($a, $b :adj) }
multi infix:<pl-eq> ($a, $b, :noun(:$n)!) { so pl_eq($a, $b, :n) }
multi infix:<pl-eq> ($a, $b, :verb(:$v)!) { so pl_eq($a, $b, :v) }
multi infix:<pl-eq> ($a, $b, :adjective(:$adj)!) { so pl_eq($a, $b, :adj) }

# XXX Migrate parts of pl-eq to be pl-cmp
multi infix:<pl-cmp> ($a, $b) {
    X::NYI.new(:feature<pl-cmp>).throw;
}

# Improve return value
my sub pl_eq ($word1, $word2, %by?) {
    my &inflect = Lingua::EN::Inflect.new;
    my &pl = { inflect $_, $inflect.number, |%by }

    given * {
        when $word1 eq $word2     { "eq"  }

        $inflect.classical;
        when $word1 eq pl($word2) { "p:s" }
        when pl($word1) eq $word2 { "s:p" }

        $inflect.config = ();
        when $word1 eq pl($word2) { "p:s" }
        when pl($word1) eq $word1 { "s:p" }

        when %by<n> and $inflect.check-plurals($word1, $word2, :n)
                     || $inflect.check-plurals($word2, $word1, :n)
            { "p:p" }
        when %by<adj> and $inflect.check-plurals($word1, $word2, :adj)
            { "p:p" }
    }
}

