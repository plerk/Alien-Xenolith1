use strict;
use warnings;
use Test::More tests => 6;
use Alien::Xenolith::Base;
use Alien::Xenolith::Fetch;
use Alien::Xenolith::Installer;

foreach my $class (map { "Alien::Xenolith::$_" } qw( Base Fetch Installer ))
{
  can_ok $class, '_init';
  eval { $class->new };
  like $@, qr{cannot create instance of abstract class}, "cannot create instance of $class";
}
