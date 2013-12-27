use strict;
use warnings;
use Test::More;
use Alien::Xenolith::Builder::Autoconf;
use File::Temp qw( tempdir );
use Config;
use File::chdir;
use Capture::Tiny qw( capture_merged );;

plan skip_all => 'test requires Alien::MSYS on MSWin32'
  if $^O eq 'MSWin32' && ! eval q{ use Alien::MSYS; 1 };
plan tests => 4;

my $dir = tempdir( CLEANUP => 1 );
note "dir = $dir";

do {
  my $fh;
  open($fh, '>', File::Spec->catfile($dir, 'Makefile.stuff'));
  print $fh <<EOF;
all:
\tperl -e 'print "all"' > all.txt

install:
\tperl -e 'print "install:" . shift \@ARGV' \$(DEST_DIR) > install.txt

EOF
  close $fh;
  open($fh, '>', File::Spec->catfile($dir, 'configure'));
  print $fh "#!/bin/sh\n";
  print $fh "echo \$* > configure.args\n";
  print $fh "mv Makefile.stuff Makefile\n";
  close $fh;
  eval {
    chmod(0755, File::Spec->catfile($dir, 'configure'));
  };
};

my $builder = Alien::Xenolith::Builder::Autoconf->new(
  build_dir => $dir,
);

isa_ok $builder, 'Alien::Xenolith::Builder';

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

note do { 
  my $fh;
  open($fh, '<', File::Spec->catfile($dir, 'configure.args'));
  my $data = <$fh>;
  close $fh;
  "./configure $data";
};

my $data = do {
  my $fh;
  open($fh, '<', File::Spec->catfile($dir, 'install.txt'));
  my $data = <$fh>;
  close $fh;
  $data;
};

is $data, 'install:/foo/bar', 'DEST_DIR';

