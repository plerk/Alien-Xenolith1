package Alien::Xenolith::Fetch;

use strict;
use warnings;
use base qw( Alien::Xenolith::Base );

# ABSTRACT: Base class for Xenolith fetch classes
# VERSION

=head1 METHODS

=head2 list

 my @list = $fetch->list;

Returns a list of possible archives.

=cut

sub list { () }

1;
