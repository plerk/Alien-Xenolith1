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
needs 'Archive::Extract' => 0;

=head1 METHODS

=head2 new

 my $fetch = Alien::Xenolith::Fetch::File->new(
   dir => $directory_path,
 );

Returns a new instance of the file fetch class.

=cut

sub new
{
  my $self = shift->SUPER::new;
  my %args = @_;
  
  $self->{dir}    = $args{dir} || croak "dir is a required argument";
  $self->{filter} = $args{filter};
  
  if(defined $self->{filter})
  {
    $self->{filter} = qr{$args{filter}}
      unless ref $self->{filter};
  }
  else
  {
    $self->{filter} = sub { 1 };
  }
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
  
  if(ref $self->{filter} eq 'CODE')
  {
    @list = grep { $self->{filter}->($_) } @list;
  }
  else
  {
    @list = grep { $_ =~ $self->{filter} } @list;
  }
  
  @list;
}

=head2 extract

 $fetch->extract($filename, $directory);

Extract the given archive ($filename must be one of the values
returned by the L<list|Alien::Xenolith::Fetch::File#list> method)
to the given directory (if $directory is not specified, then
it will use the current directory).

=cut

sub extract
{
  my($self, $filename, $location) = @_;
  
  $location = File::Spec->curdir
    unless defined $location;
  
  my $archive = File::Spec->catfile($self->{dir}, $filename); 
  
  my $ae = Archive::Extract->new(
    archive => File::Spec->catfile($self->{dir}, $filename),
  );
  
  $ae->extract( to => $location ) || return;

  my $dh;
  opendir $dh, $location;
  my @list = grep !/^\./, readdir $dh;
  closedir $dh;
  
  return unless @list;
  
  if(@list > 1)
  {
    return $location;
  }
  else
  {
    return File::Spec->catdir($location, $list[0]);
  }
}

1;
