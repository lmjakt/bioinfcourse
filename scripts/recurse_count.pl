#!/usr/bin/perl -w

($a, $b) = @ARGV;

for $i(0..$a){
    for $j(0..$b){
	$counts[$i][$j] = 0;
    }
}

$count = recurse(0,0, 1);

for $i(0..$a){
    for $j(0..$b){
	print "\t", $counts[$i][$j];
    }
    print "\n";
}

print "number of paths for $a x $b = $count\n";

sub recurse {
    my($ai, $bi, $c) = @_;
    $counts[$ai][$bi]++;
    my $rcount = 0;
#    print "\t$ai,$bi\n";
    if($ai < $a){
	$c = recurse($ai+1, $bi, $c);
	$rcount++;
    }
    if($bi < $b){
	$c = recurse($ai, $bi+1, $c);
	$rcount++;
    }
    if($bi < $b && $ai < $a){
	$c = recurse($ai+1, $bi+1, $c);
	$rcount++;
    }
    if($rcount > 0){ $c += ($rcount - 1); }
    return($c)
}
