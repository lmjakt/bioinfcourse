#!/usr/bin/perl -w

print("$ARGV[0] \t $ARGV[1]\n");

@s1 = split //, $ARGV[0];
@s2 = split //, $ARGV[1];

print "@s1\n@s2\n";
#print "@s2\n";

$score = 0;
for $i(0..$#s1

){
    print "$s1[$i]\n";
    if($s1[$i] eq $s2[$i]){
	$score++; ## this means $score = $score + 1;
    }
}

print "$score\n";
