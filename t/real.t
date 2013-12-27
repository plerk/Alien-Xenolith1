use strict;
use warnings;
use FindBin;
use File::Spec;
use File::Temp qw( tempdir );
use Test::More tests => 1;

subtest 'File' => sub {
  plan skip_all => 'test requires Sort::Versions'
    unless eval q{ use Sort::Versions; 1 };
  plan skip_all => 'test requires Archive::Extract'
    unless eval q{ use Archive::Extract; 1 };
  plan tests => 5;

  use_ok 'Alien::Xenolith::Fetch::File';

  my $dir = File::Spec->catdir($FindBin::Bin, File::Spec->updir, qw( corpus file ));
      
  note "dir = $dir";
      
  foreach my $testname ('regex filter', 'string filter', 'subref filter')
  {
    subtest $testname => sub {

      my $filter;
      if($testname eq 'regex filter')
      {
        $filter = qr/^libfoo-/;
      }
      elsif($testname eq 'string filter')
      {
        $filter = 'libfoo-';
      }
      elsif($testname eq 'subref filter')
      {
        $filter = sub { $_[0] =~ /^libfoo-/ };
      }
      else
      {
        die 'oops';
      }
    
      note "filter = $filter";
      
      my $fetch = Alien::Xenolith::Fetch::File->new(
        dir         => $dir,
        filter      => $filter,
      );
      
      isa_ok $fetch, 'Alien::Xenolith::Fetch::File';

      eval { $fetch->init };
      is $@, '', 'init';

      my @list = eval { $fetch->list };
      diag $@ if $@;
      is_deeply \@list, [qw( libfoo-1.2.3.tar.gz libfoo-1.3.2.tar.gz )], "list = libfoo-1.2.3.tar.gz libfoo-1.3.2.tar.gz";

      my $extract_location = tempdir( CLEANUP => 1 );
    
      is $fetch->extract('libfoo-1.3.2.tar.gz', $extract_location), File::Spec->catdir($extract_location, 'libfoo-1.3.2'), 'extract';

      my $version_file = File::Spec->catfile($extract_location, 'libfoo-1.3.2', 'VERSION.txt');
      
      ok -r $version_file, "file exists $version_file";
      
      open my $fh, '<', $version_file;
      my $version = do { local $/; <$fh> };
      close $fh;
      chomp $version;
      
      is $version, '1.3.2', 'version = 1.3.2';
    };
  }
  
  subtest 'rude archive' => sub
  {
    my $fetch = Alien::Xenolith::Fetch::File->new(
      dir         => $dir,
      filter      => 'libbar',
    );
    
    isa_ok $fetch, 'Alien::Xenolith::Fetch::File';

    my $extract_location = tempdir( CLEANUP => 1 );
    
    is $fetch->extract('libbar-1.2.3.tar.gz', $extract_location), $extract_location, 'extract';
  };
};
