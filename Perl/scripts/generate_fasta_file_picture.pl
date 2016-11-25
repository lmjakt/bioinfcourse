#!/usr/bin/perl -w



$pre_lines=2;
$s1_lines = 3;
$s2_lines = 4;

$line_space = 0.5;

$y = 12;
$x = 0;

$gt = "\\textgreater";

for($i = 0; $i < $pre_lines; $i++){
    print "\\draw [-, dashed] ($x, $y) -- ($x + 6, $y);\n";
    $y -= $line_space;
}

print "\\node [] (id1) at ($x,$y) {$gt};\n";
print "\\draw [-] (id1) -- ($x + 3, $y);\n";
$y -= $line_space;

for($i=0; $i < $s1_lines; $i++){
    print "\\draw [-] ($x, $y) -- ($x + 8, $y);\n";
    $y -= $line_space;
}

print "\\node [] (id2) at ($x,$y) {$gt};\n";
print "\\draw [-] (id2) -- ($x + 3.5, $y);\n";
$y -= $line_space;

for($i=0; $i < $s2_lines; $i++){
    print "\\draw [-] ($x, $y) -- ($x + 7.5, $y);\n";
    $y -= $line_space;
}

