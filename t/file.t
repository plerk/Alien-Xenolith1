use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use testlib;
use Test::More tests => 3;
use File::Temp qw( tempdir );
use Alien::Xenolith::Fetch::File;
use File::Spec;

my $dir = tempdir( CLEANUP => 1 );

note "dir = $dir";

sub touch ($)
{
  my $fn = File::Spec->catfile($dir,shift);
  open my $fh, '>', $fn;
  close $fh;
}

touch 'libfoo-1.2.3.tar.gz';
touch 'libbar-1.2.3.tar.gz';
touch 'libfoo-1.3.2.tar.gz';

foreach my $testname ('regex filter', 'string filter', 'subref filter')
{
  subtest $testname => sub
  {
    plan tests => 4;
    
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
    
    eval { $fetch->_init };
    is $@, '', '_init';

    my @list = eval { $fetch->list };
    diag $@ if $@;
    is_deeply \@list, [qw( libfoo-1.2.3.tar.gz libfoo-1.3.2.tar.gz )], "list = libfoo-1.2.3.tar.gz libfoo-1.3.2.tar.gz";

    my $extract_location = tempdir( CLEANUP => 1 );
    
    $fetch->extract('libfoo-1.3.2.tar.gz', $extract_location);

    extracted_to_ok $extract_location;
  };
  
}

