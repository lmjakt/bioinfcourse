#!/usr/bin/perl -w

@v = (1, 100, 10, 20);
@i = 0..$#v;

@j = sort {$v[$b] <=> $v[$a]} @i;

for $i(@j){
    print $i, "\t", $v[$i], "\n";
}

init_array();

for $i(0..$#scores){
    print "  $scores[$i]\n";
    for $j(0..$#{$scores[$i]}){
	print "  $scores[$i][$j]";
    }
    print "\n";
}

sub init_array {
    our @scores;
    for my $i(0..10){
	for my $j(0..10){
	    $scores[$i][$j] = $i * $j;
	}
    }
}
