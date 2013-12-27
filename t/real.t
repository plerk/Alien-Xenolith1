use strict;
use warnings;
use FindBin;
use File::Spec;
use File::Temp qw( tempdir );
use Test::More tests => 2;
use Alien::Xenolith::Fetch;

sub note_needs ($)
{
  my($class) = @_;
  
  my $needs = $class->_needs_hash;
  
  foreach my $name (sort keys %$needs)
  {
    note sprintf "needs %-20s = %s\n", $name, $needs->{$name};
  }
}

Alien::Xenolith::Fetch->fetch_tempdir(tempdir( CLEANUP => 1 ));

foreach my $type (qw( File FTP ))
{
  subtest $type => sub {
    if($type eq 'File')
    {
      plan skip_all => 'test requires Sort::Versions'
        unless eval q{ use Sort::Versions; 1 };
      plan skip_all => 'test requires Archive::Extract'
        unless eval q{ use Archive::Extract; 1 };
    }
    elsif($type eq 'FTP')
    {
      plan skip_all => 'test requires Net::FTP'
        unless eval q{ use Net::FTP; 1 };
      plan skip_all => 'test requires URI'
        unless eval q{ use URI; 1 };
      plan skip_all => 'test requires an FTP server (set ALIEN_XENOLITH_DEV_TEST_FTP to the correct URI)'
        unless $ENV{ALIEN_XENOLITH_DEV_TEST_FTP};
    }
    plan tests => 5;

    use_ok "Alien::Xenolith::Fetch::$type";

    note_needs "Alien::Xenolith::Fetch::$type";

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
      
        my $fetch;
        if($type eq 'File')
        {
          $fetch = Alien::Xenolith::Fetch::File->new(
            dir         => $dir,
            filter      => $filter,
          );
        }
        elsif($type eq 'FTP')
        {
          $fetch = Alien::Xenolith::Fetch::FTP->new(
            uri         => $ENV{ALIEN_XENOLITH_DEV_TEST_FTP},
            filter      => $filter,
          );
        }
      
        isa_ok $fetch, 'Alien::Xenolith::Fetch';

        eval { $fetch->_init };
        is $@, '', '_init';

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
      my $fetch;
      if($type eq 'File')
      {
        $fetch = Alien::Xenolith::Fetch::File->new(
          dir         => $dir,
          filter      => 'libbar',
        );
      }
      elsif($type eq 'FTP')
      {
        $fetch = Alien::Xenolith::Fetch::FTP->new(
          uri         => $ENV{ALIEN_XENOLITH_DEV_TEST_FTP},
          filter      => 'libbar',
        );
      }
    
      isa_ok $fetch, 'Alien::Xenolith::Fetch';

      my $extract_location = tempdir( CLEANUP => 1 );
    
      is $fetch->extract('libbar-1.2.3.tar.gz', $extract_location), $extract_location, 'extract';
    };
  };
}
