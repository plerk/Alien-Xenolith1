package Alien::Xenolith::Builder;

use strict;
use warnings;
use base qw( Alien::Xenolith::Base );
use Carp qw( croak );

# ABSTRACT: Base class for Xenolith builders
# VERSION

=head1 METHODS

=head2 new

Creats a new instance of the builder.

=cut

sub new
{
  my($class, %args) = @_;
  my $dir = delete $args{build_dir};
  my $self = $class->SUPER::new(%args);
  $self->{build_dir} = $dir || croak "requires build_dir";
  $self;
}

=head2 build_dir

 my $dir = $builder->build_dir;

Returns the build directory.

=cut

sub build_dir
{
  shift->{build_dir};
}

1;

