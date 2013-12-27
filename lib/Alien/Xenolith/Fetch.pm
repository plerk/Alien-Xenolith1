package Alien::Xenolith::Fetch;

use strict;
use warnings;
use base qw( Alien::Xenolith::Base );
use File::Path qw( mkpath );

# ABSTRACT: Base class for Xenolith fetch classes
# VERSION

=head1 METHODS

=head2 list

 my @list = $fetch->list;

Returns a list of possible archives.

=cut

sub list { () }

=head2 fetch_tempdir

 my $tempdir = $self->tempdir;
 $self->tempdir($tempdir);

Get or set the temporary directory used by the fetch classes.

=cut

my $fetch_tempdir;

sub fetch_tempdir
{
  my($class, $value) = @_;
  $fetch_tempdir = $value if defined $value;
  $fetch_tempdir = File::Spec->catdir("_xenolith", "fetch") unless defined $fetch_tempdir;
  mkpath $fetch_tempdir, 1, 0700;
  $fetch_tempdir;
}

1;
