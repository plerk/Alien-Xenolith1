package Alien::Xenolith::Builder::Autoconf;

use strict;
use warnings;
use base qw( Alien::Xenolith::Builder );
use Alien::Xenolith::Base;
use File::chdir;

with 'Alien::Xenolith::Role::Make';

requires 'Alien::MSYS' => 0 if $^O eq 'MSWin32';

# ABSTRACT: Autoconf builder class for Xenolith
# VERSION

=head1 METHODS

=head2 new

 my $builder = Alien::Xenolith::Builder::Autoconf->new;

Create a new instance of the autoconf builder.

=cut

sub new
{
  my($class, %args) = @_;
  my $self = $class->SUPER::new(%args);
  $self;
}

=head2 build

 $builder->build;

runs ./configure and make

=cut

sub build
{
  my($self) = @_;
  do {
    local $CWD = $self->build_dir;
    system './configure', '--prefix=/foo';
    if($? == -1)
    { die "make failed to execute $!" }
    elsif($? & 127)
    { die "died with signal " . $? & 127 }
    elsif($?)
    { die "exited with return " . $? >> 8 }
  };
  $self->make;
}

1;
