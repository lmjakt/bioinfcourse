#!/usr/bin/perl -w

$fastaFile = shift @ARGV;
$outFile = shift @ARGV;
open($in, "<", $fastaFile) 
    || die "unable to open $fastaFile $!\n";
open($out, ">", $outFile) 
    || die "unable to open $outFile $!\n";

$id = 0;
$seq = "";
while(<$in>){
    chomp;
    if($_ =~ /^>(\S+)/){
	if( $id ){ print $out "$id\t$seq\n"; }
	$id = $1;
	$seq = "";
	next;
    }
    $seq .= $_;
}
print $out "$id\t$seq\n";
