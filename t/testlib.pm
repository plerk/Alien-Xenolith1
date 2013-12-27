use strict;
use warnings;

package
  Sort::Versions;

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

$INC{'Sort/Versions.pm'} = __FILE__;

package
  Archive::Extract;

$INC{'Archive/Extract.pm'} = __FILE__;

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
  main;

use Test::More;

sub extracted_to_ok ($;$)
{
  my($dir, $testname) = @_;
  $testname ||= "extracted to $dir";
  is $last_extracted_location, $dir, $testname;
}

1;
