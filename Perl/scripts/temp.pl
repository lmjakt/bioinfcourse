#!/usr/bin/perl -w

@v = (1,2,3,4,5,5);

print "the mean value is: ", mean(@v), "\n";

##print "the mean value is: ", mean @v, "\n";
$m = mean( @v );
$sm = sqrt $m;

print "sm is $sm\n";
print "and sqrt($m)\n";

sub mean {
    my $m = 0;
    for my $v(@_){
	$m += $v;
    }
    return($m);
}
