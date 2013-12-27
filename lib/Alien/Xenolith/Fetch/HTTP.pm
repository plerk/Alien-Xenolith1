package Alien::Xenolith::Fetch::HTTP;

use strict;
use warnings;
use base qw( Alien::Xenolith::Fetch );
use Alien::Xenolith::Base;
use Carp qw( croak );

# ABSTRACT: HTTP fetch class for Xenolith
# VERSION

with 'Alien::Xenolith::Role::Archive';
with 'Alien::Xenolith::Role::Filter';

needs 'URI'          => 0;
needs 'HTTP::Tiny'   => 0;
needs 'HTML::Parser' => 3.0;

=head1 METHODS

=head2 new

 my $fetch = Alien::Xenolith::Fetch::HTTP->new(
   uri            => 'http://example.com/path/to/dir',
   http_tiny_args => { },
 );

Returns a new instance of the http fetch class.

=cut

sub new
{
  my($class, %args) = @_;
  my $uri = delete $args{uri} || croak 'requires uri argument';
  my $tiny = delete $args{http_tiny_args};
  my $self = $class->SUPER::new(%args);
  $self->{uri} = $uri;
  $self->{http_tiny_args} = $tiny || {};
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
  my $web = $self->_web;

  my $response = $web->get($uri);
  
  croak join(' ', "unable to get $uri ", $response->{status}, $response->{reason})
    unless $response->{success};  

  my @raw_links;

  my $cb = sub {
    my($tagname, $attr) = @_;
    if($tagname eq 'a' && defined $attr->{href})
    {
      push @raw_links, $attr->{href};
    }
  };

  my $parser = HTML::Parser->new(
    api_version => 3,
    start_h => [ $cb, "tagname, attr" ],
    marked_sections => 1,
  );
  
  $parser->parse($response->{content});

  my %links;
  foreach my $href (@raw_links)
  {
    my $link = URI->new_abs($href, URI->new($response->{url}));
    my @segments = $link->path_segments;
    my $name = $segments[-1];
    $links{$name} = $link;
  }
  
  $self->{links} = \%links;
 
  my @list = keys %links;
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

  my $web = $self->_web;
  my $response;
  my $uri;

  if($self->{links}->{$filename})
  {
    $uri = $self->{links}->{$filename};
    $response = $web->get($uri);
  }
  else
  {
    my $base = $self->_uri->clone;
    $base->path($base->path . '/')
      unless $base->path =~ /\/$/;
    $uri = URI->new_abs($filename, $base);
    $response = $web->get($uri);
  }
  
  croak join(' ', "unable to get $uri ", $response->{status}, $response->{reason})
    unless $response->{success};  

  my $temp = File::Spec->catfile($self->fetch_tempdir, ".$filename.tmp");
  
  my $fh;
  open($fh, '>', $temp) || die "unable to write $temp";
  binmode $fh;
  print $fh $response->{content};
  close $fh;

  rename($temp, $local) || croak "unable to rename $temp to $local $!";
  
  $local;
}

sub _web
{
  my($self) = @_;
  $self->{web} ||= HTTP::Tiny->new(%{ $self->{http_tiny_args} });
}

sub _uri
{
  my($self) = @_;
  
  unless(ref $self->{uri})
  {
    $self->{uri} = URI->new($self->{uri});
    croak "URI protocol must be http or https"
      unless $self->{uri}->scheme =~ /^https?$/;
  }

  $self->{uri};
}

1;
