#!/usr/bin/perl -w

## take two sequences and create tikz code that visualises the
## Smith Waterman algorithm.
## This code is a modified version of the Needleman-Wunsch 
## implementation in this directory (hence a bit messy)

($seq1, $seq2, $mp, $mmp, $gop, $gep) = @ARGV;
## these are :
## sequence 1
## sequence 2
## the match penalty (positive)
## mismath penalty (negative)
## gap opening penalty
## gap extension penalty

(@ARGV == 6) || die "usage: needleman_tikz.pl seq1 seq1 match_penalty mismatch_penalty gap_opening_penalty gap_extension_penalty\n";

@seq1 = split //, $seq1;
@seq2 = split //, $seq2;

$fsscale = 0.5; ## used for drawing scores

## put the terms at the bottom
print "\\node [right] at (1,-1) {Match $mp};\n";
print "\\node [right] at (7,-1) {Mismatch $mmp};\n";
print "\\node [right] at (1,-2.5) {Gap open $gop};\n";
print "\\node [right] at (7,-2.5) {Gap ext. $gep};\n";

## draw the grid...
## we simply use a size of 1 for each position, let the final user
## scale to fit appropriately.
$sn1 = scalar(@seq1);
$sn2 = scalar(@seq2);

$stage = 2;
print '\visible<', $stage, "->{\n";
$stage++;
print '\draw [-] (', "0.5,", $sn2+1.5, ') -- (', $sn1+2.5, ',', $sn2+1.5, ");\n";
print '\draw [-] (', "1.5,", $sn2+2.5, ') -- (', 1.5, ',', 0.5, ");\n";

print '\draw [-, dotted, opacity=0.5] (', "0.5,", $sn2+0.5, ') -- (', $sn1+2.5, ',', $sn2+0.5, ");\n";
print '\draw [-, dotted, opacity=0.5] (', "2.5,", $sn2+2.5, ') -- (', 2.5, ',', 0.5, ");\n";


for $i(0..$#seq1){
    print "\t", '\node at (', $i+3, ',', $sn2+2, ') {', $seq1[$i], "};\n";
    if($i < $#seq1){
	print "\t", '\draw [-, dotted, opacity=0.5] (', $i+3.5,',',$sn2+2.5,') -- (', $i+3.5, ',', 0.5, ");\n";
    }
}

for $i(0..$#seq2){
    print "\t", '\node at (', 1, ',', $sn2 - $i, ') {', $seq2[$i], "};\n";
    if($i < $#seq2){
	print "\t", '\draw [-, dotted, opacity=0.5] (0.5,', $sn2-$i-0.5, ') -- (', $sn1+2.5, ',', $sn2-$i-0.5, ");\n";
    }
}

print "}\n", '\visible<', $stage, "->{\n";
$stage++;

## lets prepare a two dimensional array to put scores in.
## we also want to have a two dimensional array to put the paths
## in. As this can have more than one arrow, we can put in arrays of arrays?
## this part would certainly be simpler in C++. Hmm, but whatever.
## then we need something to tell us if gaps have been openend or not.
## simple array of 0 or 1 (booleans).

for $i(0..@seq2){
    for $j(0..@seq1){
	$scores[$i][$j] = 0;
	$h_gap_opened[$i][$j] = 0;  ## for horizontal gaps
	$v_gap_opened[$i][$j] = 0;  ## for vertical gaps
    }
}

## then let's go through and fill in the initial gap penalties
## in the first row we have to separate
## In Smith Waterman, there are no values below 0, so these all get set to 0.

print "\t", '\node', "[scale=$fsscale] at (2,", $sn2+1, ") {0};\n";
#$p = 0;
print "\t", '\node', "[scale=$fsscale] at (3,", $sn2+1, ") {0};\n";
#print "\t", "\\draw [->] (2.65, $sn2+1) -- (2.35, $sn2+1);\n";
$scores[0][1] = 0;
##$h_gap_opened[0][1] = 0;
for $i(1..$#seq1){
#    $p += $gep;
    print "\t", '\node', "[scale=$fsscale] at(", $i+3,',', $sn2+1, ") {0};\n";
#    print "\t", "\\draw [->] (", $i+2.65, ",$sn2+1) -- (", $i+2.35, ",$sn2+1);\n";
##    $path[0][$i] = [(1)];
    $scores[0][$i+1] = 0;
    ##$h_gap_opened[0][$i+1] = 0;
}

$path[0][0] = ();
for $i(1..@seq1){
    $path[0][$i] = [()];
}
for $i(1..@seq2){
    $path[$i][0] = [()];
}
#$p = $gop;
print "\t", '\node', "[scale=$fsscale] at (2,", $sn2, ") {0};\n";
#print "\t", "\\draw [->] (2,$sn2 + 0.35) -- (2, $sn2 + 0.65);\n";
$scores[1][0] = 0;
##$v_gap_opened[1][0] = 0;
for $i(1..$#seq2){
#    $p += $gep;
    print "\t", '\node', "[scale=$fsscale] at(2,", $sn2-$i, ") {0};\n";
##    print "\t", "\\draw [->] (2,$sn2-$i + 0.35) -- (2, $sn2-$i + 0.65);\n";
##   $path[$i][0] = [(2)];
    $scores[$i+1][0] = 0;
##    $v_gap_opened[$i+1][0] = 0;
}
print "}\n";

### then finally we can go through and fill  in all of the scores for the alignment
@maxPos = (0,0); ## express as the row and column, i, j.
$maxScore = 0;
for $i(0..$#seq2){
    print '\visible<', $stage, "->{\n";
    $stage++;
    for $j(0..$#seq1){
	## make short array for the different options
	## diagonal, above, left
	$s[0] = $scores[$i][$j] + ($seq2[$i] eq $seq1[$j] ? $mp : $mmp);
	$s[1] = $scores[$i+1][$j] + ($h_gap_opened[$i+1][$j] ? $gep : $gop);
	$s[2] = $scores[$i][$j+1] + ($v_gap_opened[$i][$j+1] ? $gep : $gop);
	## find the maximal score(s)
	@mi = maxI(@s);
	$score = $s[ $mi[0] ];
	if($score > 0){
	    $scores[$i+1][$j+1] = $s[ $mi[0] ];
	    ## this is quite convenient, as @mi gives us the path that was followed
	    $path[$i+1][$j+1] = [@mi];
	}else{
	    $path[$i+1][$j+1] = [()];
	    $score = 0;
	}
	if($score > $maxScore){
	    $maxScore = $score;
	    @maxPos = ($i+1, $j+1);  ##
	}
	## and let's print out the score here
	print "\t\\node [scale=$fsscale] at (", $j+3, ",", $sn2-$i, ") {$score};\n";
	## and draw the appropriate arrows and set the appropriate extension
	## flags
	if($score > 0){
	    for $k(@mi){
		## $k can take one of three values
		if($k == 0){
		    print "\t\\draw [->] (", $j+2.65, ",", $sn2-$i+0.35, ") -- (", 
		    $j+2.35, ",", $sn2-$i+0.65, ");\n";
		}
		if($k == 1){
		    print "\t\\draw [->] (", $j+2.65, ",", $sn2-$i, ") -- (",
		    $j+2.35, ",", $sn2-$i, ");\n";
		    $h_gap_opened[$i+1][$j+1] = 1;
		}
		if($k == 2){
		    print "\t\\draw [->] (", $j+3, ",", $sn2-$i+0.35, ") -- (",
		    $j+3, ",", $sn2-$i+0.65, ");\n";
		    $v_gap_opened[$i+1][$j+1] = 1;
		}
	    }
	}
    }
    print "}\n";
}

## to follow the path of the optimal alignment start at the 
## top scoring cell and read backwards
$i = $maxPos[0]; ## scalar @seq2;
$j = $maxPos[1]; ## scalar @seq1;
## because we do not know how many paths we will obtain, this is easiest done
## using a recursive function.

@aligns1 = ("");
@aligns2 = ("");

find_path($i, $j, 0, 0);

sub find_path {
    my($i, $j, $n, $l) = @_;
    ## first draw the position for the alignment..
    #if(($i <= 0 && $j <= 0) || ($i < 0 || $j < 0) ){ 
#	print STDERR "|||\n"; 
#	return; 
#    }
    print '\visible<', $stage, "->{\n";
    $stage++;
    print "\\draw [fill=yellow, fill opacity=0.1] (", $j+1.5, ",", $sn2-$i+0.5, ") rectangle (",
    $j+2.5, ",", $sn2-$i+1.5, ");\n";
    print "}\n";
    $l++;
    for my $k(0..$#{$path[$i][$j]} ){
	my $v = $path[$i][$j][$k];
	if($k > 0){ 
	    $n++; 
	    push @aligns1, substr($aligns1[-1], 0, $l-1);
	    push @aligns2, substr($aligns2[-1], 0, $l-1);
#	    print STDERR "l $l: $i,$j\n";
#	    print STDERR "aligns1: $aligns1[$n-1] -> $aligns1[$n]\n";
#	    print STDERR "aligns2: $aligns2[$n-1] -> $aligns2[$n]\n";
	}
	if($v == 0 && $i > 0 && $j > 0){
	    $aligns1[$n].= $seq1[$j-1]; 
	    $aligns2[$n].= $seq2[$i-1]; 
	    find_path( $i-1, $j-1, $n, $l );
	}
	if($v == 1 && $j > 0){
	    $aligns1[$n].= $seq1[$j-1]; 
	    $aligns2[$n].= "-"; 
	    find_path( $i, $j-1, $n, $l ); 
	}
	if($v == 2 && $i > 0){
	    $aligns1[$n].= "-";
	    $aligns2[$n].= $seq2[$i-1]; 
	    find_path( $i-1, $j, $n, $l); 
	}
    }
}

print '\visible<', $stage, "->{\n";
$stage++;

$alX=4 + scalar( @seq1 );
$alY= $sn2 -1 ;
for $i(0..$#aligns1){
    @ts1 = split //, $aligns1[$i];
    @ts2 = split //, $aligns2[$i];
    for $i(0..$#ts1){ 
	$j = $#ts1-$i;
	print STDERR $ts1[$j]; 
	print "\\node [scale=0.75] (s1) at ($alX + $i/2.5, $alY) {$ts1[$j]};\n";
	print "\\node [scale=0.75] (s2) at ($alX + $i/2.5, $alY-1.25) {$ts2[$j]};\n";
	if( $ts1[$j] eq $ts2[$j] ){
	    print "\\draw [-] (s1) -- (s2);\n";
	}
    }
    print STDERR "\n";
    for $i(0..$#ts2){
	print STDERR $ts2[$#ts2 - $i];
    }
    print STDERR "\n";
    $alY -= 3;
}
print "}\n";

sub maxI {
    my @mi = (0);
    for my $i(1..$#_){
	if($_[$i] == $_[ $mi[0] ]){ push @mi, $i };
	if($_[$i] > $_[$mi[0]]){ @mi = ($i) };
    }
    return(@mi);
}
