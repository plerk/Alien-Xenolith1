package Alien::Xenolith::Base;

use strict;
use warnings;
use Carp qw( croak );
use File::Spec;

# ABSTRACT: base class for Xenolith installer and fetch classes
# VERSION

=head1 METHODS

=head2 new

Creates an new instance of the class.  

=cut

sub new
{
  my $class = shift;
  croak "cannot create instance of abstract class"
    if $class =~ /^Alien::Xenolith::(Fetch|Installer|Base)$/;
  bless {}, $class;
}

=head2 requires

Returns a hash reference of requirements for this installer
or fetch class.  They keys are the package names and the 
values are the version numbers.

=cut

sub requires
{
  return {};
}

=head2 init

Loads the modules specified by the requires method.

=cut

sub init
{
  foreach my $class (keys %{ shift->requires })
  {
    my @filename = split /::/, $class;
    $filename[-1] .= '.pm';
    my $filename = File::Spec->catfile(@filename);
    require $filename;
  } 
}

1;
