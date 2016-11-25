#!/usr/bin/perl
use warnings;
use SVG;

if(@ARGV != 5){
    die "usage: SW_2016.pl seq_file1 seq_file2 matrix_file gap_open gap_extend\n";
}

($sfile1, $sfile2, $mfile, $gap_open, $gap_extend) = @ARGV;

@seq1 = read_fasta($sfile1);
@seq2 = read_fasta($sfile2);
%matrix = read_matrix($mfile);

init_tables($#seq1+1, $#seq2+1, $gap_open, $gap_extend);

## then simpy go through and set up the scores:
for($i=0; $i < @seq1; $i++){
    for($j=0; $j < @seq2; $j++){
        score_cell( $i+1, $j+1 );
    }
}

print "\t";
for $i(0..$#seq2){
    print "\t", $seq2[$i];
}
print "\n";

$max_score = 0;
$max_row = 0;
$max_column = 0;

for $i(0..$#scores){
    if($i > 0){
	print $seq1[$i-1];
    }
    for $j(0..$#{$scores[$i]}){
	if( $scores[$i][$j] > $max_score ){
	    $max_score = $scores[$i][$j];
	    $max_row = $i;
	    $max_column = $j;
	}
	print "\t$scores[$i][$j]";
    }
    print "\n";
}
print "\n";

for $i(0..$#scores){
    if($i > 0){
	print $seq1[$i-1];
    }
    for $j(0..$#{$scores[$i]}){
	print "\t$pointers[$i][$j]";
    }
    print "\n";
}


@aligns = ();
@align_scores = ();
$tmp_al = "";
traceback(\@aligns, $tmp_al, $max_row, $max_column, 0, \@align_scores);

## then do something with the aligns... 
print "Alignments:\n";
for $i(0..$#aligns){
#    print $aligns[$i], "\n";
    print "Alignment ", $i + 1, "\tscore: $align_scores[$i]\n";
    if($align_scores[$i] == $max_score){
	print_alignment($aligns[$i], $max_row, $max_column);
	print "\n";
    }
}

for $sc(@align_scores){
    print "\t$sc";
}
print "\n";

drawScoreTable("scoreMatrix.svg");

## determines the appropriate gap penalty
sub gp {
    my ( $i, $j, $d ) = @_;
    ## if $d is 1 then we are looking up
    if( $d == 1 && $pointers[$i-1][$j] & $d ){ return($gap_extend); }
    if( $d == 2 && $pointers[$i][$j-1] & $d ){ return($gap_extend); }
    return( $gap_open )
}


sub max_score {
    my $max = 0;
    for my $i(0..$#_){
        if( $max < $_[$i] ){ $max = $_[$i] };
    }
    my $ptr = 0;
    if( $_[0] == $max ){ $ptr = $ptr | 1; }
    if( $_[1] == $max ){ $ptr = $ptr | 2; }
    if( $_[2] == $max ){ $ptr = $ptr | 4; }
    return( $max, $ptr );
}

sub score_cell {
    my ($i, $j) = @_;
    ## make three different scores
    ## for the different alternatives
    my $sc_1 = $scores[$i-1][$j] + gp($i,$j,1);
    my $sc_2 = $scores[$i][$j-1] + gp($i,$j,2);
    my $sc_3 = $scores[$i-1][$j-1] +
	$matrix{ $seq1[$i-1] }{ $seq2[$j-1] };
    
    ## find the max score and set the
    ## score and the pointer tables
    ($scores[$i][$j], $pointers[$i][$j]) =
	max_score($sc_1, $sc_2, $sc_3);
}


sub init_tables {
    my($l1, $l2, $gap_open, $gap_extension) = @_;  ## the lengths of the sequences
    our @scores;
    our @pointers;
    ## first fill everything with 0s
    for my $i(0..$l1){
        for $j(0..$l2){
	    $scores[$i][$j] = 0;
	    $pointers[$i][$j] = 0;
        }
    }
    # ## the gap opening penalties
    # $scores[1][0] = $gap_open;
    # $scores[0][1] = $gap_open;
    # ## and the first pointers
    # $pointers[1][0] = 1;
    # $pointers[0][1] = 2;
    # ## the first extension penalties
    # for my $i(2..$l1){
    #     $scores[$i][0] = $scores[$i-1][0] + $gap_extension;
    #     $pointers[$i][0] = 1;
    # }
    # for my $i(2..$l2){
    #     $scores[0][$i] = $scores[0][$i-1] + $gap_extension;
    #     $pointers[0][$i] = 2;
    # }
}


sub read_matrix{
    my $mfile = shift @_;
    my %matrix = ();
    open(my $in, "<", $mfile) or die "unable to open $mfile $!\n";
    my $header_line = <$in>;
    chomp $header_line;
    my @aa2 = split /\s+/, $header_line;
    shift @aa2;
    while(<$in>){
        chomp;
        my @tmp = split /\s+/, $_;
        my $aa1 = shift @tmp;
        for my $i(0..$#tmp){
	    $matrix{$aa1}{$aa2[$i]} = $tmp[$i];
        }
    }
    return(%matrix);
}


sub read_fasta {
    ## reads a single sequence from a fasta file
    my $seqFile = shift @_;
    my $seq = "";
    open(my $in, "<", $seqFile) or die "unable to open $seqFile $!\n";
    my $found_identifier = 0;
    while(<$in>){
        chomp;
        if($_ =~ /^>\S+/ ){
	    if($found_identifier){
		last;
	    }else{
		$found_identifier = 1;
		next;
	    }
        }
        if($found_identifier){
	    $seq .= $_;
        }
    }
    ## return an array of letters instead.. 
    return( split //, $seq );
}
    
sub traceback {
    ## $al_ref is a reference to an array of strings
    ## The function pushes its $cigar to this when 
    ## it has a 0 pointer.. 
    my ($al_ref, $cigar, $i, $j, $score, $score_ref) = @_;
    if( $pointers[$i][$j] == 0 ){
        push @{$al_ref}, $cigar;
	push @{$score_ref}, $score;
        return;
    }
    ## we need to know how we got here... 
    my $p_ptr = 0;
    if(length($cigar)){
	my $c = substr($cigar, 0, 1);
	if($c eq 'I'){ $p_ptr = 1; }
	if($c eq 'D'){ $p_ptr = 2; }
    }
    if( $pointers[$i][$j] & 1 ){
        traceback($al_ref, 'I'.$cigar, $i-1, $j, $score + ($p_ptr & 1 ? $gap_extend : $gap_open), $score_ref);
    }
    if( $pointers[$i][$j] & 2){
        traceback($al_ref, 'D'.$cigar, $i, $j-1, $score + ($p_ptr & 2 ? $gap_extend : $gap_open), $score_ref);
    }
    if( $pointers[$i][$j] & 4){
#	print  "$i\t$j\t$seq1[$i-1]\t$seq2[$j-1]\n";
        traceback($al_ref, 'M'.$cigar, $i-1, $j-1, $score + $matrix{$seq1[$i-1]}{$seq2[$j-1]}, $score_ref);
    }
}

## this makes use of the global @seq1, and @seq2
## taking an expanded cigar string as an argument
sub print_alignment {
    my $cigar = shift @_;
    my $max_i = shift @_;
    my $max_j = shift @_;
    my @cigar = split //, $cigar;
    my $i = $max_i;
    my $j = $max_j;
    for my $c(@cigar){
	$i-- if $c ne 'D';
	$j-- if $c ne 'I';
    }
#    my $i2 = $i;
#    my $j2 = $j;
    my $line_length = 50;
    
    for(my $line_start = 0; $line_start < @cigar; $line_start += $line_length){
	my $line1 = "$i\t";
	my $line2 = "$j\t";
	my $midline = "\t";
#	print $line_start, "\n";
	my $line_end = $line_start + $line_length < @cigar ? $line_start + $line_length - 1 : $#cigar;
	for my $k($line_start..$line_end){
	    my $op = $cigar[$k];
	    if($op eq 'M'){
		$line1 .= $seq1[$i];
		$line2 .= $seq2[$j];
		if($seq1[$i] eq $seq2[$j]){
		    $midline .= '|';
		}else{
		    $midline .= '*';
		}
	    }
	    if($op eq 'D'){	
		$line1 .= '-';
		$line2 .= $seq2[$j];
		$midline .= ' ';
	    }
	    if($op eq 'I'){
		$line1 .= $seq1[$i];
		$line2 .= '-';
		$midline .= ' ';
	    }
	    $i++ if $op ne 'D';
	    $j++ if $op ne 'I';
	}
	print "$line1\t$i\n$midline\n$line2\t$j\n\n";
	# print "\n";
	# for my $k($line_start..$line_end){
	#     my $op = $cigar[$k];
	#     if($op eq 'M' && $seq1[$i2] eq $seq2[$j2]){
	# 	print "|";
	#     }else{
	# 	print " ";
	#     }
	#     $i2++ if $op ne 'D';
	#     $j2++ if $op ne 'I';
	# }
	# print "\n";
	# for my $k($line_start..$line_end){
	#     my $op = $cigar[$k];
	#     if($op eq 'I'){
	# 	print "-";
	#     }else{
	# 	print $seq2[$j];
	# 	$j++;
	#     }
	# }
	# print "\n";
    }
    print "\n-----------\n"
}

# ## this makes use of the global @seq1, and @seq2
# ## taking an expanded cigar string as an argument
# sub print_alignment {
#     my $cigar = shift @_;
#     my @cigar = split //, $cigar;
#     my $i = 0;
#     my $j = 0;
#     for my $op(@cigar){
# 	if($op eq 'D'){
# 	    print "-";
# 	}else{
# 	    print $seq1[$i];
# 	    $i++;
# 	}
#     }
#     print "\n";
#     $i = 0;
#     $j = 0;
#     for my $op(@cigar){
# 	if($op eq 'M' && $seq1[$i] eq $seq2[$j]){
# 	    print "|";
# 	}else{
# 	    print " ";
# 	}
# 	$i++ if $op ne 'D';
# 	$j++ if $op ne 'I';
#     }
#     print "\n";
#     $i = 0;
#     for my $op(@cigar){
# 	if($op eq 'I'){
# 	    print "-";
# 	}else{
# 	    print $seq2[$i];
# 	    $i++;
# 	}
#     }
#     print "\n";
# }


## a function that outputs an svg picture of the matrix
## again, be lazy and use global variables

sub drawScoreTable {
    my ($filename) = @_;
    ## some constants that we should make into optional arguments
    my $char_width = 20;
    my $line_height = 20;
    my $line_offset = 1;  ## draw the lines below the characters
    
    my $height = ($#seq1 + 3) * $line_height + $char_width;
    my $width = ($#seq2 + 3) * $char_width + $char_width;
    
    ## draw a rect to have a background
    my $bg_color = 'rgb(200, 200, 200)';
    my $svg = SVG->new(width=>$width, height=>$height);
    
    $svg->rect(x=>0, y=>0, width=>$width, height=>$height, fill=>$bg_color);

    ## draw the sequences
    for my $i(0..$#seq1){
	$svg->text(x=>$char_width/2, y=>((3 + $i) * $line_height), 'text-anchor'=>'middle')->cdata($seq1[$i]);
    }
    for my $i(0..$#seq2){
	$svg->text(x=>(2.5 + $i)*$char_width, y=>$line_height, 'text-anchor'=>'middle')->cdata($seq2[$i]);
    }
    ## and lets draw a couple of lines
    $svg->line(x1=>$char_width, y1=>$height, x2=>$char_width, y2=>0, stroke=>'rgb(0,0,0)', 'stroke-width'=>'0.5');
    $svg->line(x1=>0, y1=>$line_height+$line_offset, x2=>$width, y2=>$line_height+$line_offset, stroke=>'rgb(0,0,0)', 'stroke-width'=>'0.5');

    ## and a few more ones:
    for my $i(0..@seq1){
	$svg->line(x1=>0, y1=>($i + 2) * $line_height + $line_offset, x2=>$width, 
	y2=>($i + 2) * $line_height +$line_offset, stroke=>'rgb(0,0,0)', 
       'stroke-width'=>'0.5', 'stroke-opacity'=>0.5, 'stroke-dasharray'=>(1));
    }
    for my $i(0..@seq1){
	$svg->line(x1=>(1 + $i) * $char_width, y1=>0, x2=>(1 + $i) * $char_width, y2=>$height,
		   stroke=>'rgb(0,0,0)', 
		   'stroke-width'=>'0.5', 'stroke-opacity'=>0.5, 'stroke-dasharray'=>(1));
    }

    for my $i(0..$#scores){
	for my $j(0..$#{$scores[$i]}){
	    $svg->text( x=>($char_width * 1.5 + $j * $char_width), y=>(2 + $i) * $line_height, 'text-anchor'=>'middle')->cdata($scores[$i][$j]);
	}
    }

    my $xml = $svg->xmlify;
    open(my $out, ">", $filename) || die "unable to open $filename $!\n";
    print $out $xml;
    close $out;
}
