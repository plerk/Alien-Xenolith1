package Alien::Xenolith::Builder::Make;

use strict;
use warnings;
use base qw( Alien::Xenolith::Builder );
use Alien::Xenolith::Base;

with 'Alien::Xenolith::Role::Make';

# ABSTRACT: Makefile builder class for Xenolith
# VERSION

sub new
{
  my($class, %args) = @_;
  my $self = $class->SUPER::new(%args);
  $self;
}

sub build
{
  my($self) = @_;
  $self->make;
}

1;
