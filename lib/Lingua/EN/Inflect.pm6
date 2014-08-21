use Lingua::EN::Numbers::Ordinal;
use Lingua::EN::Inflect::Map;

class Lingua::EN::Inflect does Callable;
has %.config is rw = :names;
has $.number is rw = 2;
has $.map handles /def_/ = Lingua::EN::Inflect::Map.new;

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
    my sub postprocess ($orig, $inflected is copy) {
        $inflected ~~ s[(<-[|]>+) \| (.+)] = $/[so %!config<all>];
        given $orig {
            when /^I$/         { $inflected } # XXX What?
            when /^<:Upper>+$/ { uc $inflected }
            when /^<:Upper>/   { tc $inflected }
            default { $inflected }
        }
    }
}

my &return-first = -> @_ { for @_ -> $b { if $b -> $_ { return $_ } } }

method noun ($word, $count = $.count) {
    return $word if $count == 1;
    my $value;

    # HANDLE USER-DEFINED NOUNS

    return $value if defined $value = $!map.ud_match($word);

    # HANDLE EMPTY WORD, SINGULAR COUNT AND UNINFLECTED PLURALS

    return $word if $word eq ''
        or ($!map.sb_uninflected($word) and $!map.sb_irregular{$word}:!exists and $!map.sb_lese_lesen($word))
        or (%!config<herd> and $!map.sb_uninflected_herd($word));

    # XXX Move more of this to …::Map.pm6 ?

    # HANDLE ISOLATED IRREGULAR PLURALS
    # HANDLE COMPOUNDS ("Governor General", "mother-in-law", "aide-de-camp", ETC.)
    # HANDLE PRONOUNS
    return-first map -> $w { $!map."map_$w"($word) }, qw{
        sb_irregular
        sb_postfix_adj sb_prep_dual_compound sb_prep_compound
        prep_pron_acc pron_nom pron_acc
    };

    # HANDLE FAMILIES OF IRREGULAR PLURALS
    if $word ~~ /:i(.*<|w><{$!map.sb_U_man_mans_posts}>)$/ {"$0s"}
    if $word ~~ /:i(.*<{$!map.sb_U_man_mans}>)$/ {"$0s"}

    # Replace one postfix with another
    map -> $r0, $r1, $s { if $word ~~ /:i (<{$r0}>) $r1 $/ { return "$0$s" } },
        <(\S*) quy quies>,
        <(\S*) person>, %!config<persons> ?? "persons" !! "people",
        <(.*) man men>,
        <(.*<[ml]>) ouse ice>,
        <(.*) goose geese>,
        <(.*) tooth teeth>,
        <(.*) foot feet>,
    ;

    # HANDLE UNASSIMILATED IMPORTS

    # XXX Abstractify (Grammar?)
    return-first do given $word {
        when /:i (.*)ceps$/         {$word}
        when /:i (.*)zoon$/         {"$0zoa"}
        when /:i (.*<[csx]>)is$/    {"$0es"}
        when /:i (.*<{$!map.sb_U_a_ata}>)a$/      {"$0ata"}
        when /:i (.*<{$!map.sb_U_is_ides}>)is$/   {"$0ides"}
        when /:i (.*<{$!map.sb_U_ch_chs}>)ch$/    {"$0chs"}
        when /:i (.*<{$!map.sb_U_ex_ices}>)ex$/   {"$0ices"}
        when /:i (.*<{$!map.sb_U_ix_ices}>)ix$/   {"$0ices"}
        when /:i (.*<{$!map.sb_U_um_a}>)um$/      {"$0a"}
        when /:i (.*<{$!map.sb_U_us_i}>)us$/      {"$0i"}
        when /:i (.*<{$!map.sb_U_on_a}>)on$/      {"$0a"}
        when /:i (.*<{$!map.sb_U_a_ae}>)$/        {"$0e"}
        when /:i (.*<{$!map.sb_lese_lesen}>)$/    {"$0n"}

        # HANDLE INCOMPLETELY ASSIMILATED IMPORTS
        if %!config<ancient> {
            when /:i (.*)trix$/         {"$0trices"}
            when /:i (.*)eau$/          {"$0eaux"}
            when /:i (.*)ieu$/          {"$0ieux"}
            when /:i (..+<[yia]>)nx$/   {"$0nges"}
            when /:i (.*<{$!map.sb_C_en_ina}>)en$/  {"$0ina"}
            when /:i (.*<{$!map.sb_C_ex_ices}>)ex$/ {"$0ices"}
            when /:i (.*<{$!map.sb_C_ix_ices}>)ix$/ {"$0ices"}
            when /:i (.*<{$!map.sb_C_um_a}>)um$/    {"$0a"}
            when /:i (.*<{$!map.sb_C_us_i}>)us$/    {"$0i"}
            when /:i (.*<{$!map.sb_C_us_us}>)$/     {"$0"}
            when /:i (.*<{$!map.sb_C_a_ae}>)$/      {"$0e"}
            when /:i (.*<{$!map.sb_C_a_ata}>)a$/    {"$0ata"}
            when /:i (.*<{$!map.sb_C_is_ides}>)is$/ {"$0ides"}
            when /:i (.*<{$!map.sb_C_o_i}>)o$/      {"$0i"}
            when /:i (.*<{$!map.sb_C_on_a}>)on$/    {"$0a"}
            when /:i <{$!map.sb_C_im}>$/    {"{$word}im"}
            when /:i <{$!map.sb_C_i}>$/     {"{$word}i"}
        }

        # HANDLE SINGULAR NOUNS ENDING IN ...s OR OTHER SILIBANTS

        when /:i ^(<{$!map.sb_singular_s}>)$/ {"$1es"}
        if %!config<names> {
            when /^(<[A..Z]>.*s)$/ {"$1es"}
        }
        when /:i ^(<{$!map.sb_z_zes}>)$/          {"$1es"}
        when /:i ^(.*<-[z]>)(z)$/           {"$1zzes"}
        when /:i ^(.*)(<[cs]>h|x|zz|ss)$/   {"$1$2es"}
        # when /:i (.*)(us)$/ {"$1$2es"}

        # HANDLE ...f -> ...ves

        when /:i (.*<[eao]>)lf$/    {"$1lves"}
        when /:i (.*<-[d]>)eaf$/    {"$1eaves"}
        when /:i (.*<[nlw]>)ife$/   {"$1ives"}
        when /:i (.*)arf$/          {"$1arves"}

        # HANDLE ...y

        when /:i (.*<[aeiou]>)y$/ {"$1ys"}
        if %!config<names> {
            when /(<[A..Z]>.*y)$/ {"$1s"}
        }
        when /:i (.*)y$/ {"$1ies"}

        # HANDLE ...o

        when /:i <{$!map.sb_U_o_os}>$/    {"{$word}s"}
        when /:i <[aeiou]>o$/       {"{$word}s"}
        when /:i o$/                {"{$word}es"}


        # OTHERWISE JUST ADD ...s

        default {"{$word}s"};
    }
}

## Infixes (move to own file?)

multi infix:<pl-eq> ($a, $b) { pl_eq($a, $b, :n) || pl_eq($a, $b, :v) || pl_eq($a, $b, :adj) }
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
    my &pl = { inflect $_, &inflect.number, |%by }

    given * {
        when $word1 eq $word2     { "eq"  }

        &inflect.classical;
        when $word1 eq pl($word2) { "p:s" }
        when pl($word1) eq $word2 { "s:p" }

        &inflect.config = ();
        when $word1 eq pl($word2) { "p:s" }
        when pl($word1) eq $word1 { "s:p" }

        when %by<n> and &inflect.check-plurals($word1, $word2, :n)
                     || &inflect.check-plurals($word2, $word1, :n)
            { "p:p" }
        when %by<adj> and &inflect.check-plurals($word1, $word2, :adj)
            { "p:p" }
    }
}

