#!/usr/bin/perl -w
use warnings;
use strict;

while( my $a = shift @ARGV ){
    print $a, "\n";
}

$a = 10;

my @ar = ("one", 2, 3.5);
##print $a, "\n";

{
    my $b = 100;
    our $a = 20;
    print_something();
    print_something();
    print "and here a is now $a\n";
}


for my $i(0..10){
    my $c = $a + $i;
}

for my $i(0..$#ar){
    print "ar[$i] is $ar[$i]\n";
}

print "log10 or 1000 is ", log(1000)/log(10), "\n";

#print "d is $d\n";
print "b is $b\n";

my @x = (1, 10, 100, 1000);
my @l = ();
while( my $v = pop(@x) ){
    push @l, log($v) / log(10);
}
for my $l(@l){
    print "  $l";
}
print "\n";

my %capitals = (japan => 'Tokyo',
		norway => 'Oslo',
		uk => 'London');
print "The capital of Norway is $capitals{norway}\n";

for my $i(0..10){
    $capitals{count}[$i] = "capital_$i";
}
for my $i(0..$#{$capitals{count}}){
    print "$i : $capitals{count}[$i]\n";
}

my @ar;
for my $x(0..2){
    for my $y(0..2){
	$ar[$x][$y] = 0;
	
    }
    print "ar[$x] : $ar[$x]\n";
}

for my $x(0..$#ar){
    for my $y(0..$#{$ar[$x]}){
	print $ar[$x][$y], "\n";
    }
    $capitals{arr}[$x] = [ @{$ar[$x]} ]
}

#$capitals{arr} = [@ar];
print "capitals{arr} $capitals{arr}\n";

for my $i(0..$#{$capitals{"arr"}}){
    print "$i\t$capitals{arr}[$i]\n";
}

my %hash;
for my $i(0..1){
    $hash{el1}[$i] = $i;
    $hash{el2}[$i] = $i * 2;
}

my @keys = keys %hash;
for my $k(@keys){
    for my $i(0..$#{$hash{$k}}){
	print "$k\t$i\t$hash{$k}[$i]\n";
    }
}


my @ar4 = (2, 4, 8);
my @ar5 = (10, 100, 1000);
my @ar6;
$ar6[0] = [ @ar4 ];
$ar6[1] = [ @ar5 ];

for my $i(0..$#ar6){
    for my $j(0..$#{$ar6[$i]}){
	print "$i  $j  $ar6[$i][$j]\n";
    }
}

my $fn = 'scripts/toy.fa';
open(my $fh, "<", $fn) || die "unable to open $fn $!\n";
while(<$fh>){
    print;
}

sub print_something {
    print "can I see a here? $a\n";
    $b += 10;
}
