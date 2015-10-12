#!/usr/bin/perl -w

## al_seq.pl works, but it:
## performs one of the alignments twice
## and it doesn't print things out in a very nice
## order. We can change that quite easily by reversing
## the order of $i values in the first loop.

## Determine alignment scores for
## all possible non-gapped alignments for two sequences
##

($as, $bs) = @ARGV;

## assign $as and $bs to the values of $ARGV[0] and $ARGV[1] respectively.
## this is simply a short way of writing:
# $as = $ARGV[0];
# $bs = $ARGV[1];

## split the two sequences into arrays @a and @b
@a = split //, $as;
@b = split //, $bs;

## Define the match and mismatch scores
$match = 1;
$mismatch = -1;
## It would be better if the user could set these when
## running the program.
## You can consider how this can be done


## to find all the non-gapped alignements 
## is to find a single alignment that starts at
## each position of each sequence.
## to do this, we do a loop through each starting position
## of each sequence.

## loop through each position of $as
## modify:
#for $i(0..$#a){ 
# to in order to print a more pleasing order of alignments: 
for($i=$#a; $i > 0; $i--){
    ## to calculate the score
    $score = 0;
    for $j($i..$#a){  ## i.e. positions of @a starting from $i and to the end of a
	if(($j-$i) > $#b){
	    last;
	}
	## compare positions starting from $i in @a, but starting from 0 in @b;
	## (in the first iteration of the loop, $j is equal to $i, so ($j-$i) is equal to 0.
	if($a[$j] eq $b[$j-$i]){
	    $score += $match;
	}else{
	    $score += $mismatch;
	}
    }
    ## this is for an alignement that starts at position
    ## $i of sequence $as. Hence first print out the full 
    ## $as sequence.
    print $as, "\n";
    ## then print out the appropriate number of spaces. This is 
    ## possible using the for $j(0..$i), but this will print out
    ## one too many spaces. There is a better way to loop through these
    ## values using the for(;;) type of loop.

    for($j=0; $j < $i; $j++){
	print " ";
    }
    print $bs, "\n";
    print "score: $score\n";
    print "---------\n";
}

## and we don't really need this anymore...
## print "=========================\n";

for $i(0..$#b){ ## then we start along the other diagonals
    $score = 0;
    for $j($i..$#b){
	if(($j-$i) > $#a){
	    last;
	}
	if($a[$j-$i] eq $b[$j]){
	    $score += $match;
	}else{
	    $score += $mismatch;
	}
    }
    ## this is for alignments that starts at position $i of $bs
    ## hence first print out the correct number of spaces and then
    ## print out $as after that
    for($j=0; $j < $i; $j++){
	print " ";
    }
    print $as, "\n";
    print $bs, "\n";
    print "score: $score\n";
    print "---------\n";
}


	
