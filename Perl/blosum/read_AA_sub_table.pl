#!/usr/bin/perl -w

for $infile(@ARGV){

    $outfile = $infile;
    $outfile =~ s/\.c$/\.txt/;
    if($outfile eq $infile){
	print STDERR "Unexpected filename: $infile\nSkipping this file\n";
	next;
    }
    open(IN, $infile) || die "unable to open $infile $!\n";
    open(OUT, ">", $outfile) || die "unable to open $outfile $!\n";

    $found_table = 0;
    $AA = 0;
    @AA = ();  ## bad.. 
    while(<IN>){
	chomp;
	if($_ =~ /static const/){  ## this is probably the first line of the table
	    $found_table = 1;
	    next;
	}
	if(!$found_table){
	    next;
	}
	if($_ =~ m#/\*([A-Z\*])\*/\s+-?\d+\.?\d*,\s+#){
	    $AA = $1;
	    push @AA, $AA;
	    $_ =~ s/,$//;    ## remove trailing comma
	    @tmp = split /,?\s+/, $_;
	    shift @tmp;    ## get rid of the first entry
	    shift @tmp;    ## we have also an empty string
	    $matrix{$AA} = [ @tmp ];
	    next;
	}
	if($AA && $_ =~ /^\s+-?\d+\.?\d*,\s+/){
	    $_ =~ s/^\s+//;  ## remove leading space
	    $_ =~ s/,$//;    ## remove trailing comma
	    @tmp = split /,\s+/, $_;
	    push @{$matrix{$AA}}, @tmp;
	    next;
	}
    }
    
    
    for $AA(@AA){
	print OUT "\t$AA";
    }
    print OUT "\n";
    
    for $A(@AA){
	print OUT $A;
	for $v(@{$matrix{$A}}){
	    print OUT "\t$v";
	}
	print OUT "\n";
    }
}

    
