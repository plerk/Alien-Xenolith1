use strict;
use warnings;
use Test::More tests => 14;

use_ok 'Alien::Xenolith';
use_ok 'Alien::Xenolith::Base';
use_ok 'Alien::Xenolith::Builder';
use_ok 'Alien::Xenolith::Builder::Autoconf';
use_ok 'Alien::Xenolith::Builder::Make';
use_ok 'Alien::Xenolith::Builder::CMake';
use_ok 'Alien::Xenolith::Builder::Binary';
use_ok 'Alien::Xenolith::Fetch';
use_ok 'Alien::Xenolith::Fetch::FTP';
use_ok 'Alien::Xenolith::Fetch::HTTP';
use_ok 'Alien::Xenolith::Fetch::File';

use_ok 'Alien::Xenolith::Role::Archive';
use_ok 'Alien::Xenolith::Role::Filter';
use_ok 'Alien::Xenolith::Role::Make';
