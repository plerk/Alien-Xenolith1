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
  my $build_dir = delete $args{build_dir};
  my $prefix = delete $args{prefix};
  my $self = $class->SUPER::new(%args);
  $self->{build_dir} = $build_dir || croak "requires build_dir";
  $self->{prefix}  = $prefix;
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

=head2 prefix

 my $dir = $builder->prefix;

Returns the install directory.

=cut

sub prefix
{
  shift->{prefix};
}

1;

