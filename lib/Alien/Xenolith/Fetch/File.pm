package Alien::Xenolith::Fetch::File;

use strict;
use warnings;
use base qw( Alien::Xenolith::Fetch );
use Carp qw( croak );
use File::Spec;
use Alien::Xenolith::Base;

# ABSTRACT: Local file fetch class for Xenolith
# VERSION

with 'Alien::Xenolith::Role::Archive';
with 'Alien::Xenolith::Role::Filter';

=head1 METHODS

=head2 new

 my $fetch = Alien::Xenolith::Fetch::File->new(
   dir => $directory_path,
 );

Returns a new instance of the file fetch class.

=cut

sub new
{
  my($class, %args) = @_;
  my $dir = delete $args{dir} || croak "dir is a required argument";
  my $self = $class->SUPER::new(%args);
  $self->{dir} = $dir;
  $self;
}

=head2 list

 my @list = $fetch->list;

Returns a list of possible archives.

=cut

sub list
{
  my($self) = @_;
  my $dh;
  my $dir = $self->{dir};
  opendir($dh, $self->{dir}) || die "unable to read $dir $!";
  my @list = grep !/^\./, readdir $dh;
  closedir $dh;  
  @list;
}

=head2 local_archive_location

 my $path = $fetch->local_archive_location

Returns a copy of the archive available on a local filesystem.
For the File fetch class, this is the location of the original
archive.

=cut

sub local_archive_location
{
  my($self, $filename) = @_;
  File::Spec->catfile($self->{dir}, $filename);   
  
}

1;
