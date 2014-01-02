use strict;
use warnings;
use Test::More tests => 3;
use Alien::Xenolith::Recipe;

my $recipe = eval {
  Alien::Xenolith::Recipe->new(
    code => "fetch http { set uri => 'http://www.libarchive.org/downloads/'; build { configure; make; make 'install', 'DESTDIR=\${DESTDIR}'; install default; } };",
  );
};
diag $@ if $@;

isa_ok $recipe, 'Alien::Xenolith::Recipe';

like $recipe->_package, qr{^Alien::Xenolith::Recipe}, "package = " . $recipe->_package;

eval { $recipe->compile };
is $@, '', 'compile';

