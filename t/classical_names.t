use Lingua::EN::Inflect;
use Test;
plan *;

my &pl = Lingua::EN::Inflect.new;

# DEFAULT...

is pl('Sally'):n,        'Sallys';           # classical 'names' active
is pl('Jones', 0):n,     'Joneses';          # always inflects that way

# "person" PLURALS ACTIVATED...

&pl.config<names>++;
is pl('Sally'):n,        'Sallys';           # classical 'names' active
is pl('Jones', 0):n,     'Joneses';          # always inflects that way

# OTHER CLASSICALS NOT ACTIVATED...

is pl('wildebeest'):n,   'wildebeests';      # classical 'herd' not active
is pl('error', 0):n,     'errors';           # classical 'zero' not active
is pl('brother'):n,      'brothers';         # classical 'all' not active
is pl('person'):n,       'people';           # classical 'persons' not active
is pl('formula'):n,      'formulas';         # classical 'ancient' not active

# "person" PLURALS DEACTIVATED...

&pl.config<names>--;
is pl('Sally'):n,        'Sallies';          # classical 'names' not active
is pl('Jones', 0):n,     'Joneses';          # always inflects that way

