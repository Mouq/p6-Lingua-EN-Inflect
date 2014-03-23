use Lingua::EN::Numbers::Ordinal;

class Lingua::EN::Inflect does Callable[Str];
has %.config is rw = :names;
has $.number is rw;

method modern {
    %!config = :names
}
method classical {
    %!config = :all, :zero, :herd, :names, :persons, :ancient
}

method postcircumfix:<( )> (|p) { $.inflect(|p) }

our sub infix:<pl-eq> ($a, $b) is equiv(&[eq]) is export { ... }
our sub infix:<pl-cmp> ($a, $b) is equiv(&[eq]) is export { ... }

# 0. PERFORM GENERAL INFLECTIONS IN A STRING

# Assume pluralization is meant
multi method inflect ($str, Int $count = $.number // 2,
                      :plural(:$pl), :verb(:$v),
                      :adjective(:$adj), :noun($n))
{
    die "Too many parts of speech!" if all $v, $adj, $n;

    $str.Str ~~ /^ (\s*) (.+?) (\s*) $/;
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
    return $pre.$plural.$post;

    #= FIX PEDANTRY AND CAPITALIZATION :-)
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
