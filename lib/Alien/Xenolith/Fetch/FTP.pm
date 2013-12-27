package Alien::Xenolith::Fetch::FTP;

use strict;
use warnings;
use base qw( Alien::Xenolith::Fetch );
use Alien::Xenolith::Base;
use Carp qw( croak );

# ABSTRACT: FTP fetch class for Xenolith
# VERSION

with 'Alien::Xenolith::Role::Archive';
with 'Alien::Xenolith::Role::Filter';

needs 'Net::FTP' => 0;
needs 'URI'      => 0;

=head1 METHODS

=head2 new

 my $fetch = Alien::Xenolith::Fetch::FTP->new(
   uri => 'ftp://example.com/path/to/dir',
 );

Returns a new instance of the ftp fetch class.

=cut

sub new
{
  my($class, %args) = @_;
  my $uri = delete $args{uri} || croak "requires uri argument";
  my $self = $class->SUPER::new(%args);
  $self->{uri} = $uri;
  $self;
}

=head2 list

 my @list = $fetch->list;

Returns a list of possible archives.

=cut

sub list
{
  my($self) = @_;
  
  return @{ $self->{list} } if defined $self->{list};
  
  my $uri = $self->_uri;

  my $ftp = Net::FTP->new($uri->host)     || croak "unable to connect to $uri";
  $ftp->login($uri->user, $uri->password) || croak "unable to authenticate $uri";
  $ftp->cwd($uri->path)                   || croak "unable to chdir into $uri";
  my @list = $ftp->ls;
  $ftp->quit;
  
  
  $self->{list} = \@list;
  
  @list;
}

=head2 local_archive_location

 my $path = $fetch->local_archive_location

Returns a copy of the archive available on a local filesystem.

=cut

sub local_archive_location
{
  my($self, $filename) = @_;
  my $local = File::Spec->catfile($self->fetch_tempdir, $filename);

  return $local if -r $local;
  
  my $uri = $self->_uri;

  my $ftp = Net::FTP->new($uri->host)     || croak "unable to connect to $uri";
  $ftp->login($uri->user, $uri->password) || croak "unable to authenticate $uri";
  $ftp->cwd($uri->path)                   || croak "unable to chdir into $uri";
  $ftp->binary                            || croak "unable to set binary mode $uri";
  
  my $temp = File::Spec->catfile($self->fetch_tempdir, ".$filename.tmp");
  
  $ftp->get($filename, $temp) || croak "unable to get $uri/$filename";
  rename($temp, $local) || croak "unable to rename $temp to $local $!";
  
  $local;
}

sub _uri
{
  my($self) = @_;
  
  unless(ref $self->{uri})
  {
    $self->{uri} = URI->new($self->{uri});
    croak "URI protocol must be ftp"
      if $self->{uri}->scheme ne 'ftp';
  }

  $self->{uri};
}

1;
