#!/usr/bin/perl -w

## align two sequences given on the command line calculating alignment
## scores for all non-gapped alignments.

($as, $bs) = @ARGV;

@a = split //, $as;
@b = split //, $bs;

## we can consider that the two sequences should be placed in
## a box of length @a + @b. At the starting point sequence a
## is place at the leftmost position; it is then moved to the right until
## is in the rightmost position, at which point we slide sequce be
## to the leftmost position.

## we don't actually have such a box, but we can see that the starting point
## of the alignments made will follow the following pattern

## for a: @a..0..0
## for b: 0..0..@b

## if we include the completely non-overlapping position.
## we can then define a starting indices for the a and b positions
## as $i and $j;
## and then use a while loop which we break out of when $j == @b and
## $i == 0;

$i = @a;
$j = 0;

while(!($i == 0 && $j == (@b+1))){
    print " "x$j, $as, "\n";
    print " "x$i, $bs, "\n";
    print "--------------------------\n";

    ## we need to change the variables appropriately here:
    if($i > 0){
	$i--;
    }
    if($i == 0){
	$j++;
    }
}


