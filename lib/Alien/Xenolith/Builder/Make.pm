package Alien::Xenolith::Builder::Make;

use strict;
use warnings;
use base qw( Alien::Xenolith::Builder );
use Alien::Xenolith::Base;

with 'Alien::Xenolith::Role::Make';

# ABSTRACT: Makefile builder class for Xenolith
# VERSION

=head1 METHODS

=head2 new

 my $builder = Alien::Xenolith::Builder::Make->new;

Creats a new instance of the make builder.

=cut

sub new
{
  my($class, %args) = @_;
  my $self = $class->SUPER::new(%args);
  $self;
}

=head2 build

 $builder->build;

Runs make.

=cut

sub build
{
  my($self) = @_;
  $self->run('PREFIX=' . $self->prefix);
}

=head2 run

 $builder->run(@arguments);

Runs make with the given arguments;

=cut

sub run
{
  my($self, @args) = @_;
  $self->make(@args);
}

1;
