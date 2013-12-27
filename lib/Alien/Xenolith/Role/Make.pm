package Alien::Xenolith::Role::Make;

use strict;
use warnings;
use Alien::Xenolith::Base;
use File::chdir;

# ABSTRACT: Machinery for Xenolith fetch classes that use archives
# VERSION

around new => sub
{
  my($orig, $class, %args) = @_;

  my $make_path = delete $args{make_path};
  my $gnu       = delete $args{make_prefer_gnu};
  $make_path ||= 'make'
    if $class eq 'Alien::Xenolith::Builder::Autoconf'
    && $^O eq 'MSWin32';

  my $self = $class->$orig(%args);
  
  if($make_path)
  {
    $self->{make_path} = $make_path;
  }
  elsif($gnu)
  {
    require Config;
    $self->{make_path} = $Config::Config{gmake} || $Config::Config{make};
  }
  else
  {
    require Config;
    $self->{make_path} = $Config::Config{make};    
  }
  
  $self;  
};

requires 'build_dir';

sub _wrapper
{
  my $cb = shift;
  if($^O eq 'MSWin32')
  {
    Alien::MSYS::msys($cb);
  }
  else
  {
    $cb->();
  }
}

default make => sub
{
  my($self, @args) = @_;
  local $CWD = $self->build_dir;
  my $make = $self->{make_path};
  print "$make @args\n";
  _wrapper(sub {
    system $make, @args;
    if($? == -1)
    { die "make failed to execute $!" }
    elsif($? & 127)
    { die "died with signal " . ($? & 127) }
    elsif($?)
    { die "exited with return " . ($? >> 8) }
  });
  return;
};

default stage => sub
{
  my($self, $path) = @_;
  $self->make('install', "DEST_DIR=$path");
};

1;
