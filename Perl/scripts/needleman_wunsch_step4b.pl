#!/usr/bin/perl -w

## create a scoring table for a Needleman-Wunsch alignment
## Use only a single gap penalty for both insertion and extension.
###
### THIS VERSION ALLOWS affine gap penalties

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

##### THIS IS THE NON-RECURSIVE FUNCTION ###############
## 3b modifies needleman_wunsch_part3.pl to use a non-recursive function
## that rather modifies the routing matrix to achieve the same thing.

### part 4 extends 3 to allow separate gap insertion and gap extension
### penalties. This requires only very modest changes to the code.
### 
## There is however a problem in determining if a score should be considered
## as a gap insertion or gap extension penalty when the prior entry contains
## a branch point. In such a circumstances we will end up with some mutually
## exclusive combination of routes. The easiest option is simply to follow
## all, and calculate the alignment scores accepting only those with the best
## score. Hopefully this will be obvious from the below code.

## The two sequences are given by the command line (@ARGV[0] and @ARGV[1]).

## define the match, mismatch and gap scores.
$match = 2;
$mismatch = -2;
$gap_insertion = -4;
$gap_extension = -1;

## check that we have some command line arguments..
if(@ARGV != 2){
    die "usage: needleman_wunsch_step3b.pl seq1 seq2\n";
}

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


## we can hence have 0 for no path, and initate scores and routes as follows

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
## sequence @b without any movement along @a.)
## the first column similarly represents gaps in sequence @b
## We first need to insert gap scores in these.

## The gaps start from the first position, not the last one
## so we use the range from 1..@a and 1..@b

## first fill in the top row (which has row number 0).
## and the routing information
$scores[0][1] = $gap_insertion;
$routes[0][1] = 2;
for $j(2..@b){
    $scores[0][$j] = $scores[0][$j-1] + $gap_extension;
    $routes[0][$j] = 2;
}

## then the first column (has column number 0).
$scores[1][0] = $gap_insertion;
$routes[1][0] = 4;
for $i(2..@a){
    $scores[$i][0] = $scores[$i-1][0] + $gap_extension;
    $routes[$i][0] = 4;
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

	## here we simply have to look back and consider the route of the
	## previos cell (i.e. the one from which we take the score)
	if($routes[$i+1][$j] & 2){
	    $s2 = $scores[$i+1][$j] + $gap_extension;
	}else{
	    $s2 = $scores[$i+1][$j] + $gap_insertion;
	}

	if($routes[$i][$j+1] & 4){
	    $s3 = $scores[$i][$j+1] + $gap_extension;
	}else{
	    $s3 = $scores[$i][$j+1] + $gap_insertion;
	}

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
## both initialised to hold a single empty string containing
## the aligned sequences with gaps inserted as necessary.

@a_al = ();
@b_al = ();

## we start from the bottom right hand corner;
$i = @a;
$j = @b;

## $ad_al indicates whether we need to find additional alignments
## i.e. there are remaining branchpoints in the matrix:
$ad_al = 1;
while($ad_al){
    ($ad_al, $al, $bl) = obtain_alignment( $i, $j, $n );
    push @a_al, $al;
    push @b_al, $bl;
}

for $i(0..$#a_al){
    $score = score_alignment($a_al[$i], $b_al[$i]);
    print "$i: $score\n";
    print_alignment($a_al[$i], $b_al[$i]);
}


## As having separate gap extension and insertion penalties can
## result in us getting non-optimal alignments we need to score the
## alignments. So make a function..
sub score_alignment{
    my @a = split //, $_[0];
    my @b = split //, $_[1];
    my $gap_opened = 0;
    my $score = 0;
    ## assume that the lengths are the same..
    for my $i(0..$#a){
	if($a[$i] eq "-" || $b[$i] eq "-"){
	    ## here we introduce the ternary operator
	    ## a very useful operator. It can be read as follows
	    ## if the expression before the '?' is true, then return the value before
	    ## the ':', otherwise return the value after the ':'.
	    $score = ($gap_opened) ? $score + $gap_extension : $score + $gap_insertion;
	    $gap_opened = 1;
	    next;
	}
	if($a[$i] eq $b[$i]){
	    $score += $match;
	}else{
	    $score += $mismatch;
	}
	$gap_opened = 0;
    }
    return($score);
}

## a function to print the alignment..
sub print_alignment{
    my @a = split //, $_[0];
    my @b = split //, $_[1];
    for my $n(@a){  ## another way to loop through values
	print $n;
    }
    print "\n";
    for(my $i=0; $i < @a && $i < @b; $i++){
	if($a[$i] eq $b[$i]){
	    print "|";
	}else{
	    if($a[$i] eq '-' || $b[$i] eq '-'){
		print " ";
	    }else{
		print "*";
	    }
	}
    }
    print "\n";
    for my $n(@b){
	print $n;
    }
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
	    print "\t", $table[$i][$j];
	}
	print "\n";
    }
    print "=======================================\n";
}


sub obtain_alignment{
    my($i, $j) = @_;
    ## $i is the row of the entry (cell) that we are looking at
    ## $j is the column
    ## This function will modify the two global arrays @a_al, and @b_al
    ## these hold the alignments as strings with added gaps represented
    ## by '-' characters
 
    ## don't do anything if we've reached the end
    if($i == 0 && $j == 0){ return; }

    ## each time this function is called it follows the routing matrix
    ## from the starting point specifed ($i, $j) moving backwards. If
    ## a branch point is encountered we follow the lowest valued route
    ## and store the coordinates of the branch point in $i_rm, $j_rm as well
    ## as the route we followed in $rm_type.
    ## The route followed at the last branch point encountered is removed from
    ## the matrix by simple subtraction (could also be done by bitwise XOR).

    my $i_rm = -1;
    my $j_rm = -1;
    my $rm_type = 0;

    ## the aligned sequences (i.e. with inserted gaps) are defined as local variables:
    my $al = "";
    my $bl = "";

    ## and we have a counter to indicate if there are additional routes to be followed
    ## (i.e. we have encountered branch points)
    my $additional_routes = 0;


    while($i > 0 || $j > 0){
	my @routes_followed = ();
	my $ni = $i;
	my $nj = $j;  ## these are $i and $j for the next iteration
	## look at the route information

	if($routes[$i][$j] & 1){    ## we have a diagonal route
	    push @routes_followed, 1;
	    ## then extend the alignment sequences
	    $al = $a[$i-1].$al;  ## concatenate the strings
	    $bl = $b[$j-1].$bl;
	    $ni--;
	    $nj--;
	}
	if($routes[$i][$j] & 2){   ## we have a leftward route,
	    if(!@routes_followed){
		$al = "-".$al;
		$bl = $b[$j-1].$bl;
		$nj--;
	    }
	    push @routes_followed, 2;
	}
	if($routes[$i][$j] & 4){   ## we have an upward route
	    if(!@routes_followed){
		$al = $a[$i-1].$al;
		$bl = "-".$bl;
		$ni--;
	    }
	    push @routes_followed, 4;
	}
	## check to make sure that we have some route out of the current cell
	if(!($routes[$i][$j] & 7)){  ## 7 is 0111, so if any flag is set this should give a positive value
	    print STDERR "$i, $j: We have a problem. Exiting the alignment extraction\n";
	    last;
	}
	#### only the route followed at the last branch point should be removed
	if(@routes_followed > 1){
	    $i_rm = $i;
	    $j_rm = $j;
	    $rm_type = $routes_followed[0];
	    $additional_routes += (@routes_followed - 1);
	}
	$i = $ni;
	$j = $nj;
    }
    ## remove if $rm_type is non-0 (i.e. TRUE)
    if($rm_type){
	$routes[$i_rm][$j_rm] -= $rm_type;
    }
    return($additional_routes, $al, $bl);
}
