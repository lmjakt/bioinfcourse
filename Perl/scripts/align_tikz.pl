#!/usr/bin/perl -w

## create tikz code to visualise the ungapped alignment of two sequences against each other
($seq1, $seq2) = @ARGV;

@s1 = split //, $seq1;
@s2 = split //, $seq2;

$top = 15;
$lw = 1;
$seq_space = 1.5;
$letter_space = 0.6;

$vis = 1;

$offset = 2;
print "\\visible<", $vis, ">{\n";
for $i(0..$#s1){
    print "\t\\node  [] (a$i) at (0 + ", $letter_space * $i, ", $top) {$s1[$i]};\n";
}

$match = 0;
$mismatch = 0;

for $i(0..$#s1){
    print "\t\\node [] (b$i) at (", $letter_space * $offset + $letter_space * $i, ",", $top - $seq_space, ") {$s2[$i]};\n";
    if($i + $offset < @s1 && $i + $offset >= 0){
	if($s1[$i+$offset] eq $s2[$i]){
	    print "\t\\draw [line width=2, -] (a", $i+$offset, ") -- (b$i);\n";
	    $match++;
	}else{
	    print "\t\\node at (", $letter_space * $offset + $letter_space * $i, ",", $top - $seq_space/2, ") {*};\n";
	    $mismatch++;
	}
    }

}
$x = -length($seq1) + 6;
$x2 = $x + 8 * $letter_space;
$y = $top - $seq_space - 3 * $lw;
print "\t\\node [right] at ($x,$y) {matches};\n";
print "\t\\node [right] at ($x2,$y) {: $match};\n";
$y -= $lw;
print "\t\\node [right] at ($x,$y) {mismatches};\n";
print "\t\\node [right] at ($x2,$y) {: $mismatch};\n";
$y -= $lw;
print "\t\\node [right] at ($x,$y) {align length};\n";
print "\t\\node [right] at ($x2,$y) {: ", $match + $mismatch, "};\n";

print "}\n";
$vis++;


for $offset(-length($seq1)..length($seq1)){
#for $offset(-4..4){
    $match = 0;
    $mismatch = 0;
    print "\\visible<", $vis, ">{\n";
    for $i(0..$#s1){
	print "\t\\node  [] (a$i) at (0 + ", $letter_space * $i, ", $top) {$s1[$i]};\n";
    }
    
    for $i(0..$#s1){
	pringt "\t\\node [] (b$i) at (", $letter_space * $offset + $letter_space * $i, ",", $top - $seq_space, ") {$s2[$i]};\n";
	if($i + $offset < @s1 && $i + $offset >= 0){
	    if($s1[$i+$offset] eq $s2[$i]){
		print "\t\\draw [line width=2, -] (a", $i+$offset, ") -- (b$i);\n";
		$match++;
	    }else{
	    print "\t\\node at (", $letter_space * $offset + $letter_space * $i, ",", $top - $seq_space/2, ") {*};\n";
	    $mismatch++;
	    }
	}
    }
    $x = -length($seq1) + 6;
    $x2 = $x + 8 * $letter_space;
    $x3 = $x2 + 6 * $letter_space;
    $y = $top - $seq_space - 3 * $lw;

    print "\t\\node [right] at ($x,$y) {matches};\n";
    print "\t\\node [right] at ($x2,$y) {: $match};\n";
    $y -= $lw;
    print "\t\\node [right] at ($x,$y) {mismatches};\n";
    print "\t\\node [right] at ($x2,$y) {: $mismatch};\n";
    $y -= $lw;
    print "\t\\node [right] at ($x,$y) {align length};\n";
    print "\t\\node [right] at ($x2,$y) {: ", $match + $mismatch, "};\n";
    

    print "}\n";
    $vis++;
}

