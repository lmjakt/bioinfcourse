#!/usr/bin/perl -w

@a = (0,1);
for($i = 2; $i < 100; $i++){
    $a[$i] = $a[$i-2] + $a[$i-1];
}

for $v(@a){
    print "$v\n";
}


