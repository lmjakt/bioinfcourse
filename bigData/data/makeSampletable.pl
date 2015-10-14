#!/usr/bin/perl -w

open(IN, "samples_unique.txt") || die "unable to open file $!\n";

$header = <IN>;

while(<IN>){
    chomp;
    @temp = split /\t/, $_;
    for $i(1..$#temp){
	$temp[$i] =~ s/\(.+//;
#	print "& $temp[$i]";
    }
    $samples{$temp[2]}{$temp[1]}{$temp[3]} = 1;
#    print "\n";
}

for $tissue(keys %samples){
    for $genotype(keys %{$samples{$tissue}}){
	for $drug(keys %{$samples{$tissue}{$genotype}}){
	    print "$tissue & $genotype & $drug \\\\\n";
	}
    }
}
