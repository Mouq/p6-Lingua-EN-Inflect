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
