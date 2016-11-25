#!/usr/bin/perl -w

($minSize, $maxSize) = @ARGV;

for($s = $minSize; $s <= $maxSize; $s++){
    $seq1 = 'A'x$s;
    $seq2 = 'C'x$s;

    @s1 = ("");
    @s2 = ("");
    
    push @s1, split //, $seq1;
    push @s2, split //, $seq2;
    
    $step_count = 0;
    $align_count = 0;
    
    find_score(0, 0);
    
    print STDERR "$seq1 vs $seq2\n";
    print STDERR "total number of steps $step_count\n";
    print STDERR "total number of alignments $align_count\n";
    print "$s\t$step_count\t$align_count\n";
}
## a recursive function for searching through the positions in the sequences
sub find_score {
    my( $i, $j ) = @_;
    if( $i < $#s1 ){ find_score($i + 1, $j); }
    if( $j < $#s2 ){ find_score($i, $j + 1); }
    if( $i < $#s1 && $j < $#s2 ){ find_score($i + 1, $j + 1); }
    $step_count++;
    if($i == $#s1 && $j == $#s2){
	$align_count++;
    }
}

