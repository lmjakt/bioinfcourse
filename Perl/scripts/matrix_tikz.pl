#!/usr/bin/perl -w

($matrixFile, $size) = @ARGV;

open($in, "<", $matrixFile) or die "unable to open $matrixFile $!\n";
$headerLine = <$in>;
chomp($headerLine);
@aa2 = split /\s+/, $headerLine;
shift @aa2;

while(<$in>){
    chomp;
    @tmp = split /\s+/, $_;
    $aa1 = shift @tmp;
    for $i(0..$#tmp){
	$matrix{ $aa1 }{ $aa2[$i] } = $tmp[$i];
    }
}

$top = 10;
$lw = 1.2;
$seq_space = 3;
$letter_space = 1.2;

for $i(1..$size){
    print "\\node [above right] at (", $i * $letter_space, ",", $top, ") {$aa2[$i-1]};\n";
    print "\\node [above right] at (", 0, ",", $top - $i * $lw, ") {$aa2[$i-1]};\n";
}

print "\\draw [dashed, -] (0,$top) -- (", ($size + 1) * $letter_space, ",$top);\n";
print "\\draw [dashed, -] (", $letter_space, ",", $top + $lw, ") -- ($letter_space, ", $top - $lw * $size, ");\n";

for($i=0; $i < $size; $i++){
    for($j=0; $j < $size; $j++){
	print "\\node [above] at (", (1.5 + $j) * $letter_space, ",", $top - ($i+1) * $lw, ") {$matrix{$aa2[$i]}{$aa2[$j]}};\n";
    }
}

print "\\visible<2->{\n";

print "\\draw [->, line width=2] (", (1.5 + $size) * $letter_space, ",", $top - $lw * $size/2, ") -- (", (3 + $size) * $letter_space,
    ",", $top - $lw * $size/2, ");\n";

$print_string = "\\node [right, align=left, scale=0.8] at (".((3.5 + $size) * $letter_space).",".($top - $lw * $size/2).") { ";

for $j(0..1){
    for($i=0; $i < $size; $i++){
	$print_string .= ' matrix\\{'.$aa2[$j].'\\}\\{'.$aa2[$i].'\\} = ';
	$print_string .= $matrix{$aa2[$j]}{$aa2[$i]}.'\\\\';
    }    
}
$print_string .= "};\n";
print $print_string;
print "\n}";


print "\n";
print_part_matrix(\%matrix, 10);

sub print_part_matrix {
    my($mref, $s) = @_;
    my @keys = sort keys %{$mref};
    for my $i(0..$s){
	print "$keys[$i]";
	for my $j(0..$s){
	    print "\t", $mref->{$keys[$i]}{$keys[$j]};
	}
	print "\n";
    }
}
