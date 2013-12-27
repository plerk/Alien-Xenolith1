package Alien::Xenolith::Role::Filter;

use strict;
use warnings;
use Alien::Xenolith::Base;

# ABSTRACT: Machinery for Xenolith fetch classes that need to filter out certain files/links
# VERSION

around new => sub
{
  my($orig, $class, %args) = @_;

  my $filter = delete $args{filter};
  my $self = $class->$orig(%args);
  
  $self->{filter} = $filter;
  
  if(defined $self->{filter})
  {
    $self->{filter} = qr{$filter}
      unless ref $self->{filter};
  }
  else
  {
    $self->{filter} = sub { 1 };
  }
  
  $self;
};

around list => sub
{
  my($orig, $self) = @_;
  
  my @list = $self->$orig;
  
  if(ref $self->{filter} eq 'CODE')
  {
    @list = grep { $self->{filter}->($_) } @list;
  }
  else
  {
    @list = grep { $_ =~ $self->{filter} } @list;
  }
  
  @list;
};

1;
