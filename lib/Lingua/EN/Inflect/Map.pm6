class Lingua::EN::Inflect::Map;

has %.ud_nouns{Any};
has %.ud_verbs{Any};
has %.ud_adjs{Any};
has %.ud_arts{Any};

method def_noun (Pair $p) { %.ud_nouns{$p.key} = $p.value }
method def_verb (Pair $p) { %.ud_verbs{$p.key} = $p.value }
method def_adj  (Pair $p) { %.ud_adjss{$p.key} = $p.value }
method def_a  ($w) { %.ud_arts<a>  = $w }
method def_an ($w) { %.ud_arts<an> = $w }
proto method ud_match ($word) {
    for {*}.kv -> $k, $v {
        if $word ~~ $k {
            return $v ~~ Callable ?? $v.($word) !! $v;
        }
    }
}
multi method ud_match ($word, :noun(:$n)!) { %.ud_nouns }
multi method ud_match ($word, :verb(:$v)!) { %.ud_nouns }
multi method ud_match ($word, :$article!)  { %.ud_nouns }
multi method ud_match ($word, :adjective(:$adj)!) { %.ud_nouns }

has %.sb_irregular_s =
    "corpus"          => <corpuses corpora>,
    "opus"            => <opuses opera>,
    "magnum opus"     => ("magnum opuses", "magna opera"),
    "genus"           => "genera",
    "mythos"          => "mythoi",
    "penis"           => <penises penes>,
    "testis"          => "testes",
    "atlas"           => <atlases atlantes>,
    "yes"             => "yeses",
    'editio princeps' => 'editiones principes',
    'starets'         => 'startsy',
    'staretz'         => 'startzy',
;
has %.sb_irregular =
    "child"       => "children",
    "brother"     => <brothers brethren>,
    "loaf"        => "loaves",
    "hoof"        => <hoofs hooves>,
    "beef"        => <beefs beeves>,
    "thief"       => <thiefs thieves>,
    "money"       => "monies",
    "mongoose"    => "mongooses",
    "ox"          => "oxen",
    "cow"         => <cows kine>,
    "graffito"    => "graffiti",
    "prima donna" => ("prima donnas", "prime donne"),
    "octopus"     => <octopuses octopodes>,
    "genie"       => <genies genii>,
    "ganglion"    => <ganglions ganglia>,
    "trilby"      => "trilbys",
    "turf"        => <turfs turves>,
    "numen"       => "numina",
    "atman"       => "atmas",
    "occiput"     => <occiputs occipita>,
    'sabretooth'  => 'sabretooths',
    'sabertooth'  => 'sabertooths',
    'lowlife'     => 'lowlifes',
    'flatfoot'    => 'flatfoots',
    'tenderfoot'  => 'tenderfoots',
    'Romany'      => 'Romanies',
    'romany'      => 'romanies',
    'Tornese'     => 'Tornesi',
    'Jerry'       => 'Jerrys',
    'jerry'       => 'jerries',
    'Mary'        => 'Marys',
    'mary'        => 'maries',
    'talouse'     => 'talouses',
    'blouse'      => 'blouses',
    'Rom'         => 'Roma',
    'rom'         => 'roma',
    'carmen'      => 'carmina',
    'cheval'      => 'chevaux',
    'chervonetz'  => 'chervontzi',
    'kuvasz'      => 'kuvaszok',
    'felo'        => 'felones',
    'put-off'     => 'put-offs',
    'set-off'     => 'set-offs',
    'set-out'     => 'set-outs',
    'set-to'      => 'set-tos',
    'brother-german' => <brothers-german brethren-german>,
    'studium generale' => 'studia generali',
 
    %!sb_irregular_s,
;
method map_sb_irregular ($word) {
    if %!sb_irregular{lc $word} -> $_ { return $_ }
    if $word ~~ state token {:i (.*) <|w> (<{%!sb_irregular.keys.sort.reverse}>) $} {
        return $0 ~ %!sb_irregular{lc $1}
    }
}

# Z's that don't double

has @.match_sb_z_zes = "batz", "quartz", "topaz", /snooz<?[e]>/, "kibbutz";

# UNCONDITIONAL "..man" -> "..mans"

has @.sb_U_man_mans_posts = qw{
    ataman desman dolman farman
    harman hetman leman
};
has @.sb_U_man_mans = qw{
    caiman cayman ceriman
    human ottoman shaman talisman
    Alabaman Bahaman Burman German
    Hiroshiman Liman Nakayaman Norman Oklahoman
    Panaman Roman Selman Sonaman Tacoman Yakiman
    Yokohaman Yuman
};

# UNCONDITIONAL "..is" -> "..ides"

has @.sb_U_is_ides = "aphis";
has @.match_sb_U_is_ides = map *.substr(0, *-2), @!sb_U_is_ides;

# CLASSICAL "..is" -> "..ides"

has @.sb_C_is_ides =
    # GENERAL WORDS...
    "ephemeris", "iris", "clitoris",
    "chrysalis", "epididymis",
    # INFLAMATIONS...
    ".*itis", 
;
has @.match_sb_C_is_ides = map *.substr(0, *-2), @!sb_C_is_ides;

# UNCONDITIONAL "..a" -> "..ata"

has @.match_sb_U_a_ata = "plasmalemma", "pseudostoma";

# CLASSICAL "..a" -> "..ata"

has @.sb_C_a_ata =
    "anathema", "bema", "carcinoma", "charisma", "diploma",
    "dogma", "drama", "edema", "enema", "enigma", "lemma",
    "lymphoma", "magma", "melisma", "miasma", "oedema",
    "sarcoma", "schema", "soma", "stigma", "stoma", "trauma",
    "gumma", "pragma", "bema",
;
has @.match_sb_C_a_ata = map *.substr(0, *-2), @!sb_C_a_ata;

# UNCONDITIONAL "..a" -> "..ae"

has @.match_sb_U_a_ae = "alumna", "alga", "vertebra", "persona";

# CLASSICAL "..a" -> "..ae"

has @.match_sb_C_a_ae  =
    "amoeba", "antenna", "formula", "hyperbola",
    "medusa", "nebula", "parabola", "abscissa",
    "hydra", "nova", "lacuna", "aurora", ".*umbra",
    "flora", "fauna",
;

# CLASSICAL "..en" -> "..ina"

has @.match_sb_C_en_ina = map *.substr(0, *-2), "stamen", "foramen", "lumen";

# UNCONDITIONAL "..um" -> "..a"

has @.match_sb_U_um_a = map *.substr(0, *-2),
    "maximum",  "minimum",    "momentum",   "optimum",
    "quantum",  "cranium",    "curriculum", "dictum",
    "phylum",   "aquarium",   "compendium", "emporium",
    "enconium", "gymnasium",  "honorarium", "interregnum",
    "lustrum",  "memorandum", "millennium", "rostrum",
    "spectrum", "speculum",   "stadium",    "trapezium",
    "ultimatum",    "medium",   "vacuum",   "velum",
    "consortium",
;

# UNCONDITIONAL "..us" -> "i"

# XXX XXX XXX

