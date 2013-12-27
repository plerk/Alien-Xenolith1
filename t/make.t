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
  open($fh, '>', 'Util.pm');
  print $fh "sub go { exit 0 }\n1;";
  close $fh;
  open($fh, '>', 'Makefile');
  print $fh "all:\n";
  print $fh "\tperl -MUtil -e go\n";
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
  open($fh, '>', File::Spec->catfile($dir, "Util.pm"));
  print $fh '# line '. __LINE__ . ' "' . __FILE__ . qq("\n) . <<EOF1;
    use strict;
    use warnings;
    my \$fh;
    open \$fh, '>', \$ARGV[0];
    sub print_all     { print \$fh "all" }
    sub print_install { print \$fh "install:\$ARGV[1]" }
EOF1
  close $fh;
  open($fh, '>', File::Spec->catfile($dir, 'Makefile'));
  print $fh <<EOF2;
all:
\tperl -MUtil -e print_all all

install:
\tperl -MUtil -e print_install install \$(DEST_DIR)

EOF2
  close $fh;
};

my $builder = Alien::Xenolith::Builder::Make->new(
  build_dir => $dir,
);

isa_ok $builder, 'Alien::Xenolith::Builder';

my $error;
my $out;

note capture_merged {
  eval { $builder->build };
  $error = $@;
};
is $error, '', 'build';

note capture_merged {
  eval { $builder->stage('/foo/bar') };
  $error = $@;
};
is $error, '', 'stage';

my $data = do {
  my $fh;
  open($fh, '<', File::Spec->catfile($dir, 'install'));
  my $data = <$fh>;
  close $fh;
  $data;
};

is $data, 'install:/foo/bar', 'DEST_DIR';

