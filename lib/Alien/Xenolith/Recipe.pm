package Alien::Xenolith::Recipe;

use strict;
use warnings;
use Carp qw( croak );

# ABSTRACT: Xenolith recipe for building an alien library
# VERSION

=head1 METHODS

=head2 new

Create a new recipe instance

=cut

sub new
{
  my($class, %args) = @_;

  if($args{code})
  {
    # nothing to do yet
  }
  elsif($args{filename})
  {
    croak "can't read $args{filename}"
      unless -r $args{filename};
  }
  else
  {
    croak "must specify either code or filename";
  }
  
  bless {
    code     => $args{code},
    filename => $args{filename},
    needs    => {},
    fetch    => [],
    build    => [],
  }, $class;
}

our $recipe;
our %args;
our $block;
our @build;

sub _add_needs
{
  my $self = shift;
  foreach my $other (@_)
  {
    my $needs = $other->_needs_hash;
    while(my($k,$v) = each %$needs)
    {
      $self->{needs}->{$k} = $v;
    }
  }
}

sub _kw_fetch ($)
{
  my($fetch) = @_;
  if(eval { $fetch->isa('Alien::Xenolith::Fetch'); 1 })
  {
    push @{ $recipe->{fetch} }, $fetch;
    $recipe->_add_needs($fetch);
  }
  else
  {
    croak "usage: fetch ( http | ftp | file | ... ) { ... }";
  }
}

sub _kw_set ($$)
{
  croak "set must be in a fetch, build or install block"
    unless defined $block;
  $args{$_[0]} = $_[1];
}

foreach my $type (qw( HTTP FTP File  ))
{
  my $sub = sub (&) {
    my($code) = @_;
    require "Alien/Xenolith/Fetch/$type.pm";
    local $block = 'fetch';
    local %args = ();
    $code->();
    "Alien::Xenolith::Fetch::$type"->new(%args);
  };
  
  no strict 'refs';
  *{"_kw_" . lc $type} = $sub;
}

sub _builder
{
  my($self, $name) = @_;
  
  unless($self->{builder}->{$name})
  {
    require "Alien/Xenolith/Builder/$name.pm";
    $DB::single = 1;
    $self->{builder}->{$name} = "Alien::Xenolith::Builder::$name";
    $recipe->_add_needs($self->{builder}->{$name});
  }
  
  $self->{builder}->{$name};
}

sub _kw_configure (@)
{
  croak "configure valid only in a build block"
    unless $block eq 'build';
  push @build, [ $recipe->_builder('Autoconf'), @_ ];
}

sub _kw_make (@)
{
  croak "make valid only in a build block"
    unless $block eq 'build';
  push @build, [ $recipe->_builder('Make'), @_ ];
}

sub _kw_cmake (@)
{
  croak "cmake valid only in a build block"
    unless $block eq 'build';
  push @build, [ $recipe->_builder('CMake'), @_ ];
}

sub _kw_binary ()
{
  croak "cmake valid only in a build block"
    unless $block eq 'build';
  push @build, [ $recipe->_builder('Binary'), @_ ];
}

sub _kw_build (&)
{
  my($code) = @_;
  local $block = 'build';
  $code->();
}

sub _package
{
  my($self) = @_;
  
  unless(defined $self->{package})
  {
    our $package_counter;
    $self->{package} = sprintf "Alien::Xenolith::Recipe::Anon%04d", $package_counter++;
    
    no strict 'refs';
    *{$self->{package} . "::$_"} = \&{"_kw_$_"} for grep { s/^_kw_// } keys %Alien::Xenolith::Recipe::;
  }
  
  $self->{package};
}

=head2 compile

Compile the recipe

=cut

sub compile
{
  my($self) = @_;

  return if $self->{compiled};

  my $package = $self->_package;
  local $recipe = $self;

  if($self->{code})
  {
    eval "package $package;" . $self->{code};
    die $@ if $@;
  }
  else
  {
    die "fixme";
  }
  
  $self->{compiled};
}

=head2 needs

Returns the needs hash for this recipe

=cut

sub needs
{
  shift->{needs};
}

1;
