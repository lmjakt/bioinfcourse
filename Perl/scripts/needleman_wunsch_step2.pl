#!/usr/bin/perl -w

## create a scoring table for a Needleman-Wunsch alignment
## Use only a single gap penalty for both insertion and extension.

## part 2 extends part 1 by also remembering the how the
## scores in the scoring table were obtained. (i.e. their
## route).

## The two sequences are given by the command line (@ARGV[0] and @ARGV[1]).

## define the match, mismatch and gap scores.
$match = 1;
$mismatch = -1;
$gap = -2;

## refer to the sequences as $as and $ab
($as, $bs) = @ARGV;

print "$as\n$bs\n";
## die;
## split the two sequences to arrays @a and @b
@a = split //, $as;
@b = split //, $bs;

## we will need a scoring matrix that has @a + 1 rows
## and @b + 1 columns
## (@a, and @b means the length of the @a and @b respectively).

## such arrays will have indexes from 0 to @a, and from 0 to @b
##

## first initialise the scoring matrix to have all 0s
## technically this isn't necessary, but it shows
## how we access the values more clearly.

## we can also store the route information in a similar two dimensional table.
## This can be stored in a number of ways. The simplest is perhaps to encode
## the path in a single number. Since a maximal score can be obtained from more
## then one route (i.e. we can get the same score from a diagonal and a horizontal
## or vertical movement) we need a single number that can encode combinations
## of paths. This can be done simply by the following scheme
## 1 --> diagonal
## 2 --> horizontal
## 4 --> vertical
## and then taking the sum of all routes followed. Hence if
## diagonal only --> 1
## horizontal only --> 2
## diagonal and horizontal only --> 3
## diagonal and horizontal and vertical --> 7
## 
## this is known as bitwise encoding, as in a binary representation, the first bit
## encodes multiples of 1, the second bit multiples of 2, the third bit multiples of 4.
## (where multiples is just 1 or 0.)

## we can hence have 0 for no path, and initate as follows

for $i(0..@a){        ## $i represents the rows of the table
    for $j(0..@b){    ## $j represents the columns of the table
	$scores[$i][$j] = 0;
	$routes[$i][$j] = 0;
    }
}

## we can look at this matrix by calling the print_score_table function
## defined at the end of this file.

## we indicate it is a function by the use of the brackets.
print_score_table(@scores);

## the top row indicates gaps in sequence @a (as we move along
## sequence @b without any movement along @a.
## the first column similarly represents gaps in sequence @b
## We first need to insert gap scores in these.

## The gaps start from the first position, not the last one
## so we use the range from 1..@a and 1..@b

## first fill in the top row (which has row number 0).
for $j(1..@b){
    $scores[0][$j] = $scores[0][$j-1] + $gap;
}

## then the first column (has column number 0).
for $i(1..@a){
    $scores[$i][0] = $scores[$i-1][0] + $gap;
}

## see what the score table looks like by printing it out:
print_score_table(@scores);

## Then we can start to fill in the actual values. We do it row, by
## row and column by column.

for $i(0..$#a){    
## here $i represents the positions in sequence a.
## hence $i + 1 is equal to the row number of the score
## that we wish to set, and $i itself corresponds to the previous row.
    for $j(0..$#b){
	## similarly, $j corresponds to the previous column, and $j+1
	## to the column of the score that we wish to set.

	## the score is defined as the maximum score obtained by:
	## 1. The match or mismatch penalty defined by the letter at $a[$i] and $a[$b]
	##    plus the score at $scores[$i][$j] representing a diagonal advance in
	##    both sequences.
	## 2. A gap penalty plus the score to the left in the scoring matrix ($scores[$i+1][$j])
	## 3. A gap penalty plus the score above in the row above in the matrix ($scores[$i][$j+1])
	## Options 2 and 3 represent gap insertions in the alignment. Option 1 indicates an extension
	## of an aligned region.
	
	## first determine these three scores. We can call the scores $s1, $s2 and $s3 from the above list.
	## The first of these depends on whether ($a[$i] eq $b[$j])
	
	## this is a bit ugly, but what the hell
	if($a[$i] eq $b[$j]){
	    $s1 = $scores[$i][$j] + $match;
	}else{
	    $s1 = $scores[$i][$j] + $mismatch;
	}
	$s2 = $scores[$i+1][$j] + $gap;
	$s3 = $scores[$i][$j+1] + $gap;

	## now we need to determine which of these is the highest. The simplest way of doing this
	## is by something like:
	$max = $s1;
	if($max < $s2){ $max = $s2; }
	if($max < $s3){ $max = $s3; }
	## we don't have to use a new line for conditionals, and writing it like this looks a bit neater to me.
	
	## then simply set the score at row ($i + 1) and column ($j + 1) to $max.
	$scores[$i+1][$j+1] = $max;

	## encoding the route information is a little more complicated as all routes that give the maximal score
	## should be remebered. So we need to ask if the different scores are equal to the maximal scores:
	if($s1 == $max){ $routes[$i+1][$j+1] += 1; }
	if($s2 == $max){ $routes[$i+1][$j+1] += 2; }
	if($s3 == $max){ $routes[$i+1][$j+1] += 4; }
    }
}

## have a look at the table:
print_score_table(@scores);

print "And the routes\n";
print_score_table(@routes);
## a simple function that prints out the table and the sequences
## it takes no arguments, but makes use of the global variables
## $scores, @a, @b
## modify this to take an argument, that is the score or route table
sub print_score_table{
    my @table = @_; ## arguments are passed to functions in the @_ array;
    print "\t";
    for $j(0..$#b){
	print "\t", $b[$j];
    }
    print "\n";
    for $i(0..@a){   ## again, $i represents the rows here
	## if $i is 0, then we print a space, otherwise we print
	## $a[$i-1]
	if($i == 0){
	    print "  ";
	}else{
	    print $a[$i-1], " ";
	}
	for $j(0..@b){ ## and $j indicates the rows
#	    print "\t", $scores[$i][$j];
	    ## and then we change scores to table
	    print "\t", $table[$i][$j];
	}
	print "\n";
    }
    print "=======================================\n";
}
