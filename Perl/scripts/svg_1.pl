#!/usr/bin/perl -w
use strict;
use SVG;

## this was just taken from :
## http://roitsystems.com/tutorial/tutorial2.html
##
## and modified to find out how to work it.

# create an SVG object
my $svg= SVG->new(width=>200,height=>200);    
# draw a circle at position (100,100)  with ID 'this_circle'  
##$svg->circle(id=>'this_circle',cx=>100,cy=>100,r=>50); 

$svg->circle(cy=>20, cy=>10, r=>30, stroke=>'red',fill=>'green');
$svg->circle(cy=>20, cy=>10, r=>30, style=>{stroke=>'red', fill=>'green'});

# Define a style %group_style
my %group_style = (
    'opacity'=>1,fill=>'red',
    'stroke'=>'green','fill-opacity'=>0.4,
    'stroke-opacity'=>'1');


# create a group with style %style.
# Every drawn object within this group
# will have the styles defined in %group_style unless
# otherwise specified.
# but first, let's draw an XML <!-- --> comment

$svg->comment('Draw a group with two circles that have url links');

$svg->comment('Define a child of $svg called $gp1');
my $gp1 = $svg->group(id=>'group_1',style=>\%group_style);
my $a1 = $gp1->anchor(-href=>'www.w3c.org');
$a1->circle(id=>'this_circle',cx=>170,cy=>100,r=>20);
$a1->circle(id=>'that_circle',cx=>100,cy=>170,r=>20);
# define a third circle with a separate style (stroke colour),
# overriding the group stroke colour definition.
$a1->circle(id=>'the_other_circle',cx=>180,cy=>160,r=>20,
            style=>{stroke=>'cyan'}); 

# add a second group, and give that group
# two text elements with cdata entries
$svg->comment('Draw a second group with two text entries One entry has an anchor');
my $gp2 = $svg->group(id=>'group_2');
$svg->comment('Here is one way to define text');
my $t1 = $gp2->text(x=>80,y=>20);
$t1->cdata('Tutorial');

$svg->comment('Here is another way to define text');
$gp2->text(x=>120,y=>20)->cdata('Two');
$gp2->anchor(-href=>'/SVG.html')
      ->text(x=>20,y=>40,fill=>'rgb(200,30,100)')
      ->cdata('Brought to you by the letters SVG and pm');
$svg->comment("Well, we're done here");

my @nuc = qw(A C G T);
for my $i(0..19){
    $svg->text(x=>$i * 10, y=>100)->cdata($nuc[ $i % 4 ]);
    $svg->text(x=>$i * 10, y=>10)->cdata($nuc[ $i % 4 ]);
}
    

my $out = $svg->xmlify;

print $out;

