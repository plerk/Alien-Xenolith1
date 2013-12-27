package Alien::Xenolith::Base;

use strict;
use warnings;
use Carp qw( croak );
use File::Spec;

# ABSTRACT: base class for Xenolith installer and fetch classes
# VERSION

=head1 METHODS

=head2 new

Creates an new instance of the class.  

=cut

sub new
{
  my $class = shift;
  croak "cannot create instance of abstract class"
    if $class =~ /^Alien::Xenolith::(Fetch|Installer|Base)$/;
  bless {}, $class;
}

my %req;

sub _needs_hash
{
  my $class = ref $_[0] ? ref $_[0] : $_[0];
  my %r;
  foreach my $baseclass (eval qq{ \@$class\::ISA })
  {
    %r = (%r, %{ $baseclass->_needs_hash });
  }
  %r = (%r, %{ $req{$class} || {} });
  \%r;
}

sub _init
{
  my($self) = @_;
  foreach my $class (keys %{ shift->_needs_hash })
  {
    my @filename = split /::/, $class;
    $filename[-1] .= '.pm';
    my $filename = File::Spec->catfile(@filename);
    require $filename;
  } 
}

sub _needs ($;$)
{
  my($package, $version) = @_;
  $version = 0 unless defined $version;
  my $caller = caller;
  $req{$caller}->{$package} = $version;
}

my %around;
my %default;

sub _with ($)
{
  my($class) = @_;
  my $caller = caller;
  my @filename = split /::/, $class;
  $filename[-1] .= '.pm';
  my $filename = File::Spec->catfile(@filename);
  require $filename;
  %{ $req{$caller} } = map { %$_ } map { $req{$_} || {} } ($class, $caller);
  
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
}

sub _around ($$)
{
  my($name, $sub) = @_;
  my $caller = caller;
  $around{$caller}->{$name} = $sub;
}

sub import
{
  my($class) = @_;
  my $caller = caller;
  
  no strict 'refs';
  *{join '::', $caller, 'needs'}    = \&_needs;
  *{join '::', $caller, 'with'}     = \&_with;
  *{join '::', $caller, 'around'}   = \&_around;
}

1;
