#!/usr/bin/perl -w
use SVG;
use strict;

## takes two sequences and creates a dotplot of them
## in the svg format.
## uses windows of size 1 and 3.

my ($seq1, $seq2) = @ARGV;

(@ARGV == 2) || die "usage dotplot_tikz.pl seq1 seq2\n";

## this splits the sequences into arrays that are
## more convenient to handle. From here on, I can
## access the individual letters of the sequence strings
## using the [] notation. I.e. the first and third letters of
## sequence1 respetively: $seq[0] and $seq[2]
## note we start counting from 0.

my @seq1 = split //, $seq1;
my @seq2 = split //, $seq2;

## The lengths of the two sequences.
my $sn1 = scalar(@seq1);
my $sn2 = scalar(@seq2);

## Using 10 points for each position makes the
## calculation simple.

my $width = 10 + $sn1 * 10;
my $height = 10 + $sn2 * 10;

## set up a new drawing region.
my $svg1 = SVG->new(width=>$width, height=>$height);
		  
## draw axes lines
$svg1->line(x1=>1, y1=>10, x2=>$width, y2=>10, 'stroke'=>'black');
$svg1->line(x1=>10, y1=>1, x2=>10, y2=>$height, 'stroke'=>'black', 'stroke-opacity'=>1);

## Horizontal positions go from left (low) to right (high) as in most
## coordinate systems. However vertical positions go from top (low) to
## bottom (high values). This is fairly common in computer graphics
## and sort of mimics writing text on a page (start at the top).

## Draw the letters of sequence 1 along the top:
for my $i(0..$#seq1){
    my $x = 10 + $i * 10;
    my $y = 10;
    $svg1->text('x'=>$x+2, 'y'=> 8,
	'font-family'=>'san serif', 'font-size'=>9)->cdata($seq1[$i]);
    ## vertical dashed lines at all positions except the last one.
    if($i < $#seq1){
	$svg1->line('x1'=>$x+10, 'y1'=>1, 'x2'=>$x+10, 'y2'=>$height, 
		    'stroke-dasharray'=>"3,1", 'stroke'=>'black', 'stroke-width'=>0.5);
    }
}

## Draw the letters of sequence 2 along the left hand side:
for my $i(0..$#seq2){
    my $x = 0;
    my $y = 20 + $i*10;
    $svg1->text('x'=>$x+2, 'y'=>$y-1, 
		'font-family'=>'san serif', 'font-size'=>9)->cdata($seq2[$i]);
    if($i < $#seq2){
	$svg1->line('x1'=>$x, 'y1'=>$y, 'x2'=>$width, 'y2'=>$y,
		    'stroke-dasharray'=>'3,1', 'stroke'=>'black', 'stroke-width'=>0.5);
    }
}

## Go through all letters in seq2 against all letters in seq1
for my $i(0..$#seq2){
    for my $j(0..$#seq1){
	my $x = 10 + $j * 10;
	my $y = 10 + $i * 10;
	if($seq1[$j] eq $seq2[$i]){# && 'ab' eq 'ac'){
	    ## the the two letters are the same, then draw a square
	    ## at the position.
	    $svg1->rectangle('x'=>$x, 'y'=>$y, 'width'=>10, 
			     'height'=>10, 'fill'=>'blue', 'opacity'=>0.5);
	}
    }
}


## Use a 3bp window to compare the two sequences
my $win = 3;
for my $i(0..($#seq2-$win+1)){
    for my $j(0..($#seq1-$win+1)){
	## substr extracts parts of strings. In this case we use
	## the original sequence string given by the user.
	if(substr($seq1, $j, $win) eq substr($seq2, $i, $win)){
	    for my $p(0..($win-1)){
		my $x = 10 * (1 + $j + $p);
		my $y = 10 * (1 + $i + $p);
		my $r = $svg1->rectangle('x'=>$x, 'y'=>$y, 'width'=>10, 'height'=>10,
					 'fill'=>'red', 'opacity'=>1/$win);
	    }
	}
    }
}

## get the xml for the svg picture
my $out = $svg1->xmlify;
## and print it out.
print $out;
