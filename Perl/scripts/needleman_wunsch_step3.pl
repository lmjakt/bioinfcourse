#!/usr/bin/perl -w

## create a scoring table for a Needleman-Wunsch alignment
## Use only a single gap penalty for both insertion and extension.

## part 2 extends part 1 by also remembering the how the
## scores in the scoring table were obtained. (i.e. their
## route).

## part 3 extends part 2 by using the route table to extract the set of best alignments
## It does this using two methods that are usually quite hard to understand when
## first encountered:
##
## 1. Bitwise encoding of state. This is in fact what we used in step 2
##    to encode the route information. In the encoding step I could kind
##    of ignore the bitwise nature of it, but for decoding, it's difficult to avoid.
## 2. Recursion. This is a function that calls itself. The effects of it are quite
##    difficult to visualise. We also have to make use of locally scoped variables:
##    which in perl means using the my statement. This is probably the most difficult
##    thing to understand here.

## The two sequences are given by the command line (@ARGV[0] and @ARGV[1]).

## define the match, mismatch and gap scores.
$match = 1;
$mismatch = -1;
$gap = -2;

## refer to the sequences as $as and $ab
($as, $bs) = @ARGV;

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

## to keep the alignments we make two arrays of strings
## both initialised to hold a single empty string

@a_al = ("");
@b_al = ("");
$n = 0; ## the last index of the alignment arrays
$i = @a;
$j = @b;

obtain_alignment( $i, $j, $n );

for $i(0..$#a_al){
    print $i, "\t$a_al[$i]\n";
    print "\t$b_al[$i]\n";
    print "\n";
}

## Modified from the first script, to take an argument indicating
## the scores.
## a simple function that prints out the table and the sequences
## It takes as an argument a two dimensional array which is is
## assumed to have the dimension of @a x @b
## 

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


sub obtain_alignment{
    my($i, $j, $n) = @_;
    ## $i is the row of the entry (cell) that we are looking at
    ## $j is the column
    ## This function will modify the two global arrays @a_al, and @b_al
    ## these hold the alignments as strings with added gaps represented
    ## by - characters
 
    ## don't do anything if we've reached the end
    if($i == 0 && $j == 0){ return; }

    ## we use the route count variable to indicate whether we need to initiate
    ## a branch at this point. A branch point means that we need to an additional
    ## alignment sequence.

    my $route_count = 0;
    
    ## we also define the current alignment sequences as local variables. These
    ## are needed to initiate alignments at branch points and need to be local
    ## to make sure that they are not modified prior to being used.
    my $al = $a_al[$n];
    my $bl = $b_al[$n];
    
    ## look at the route information
    ## we use a bitwise AND to determine if we have a diagonal branch
    if($routes[$i][$j] & 1){
	$route_count++;  ## increment the route_count to indicate we've found one route

	## then extend the alignment sequences
	$a_al[$n] = $a[$i-1].$a_al[$n];  ## concatenate the strings
	$b_al[$n] = $b[$j-1].$b_al[$n];
	obtain_alignment($i-1, $j-1, $n); 
    }
    if($routes[$i][$j] & 2){
	if($route_count > 0){  ## in this case we are opening a new alignment
	    push @a_al, $al;
	    push @b_al, $bl;
	}
	## we define the local variable $an indicating which string we will be modifying.
	my $an = $#a_al;
	$route_count++;
	$a_al[$an] = "-".$a_al[$an];
	$b_al[$an] = $b[$j-1].$b_al[$an];
	obtain_alignment($i, $j-1, $an); 
    }
    ### and then do the same thing for the vertical movement
    if($routes[$i][$j] & 4){
	if($route_count > 0){  ## in this case we are opening a new alignment
	    push @a_al, $al;
	    push @b_al, $bl;
	}
	my $an = $#a_al;
	$a_al[$an] = $a[$i-1].$a_al[$an];
	$b_al[$an] = "-".$b_al[$an];
	obtain_alignment($i-1, $j, $an);
    }
}
