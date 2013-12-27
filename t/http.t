use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use testlib;
use Test::More;
use Alien::Xenolith::Fetch::HTTP;
use File::Temp qw( tempdir );

plan skip_all => 'requires HTML::Parser'
  unless eval q{ use HTML::Parser; 1 };
plan tests => 1;

Alien::Xenolith::Fetch->fetch_tempdir(tempdir( CLEANUP => 1 ));

subtest 'normal' => sub {

  my $fetch = Alien::Xenolith::Fetch::HTTP->new(
    uri => "http://foo.wdlabs.com/roger",
    filter => 'libfoo-',
  );

  isa_ok $fetch, 'Alien::Xenolith::Fetch::HTTP';

  my @list = $fetch->list;
  is_deeply \@list, [qw( libfoo-1.2.3.tar.gz libfoo-1.3.2.tar.gz )], "list = libfoo-1.2.3.tar.gz libfoo-1.3.2.tar.gz";
  
  my $extract_location = tempdir( CLEANUP => 1 );
    
  $fetch->extract('libfoo-1.3.2.tar.gz', $extract_location);

  extracted_to_ok $extract_location;

};
