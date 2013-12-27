package Alien::Xenolith::Builder;

use strict;
use warnings;
use base qw( Alien::Xenolith::Base );
use Carp qw( croak );

# ABSTRACT: Base class for Xenolith builders
# VERSION

sub new
{
  my($class, %args) = @_;
  my $dir = delete $args{build_dir};
  my $self = $class->SUPER::new(%args);
  $self->{build_dir} = $dir || croak "requires build_dir";
  $self;
}

sub build_dir
{
  shift->{build_dir};
}

1;

