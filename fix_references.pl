#!/usr/bin/perl
#

use warnings;
use strict;

use File::Slurp qw/slurp/;

my $input = shift or die 'no input file specified';
my $output = shift or die 'no output file specified';
my $index = shift or die 'no index file specified';

$input = slurp($input) or die 'failed slurping ' . $input;
$index = slurp($index) or die 'failed slurping ' . $index;
open my $outfile, '>', $output or die 'failed opening ' . $output . ' for writing';

my %index = map { (split /:\s*/)[1] => (split /:\s*/)[0] } split '\n', $index;
$input =~ s/-ref-to-(.+?)-ref-to-/$index{$1}/g;

print $outfile $input;
