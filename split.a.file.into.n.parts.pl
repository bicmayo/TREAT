use strict;
use warnings;

##	INFO
##	Perl script is use to split a big file into n parts taking the line count into consideration

my $parts = $ARGV[0];
my $source = $ARGV[1]; # passed via command line
my $total = $ARGV[2];

my $num = '001';
my $dest = $source.".";
my $count = 0;
my $divide=0;
if ( ($total < $parts) || ($total < 50000) )	{
	$divide=$total;
}
else	{
	$divide = $total/$parts;
}
open FH, "<$source" or die "could not open $source : $!";
open OUT, ">$dest$num.txt" or die "could not open $dest : $!";

while (<FH>) {
	if ($. % $divide == 0)	{
		$num++;
		print OUT "$_";
		close OUT;
		open OUT, ">$dest$num.txt" or die "could not open $dest$num.txt : $!";
	}
	else	{
		print  OUT "$_";
	}	
}
close FH;
close OUT;
