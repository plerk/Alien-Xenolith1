package Alien::Xenolith::Role::Archive;

use strict;
use warnings;
use Alien::Xenolith::Base;

# ABSTRACT: Machinery for Xenolith fetch classes that use archives
# VERSION

needs 'Sort::Versions' => 0;
needs 'Archive::Extract' => 0;

default versioncmp => sub
{
  my($self,$a,$b) = @_;
  $a =~ s/^.*?(\d)/$1/;
  $b =~ s/^.*?(\d)/$1/;
  Sort::Versions::versioncmp($a,$b);
};

around list => sub 
{
  my($orig, $self) = @_;
  sort { $self->versioncmp($a,$b) } $self->$orig;
};

requires 'local_archive_location';

default extract => sub
{
  my($self, $filename, $location) = @_;
  
  $location = File::Spec->curdir
    unless defined $location;
  
  my $ae = Archive::Extract->new(
    archive => $self->local_archive_location($filename),
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
};

1;
