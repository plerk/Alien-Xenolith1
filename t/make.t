use strict;
use warnings;
use Test::More;
use Alien::Xenolith::Builder::Make;
use File::Temp qw( tempdir );
use Config;
use File::chdir;
use Capture::Tiny qw( capture_merged );;

eval '# line '. __LINE__ . ' "' . __FILE__ . qq("\n) . q{
  local $CWD = tempdir( CLEANUP => 1 );
  my $fh;
  open($fh, '>', 'Makefile');
  print $fh "all:\n";
  print $fh "\tperl -e 'exit 0'\n";
  close $fh;
  capture_merged {
    system $Config{make}, 'all';
    die unless $? == 0;
  };
};
plan skip_all => "test requires a working make: $@" if $@;
plan tests => 4;

my $dir = tempdir( CLEANUP => 1 );
note "dir = $dir";

do {
  my $fh;
  open($fh, '>', File::Spec->catfile($dir, 'Makefile'));
  print $fh <<EOF;
all:
	perl -e 'print "all"' > all.txt

install:
	perl -e 'print "install:" . shift \@ARGV' \$(DEST_DIR) > install.txt

EOF
  close $fh;
};

my $builder = Alien::Xenolith::Builder::Make->new(
  build_dir => $dir,
);

isa_ok $builder, 'Alien::Xenolith::Builder::Make';

my $error;
my $out;

$out = capture_merged {
  eval { $builder->build };
  $error = $@;
};
is $error, '', 'build';
if($error)
{
  diag $out;
  diag $error;
}

$out = capture_merged {
  eval { $builder->stage('/foo/bar') };
  $error = $@;
};
is $error, '', 'stage';
if($error)
{
  diag $out;
  diag $error;
}

my $data = do {
  my $fh;
  open($fh, '<', File::Spec->catfile($dir, 'install.txt'));
  my $data = <$fh>;
  close $fh;
  $data;
};

is $data, 'install:/foo/bar', 'DEST_DIR';
