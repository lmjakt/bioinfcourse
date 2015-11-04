#!/usr/bin/perl -w

($infile, $start, $end) = @ARGV;

open(IN, $infile) || die "unable to open $infile $!\n";
while(<IN>){
    chomp;
    @tmp = split //, $_;
    for $i(0..$#tmp){
	if($i < $start || $i > $end){
	    print $tmp[$i];
	}
    }
    print "\n";
}

