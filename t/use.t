use strict;
use warnings;
use Test::More tests => 10;

use_ok 'Alien::Xenolith';
use_ok 'Alien::Xenolith::Base';
use_ok 'Alien::Xenolith::Installer';
use_ok 'Alien::Xenolith::Installer::Autoconf';
use_ok 'Alien::Xenolith::Installer::Make';
use_ok 'Alien::Xenolith::Installer::CMake';
use_ok 'Alien::Xenolith::Fetch';
use_ok 'Alien::Xenolith::Fetch::FTP';
use_ok 'Alien::Xenolith::Fetch::HTTP';
use_ok 'Alien::Xenolith::Fetch::File';
