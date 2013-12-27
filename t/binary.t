use strict;
use warnings;
use Test::More;
use Alien::Xenolith::Builder::Binary;
use File::Spec;
use File::Path qw( mkpath );
use File::Temp qw( tempdir );
use Capture::Tiny qw( capture_merged );;

plan tests => 14;

my $dir = tempdir( CLEANUP => 1 );
note "dir = $dir";

my $build_dir = File::Spec->catdir($dir, 'build');
my $stage_dir = File::Spec->catdir($dir, 'stage');

mkpath $_, 0, 0700 for ($build_dir,$stage_dir);

my @dirs = (['bin'],['lib'],['include'],['share','man','man1'],['share','man','man3']);

mkpath(File::Spec->catdir($build_dir, @$_), 0, 0755)
  for (@dirs);

my @files = (['bin', 'foo.exe'], ['bin', 'bar.exe'], ['lib', 'libfoo.a'], ['include', 'foo.h'], ['share', 'man', 'man1', 'foo.1'], ['share', 'man', 'man1', 'bar.1']);

foreach my $file (@files)
{
  my $fn = File::Spec->catfile($build_dir, @$file);
  open my $fh, '>', $fn;
  close $fn;
}

#note `ls -lR $build_dir`;

my $builder = Alien::Xenolith::Builder::Binary->new(
  build_dir => $build_dir
);

isa_ok $builder, 'Alien::Xenolith::Builder::Binary';

my $error;

note capture_merged {
  eval { $builder->build };
  $error = $@;
};
is $error, '', 'build';

note capture_merged {
  eval { $builder->stage($stage_dir) };
  $error = $@;
};
is $error, '', 'build';

foreach my $dir (map { File::Spec->catdir($stage_dir, @$_) } @dirs)
{
  ok -d $dir, "dir exists $dir";
}

foreach my $file (map { File::Spec->catfile($stage_dir, @$_) } @files)
{
  ok -r $file, "file exists $file";
}
