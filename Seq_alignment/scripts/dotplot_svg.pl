#!/usr/bin/perl -w
use SVG;
use strict;

## take two sequences and create tikz code that visualises the
## a dotplot of the two sequences

## do the simplest non-windowing approach...

my ($seq1, $seq2) = @ARGV;

(@ARGV == 2) || die "usage dotplot_tikz.pl seq1 seq2\n";

my @seq1 = split //, $seq1;
my @seq2 = split //, $seq2;

## draw the grid...
## we simply use a size of 1 for each position, let the final user
## scale to fit appropriately.
my $sn1 = scalar(@seq1);
my $sn2 = scalar(@seq2);

my $stage = 2;
print '\visible<', $stage, "->{\n";
$stage++;
print '\draw [-] (', "0.5,", $sn2+0.5, ') -- (', $sn1+1.5, ',', $sn2+0.5, ");\n";
print '\draw [-] (', "1.5,", $sn2+1.5, ') -- (', 1.5, ',', 0.5, ");\n";

for my $i(0..$#seq1){
    print "\t", '\node at (', $i+2, ',', $sn2+1, ') {', $seq1[$i], "};\n";
    if($i < $#seq1){
	print "\t", '\draw [-, dotted, opacity=0.5] (', $i+2.5,',',$sn2+1.5,') -- (', $i+2.5, ',', 0.5, ");\n";
    }
}

for my $i(0..$#seq2){
    print "\t", '\node at (', 1, ',', $sn2 - $i, ') {', $seq2[$i], "};\n";
    if($i < $#seq2){
	print "\t", '\draw [-, dotted, opacity=0.5] (0.5,', $sn2-$i-0.5, ') -- (', $sn1+1.5, ',', $sn2-$i-0.5, ");\n";
    }
}

print "}\n";
print '\visible<', $stage, "->{\n";
$stage++;
print "\\draw [fill=blue, fill opacity=0.5] ($sn1 + 2, $sn2-3) rectangle ($sn1+3,$sn2-2);\n";
print "\\node [right] at ($sn1+3, $sn2-2.5) { window=1 };\n";
for my $i(0..$#seq2){
    for my $j(0..$#seq1){
	if($seq1[$j] eq $seq2[$i]){
	    print "\\draw [fill=blue, fill opacity=0.5] ($j+1.5,$sn2-$i-0.5) rectangle ($j+2.5,$sn2-$i+0.5);\n";
	}
    }
}
print "}\n";

## but using a windowing selection we may have a better chance
my $win = 3;
print '\visible<', $stage, "->{\n";
$stage++;
print "\\draw [fill=red, fill opacity=0.4] ($sn1 + 2, $sn2-4) rectangle ($sn1+3,$sn2-5);\n";
print "\\node [right] at ($sn1+3, $sn2-4.5) { window=3 };\n";
for my $i(0..($#seq2-$win+1)){
    for my $j(0..($#seq1-$win+1)){
	if(substr($seq1, $j, $win) eq substr($seq2, $i, $win)){
	    for my $p(0..($win-1)){
		print "\\draw [fill=red, fill opacity=0.4] ($p+$j+1.5,-$p+$sn2-$i-0.5) rectangle ($p+$j+2.5, -$p+$sn2-$i+0.5);\n";
	    }
	}
    }
}
print "}\n";
