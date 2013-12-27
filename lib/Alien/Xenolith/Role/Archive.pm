package Alien::Xenolith::Role::Archive;

use strict;
use warnings;
use Alien::Xenolith::Base;

# ABSTRACT: Machinery for Xenolith fetch classes that use archives
# VERSION

needs 'Sort::Versions' => 0;

sub _versioncmp ($$)
{
  my($a,$b) = @_;
  $a =~ s/^.*?(\d)/$1/;
  $b =~ s/^.*?(\d)/$1/;
  Sort::Versions::versioncmp($a,$b);
}

around list => sub 
{
  my($orig, $self) = @_;
  sort { _versioncmp($a,$b) } $self->$orig;
};

1;
