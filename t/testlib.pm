use strict;
use warnings;
use FindBin;
use File::Spec;

sub _mock ()
{
  my $caller = caller;
  my @name = split /::/, $caller;
  $name[-1] .= '.pm';
  $INC{join '/', @name} = __FILE__;
  $INC{File::Spec->catdir(@name)} = __FILE__;
}

package
  Sort::Versions;

main::_mock();

sub versioncmp
{
  my($a, $b) = @_;

  $a =~ s/\.(tar.gz)$//;
  $b =~ s/\.(tar.gz)$//;
  
  return 0 if $a eq $b;
  if($a eq '1.2.3' && $b eq '1.3.2')
  {
    return -1;
  }
  if($a eq '1.3.2' && $b eq '1.2.3')
  {
    return 1;
  }
  
  die "Don't know how to compare $a and $b";
}

package
  Archive::Extract;

main::_mock();

sub new
{
  bless {}, 'Archive::Extract';
}

my $last_extracted_location;

sub extract
{
  my($self, %args) = @_;
  $last_extracted_location = $args{to};
}

package
  HTTP::Tiny;

main::_mock();

sub new
{
  bless {}, 'HTTP::Tiny';
}

sub get
{
  my($self, $uri) = @_;
  if($$uri eq 'http://foo.wdlabs.com/roger')
  {
    return {
      success => 1,
      url     => 'http://foo.wdlabs.com/roger/',
      content => <<EOF,
<html>
  <head>
    <title>this is a title</title>
  </head>
  <body>
    <ul>
      <a href="libbar-1.2.3.tar.gz">libbar-1.2.3.tar.gz</a>
      <a href="libfoo-1.2.3.tar.gz">libfoo-1.2.3.tar.gz</a>
      <a href="libfoo-1.3.2.tar.gz">libfoo-1.3.2.tar.gz</a>
    </ul>
  </body>
</html>
EOF
    };
  }
  elsif($$uri =~ m{http://foo.wdlabs.com/roger/(.*)$})
  {
    $DB::single = 1;
    my $name = $1;
    my $fn = File::Spec->catfile($FindBin::Bin, File::Spec->updir, qw( corpus file ), $name);
    if(-r $fn)
    {
      return {
        success => 1,
        url     => "http://foo.wdlabs.com/roger/$name",
        content => do {
          open my $fh, '<', $fn;
          my $data = do { local $/; <$fh> };
          close $fh;
          $data;
        },
      };
    }
  }
  
  die "nope $uri";
}

package
  URI;

main::_mock();

use overload '""' => sub { ${$_[0]} };

sub new
{
  my($class, $uri) = @_;
  bless \$uri, $class;
}

sub new_abs
{
  my($class, $uri, $base) = @_;
  $base =~ s{/$}{};
  my $new = join '/', "$base", "$uri";
  bless \$new, $class;
}

sub scheme
{
  my($self) = @_;
  if($$self =~ /^(.*?):/)
  {
    return $1;
  }
  die "can't find scheme in " . $$self;
}

sub path_segments
{
  my($self) = @_;
  if($$self =~ m{^(https?|ftp)://.*?(/.*)$})
  {
    return split '/', $2;
  }
  die "oops";
}

package
  main;

use Test::More;

sub extracted_to_ok ($;$)
{
  my($dir, $testname) = @_;
  $testname ||= "extracted to $dir";
  is $last_extracted_location, $dir, $testname;
}

sub note_needs ($)
{
  my($class) = @_;
  
  my $needs = $class->_needs_hash;
  
  foreach my $name (sort keys %$needs)
  {
    note sprintf "needs %-20s = %s\n", $name, $needs->{$name};
  }
}

1;
