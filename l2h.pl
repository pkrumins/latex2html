#!/usr/bin/perl
#

use warnings;
use strict;

use HTML::Entities;
use File::Slurp qw/slurp/;

my $input = shift or die 'no input file specified';
my $output = shift or die 'no output file specified';
my $contents = slurp($input) or die 'failed slurping ' . $input;
open my $outfile, '>', $output or die 'failed opening ' . $output . ' for writing';

html_start();

my $par_started = 0;

while (1) {
    if ($contents =~ /^$/) {
        last;
    }
    elsif ($contents =~ /^\\chapter{(.+?)}/) {
        print $outfile "<h1>$1</h1>\n";
        $contents =~ s/\\chapter{(.+?)}//;
    }
    elsif ($contents =~ /^\\section{(.+?)}/) {
        print $outfile "<h2>$1</h2>\n";
        $contents =~ s/\\section{(.+?)}//;
    }
    elsif ($contents =~ /^\\begin{lstlisting}(.+?)\\end{lstlisting}/s) {
        print $outfile "<pre>$1</pre>\n";
        $contents =~ s/\\begin{lstlisting}(.+?)\\end{lstlisting}//s;
    }
    elsif ($contents =~ /^\\label{(.+?)}/) {
        $contents =~ s/\\label{(.+?)}//;
    }
    elsif ($contents =~ /^\n/) {
        if ($par_started) {
            print $outfile "</p>\n";
            $par_started = 0;
        }
        $contents =~ s/\n//;
    }
    elsif ($contents =~ /^\\newpage/) {
        $contents =~ s/\\newpage//;
    }
    elsif ($contents =~ /^\\hyperref\[(.+?)\]\{(.+?)\}/) {
        $contents =~ s/^\\hyperref\[(.+?)\]\{(.+?)\}//;
        print $outfile '<a href="'.$1.'">'.encode_entities($2).'</a>';
    }
    elsif ($contents =~ /^\\ref{(.+?)}/) {
        $contents =~ s/^\\ref{(.+?)}//;
    }
    elsif ($contents =~ /^(.)/) {
        if ($1 eq "\\") {
            $contents =~ s/\\//;
            if ($contents =~ /^verb(.)(.+?)(\1)/) {
                print $outfile "<code>".encode_entities($2)."</code>";
                $contents =~ s/^verb(.)(.+?)(\1)//;
            }
            elsif ($contents =~ /^index{/) {
                $contents =~ s/^index{//;
                my $open_paren = 1;
                while ($contents =~ /^(.)/) {
                    my $char = $1;
                    $contents =~ s/^(.)//;
                    if ($char eq "{") {
                        $open_paren++;
                    }
                    elsif ($char eq "}") {
                        $open_paren--;
                        if ($open_paren == 0) {
                            last;
                        }
                    }
                    else {
                        # skip
                    }
                }
            }
            elsif ($contents =~ /^index{(.+?)}/) {
                $contents =~ s/^index{(.+?)}//;
            }
            else {
                print "unrecognized tex command -->'" . substr($contents, 0, 100) . "'<--\n";
                exit;
            }
        }
        else {
            if (!$par_started) {
                print $outfile "<p>";
                $par_started = 1;
            }
            print $outfile "$1";
            $contents =~ s/.//;
        }
    }
    else {
        print "unrecognized sequence -->'" . substr($contents, 0, 100) . "'<--\n";
        exit;
    }
}

html_end();

close $outfile;

sub html_start {
    print $outfile "<html>\n";
    print $outfile "<head>\n";
    print $outfile "<title>$input</title>\n";
    print $outfile <<CSS;
<style media="screen" type="text/css">
pre {
    background-color: #AFEEEE;
    border: 1px solid black;
    padding: 1em;
}
code {
    background-color: #AFEEEE;
    border: 1px solid black;
    padding: 1px 2px;
}
</style>
CSS
    print $outfile "</head>";
    print $outfile "<body>\n";
}

sub html_end {
    print $outfile "</body>\n";
    print $outfile "</html>\n";
}

