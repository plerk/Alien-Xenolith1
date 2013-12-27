package Alien::Xenolith::Fetch::FTP;

use strict;
use warnings;
use base qw( Alien::Xenolith::Fetch );
use Alien::Xenolith::Base;

# ABSTRACT: FTP fetch class for Xenolith
# VERSION

needs 'Net::FTP' => 0;

1;
