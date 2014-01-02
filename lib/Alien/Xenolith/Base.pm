package Alien::Xenolith::Base;

use strict;
use warnings;
use Carp qw( croak );
use File::Spec;

# ABSTRACT: base class for Xenolith builder and fetch classes
# VERSION

=head1 METHODS

=head2 new

Creates an new instance of the class.  

=cut

sub new
{
  my $class = shift;
  croak "cannot create instance of abstract class"
    if $class =~ /^Alien::Xenolith::(Fetch|Builder|Base|Installer)$/;
  bless {}, $class;
}

my %needs;

sub _needs_hash
{
  my $class = ref $_[0] ? ref $_[0] : $_[0];
  my %r;
  foreach my $baseclass (eval qq{ \@$class\::ISA })
  {
    %r = (%r, %{ $baseclass->_needs_hash });
  }
  %r = (%r, %{ $needs{$class} || {} });
  \%r;
}

sub _init
{
  my($self) = @_;
  foreach my $class (keys %{ shift->_needs_hash })
  {
    eval qq{ use $class () };
    die $@ if $@;
  } 
}

sub _needs ($;$)
{
  my($package, $version) = @_;
  $version = 0 unless defined $version;
  my $caller = caller;
  $needs{$caller}->{$package} = $version;
}

my %around;
my %subs;

sub _with ($)
{
  my($class) = @_;
  my $caller = caller;
  eval qq{ use $class () };
  %{ $needs{$caller} } = map { %$_ } map { $needs{$_} || {} } ($class, $caller);
  
  while(my($name,$sub) = each %{ $around{$class} })
  {
    my $old = \&{join '::', $caller, $name};
    my $new = sub {
      $sub->($old, @_);
    };
    no strict 'refs';
    no warnings 'redefine';
    *{join '::', $caller, $name} = $new;
  }
  
  while(my($name,$sub) = each %{ $subs{$class} })
  {
    next if $caller->can($name);
    if(defined $sub)
    {
      no strict 'refs';
      *{join '::', $caller, $name} = $sub;
    }
    else
    {
      croak "$class requires $name to be implemented";
    }
  }
  
  return;
}

sub _around ($$)
{
  my($name, $sub) = @_;
  my $caller = caller;
  $around{$caller}->{$name} = $sub;
  return;
}

sub _requires ($)
{
  my($name) = @_;
  my $caller = caller;
  $subs{$caller}->{$name} = undef;
  return;
}

sub _default ($$)
{
  my($name, $sub) = @_;
  my $caller = caller;
  $subs{$caller}->{$name} = $sub;
  return;
}

sub import
{
  my($class) = @_;
  my $caller = caller;
  
  no strict 'refs';
  *{join '::', $caller, 'needs'}    = \&_needs;
  *{join '::', $caller, 'with'}     = \&_with;
  *{join '::', $caller, 'around'}   = \&_around;
  *{join '::', $caller, 'requires'} = \&_requires;
  *{join '::', $caller, 'default'}  = \&_default;
  return;
}

1;
