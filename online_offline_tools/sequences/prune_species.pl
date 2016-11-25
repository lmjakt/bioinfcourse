#!/usr/bin/perl -w
## This reads the sequences from STDIN
$skip_seq = 0;
%species = ();                                                                                                                       

while(<>){
    if( $_ =~ /^>\S+\s+.+?\[(.+)\]$/){ # \[(.+?)\]/ ){
	print STDERR "species is $1\n";
	$skip_seq = defined( $species{$1} );
	$species{$1} = 1;
    }
    if(!$skip_seq){
	print;
    }
}
