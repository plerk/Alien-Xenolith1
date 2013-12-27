package Alien::Xenolith::Builder::Binary;

use strict;
use warnings;
use base qw( Alien::Xenolith::Builder );
use Alien::Xenolith::Base;
use File::Find qw( find );
use File::Copy qw( cp );

# ABSTRACT: Binary builder class for Xenolith
# VERSION

=head1 METHODS

=head2 build

 $builder->build;

For binary packages there is nothing to do for the build
step, so this method doesn't do anything, except print
out that it isn't doing anything.

=cut

sub build
{
  print "no build step\n";
}

=head2 stage

 $builder->stage($dir);

Stages (installs) the files to the given directory.

=cut

sub stage
{
  my($self, $dest) = @_;
  
  my $build_dir = $self->build_dir;
  
  find(sub {
    my $file = $_;
    return if $file =~ /^\.\.?$/;
    my $dir = $File::Find::dir;
    $dir =~ s/^$build_dir//;
    if(! -d $File::Find::name)
    {
      my $src = $File::Find::name;
      my $dst = File::Spec->catfile($dest, $dir, $file);
      print "cp $src $dst\n";
      cp($src, $dst) || die "unable to copy $!";
    }
    else
    {
      my $dst = File::Spec->catdir($dest, $dir, $file);
      print "mkdir $dst\n";
      mkdir $dst;
    }
  }, $build_dir);
}

1;
