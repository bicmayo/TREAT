### script to split the variant file in ranges of 10,000 variants
## samr column for SNV and INDEL
##SNV	: 	chr7	35054	A	T	AT	3	4	7	0.95
##INDEL	:	chr7	54013	54014	-T:15/54

use strict;
use warnings;

if(scalar(@ARGV) != 3)	{
		die "Usage :\nperl split.variants.coordinate.pl <variant file><SNV/INDEL><target kit (YES, NO)\n" ;

	}
my $source = shift @ARGV;
my $variant = shift @ARGV;
my $Target = shift @ARGV;
my $num = '001';
my $dest = $source.".";

open FH, "<$source" or die "could not open $source : $!";
open OUT, ">$dest$num.txt" or die "could not open $dest : $!";
my $start_pos=0;
my $end_pos=0;
my $add=5000000;
if ($variant eq 'SNV')	{
	$add=5000000;
}
else	{
	$add=10000000;
}
if ($Target eq 'YES')	{
	$add=100000000;
}	

while(<FH>)	{
	my @call = split(/\t/,$_);
	if($. == 1)	{
		$start_pos = $call[1];
		print OUT "$_";
		$end_pos = $add + $start_pos;
#		print "$start_pos\n";
#		print "$end_pos\n";
	}
	else	{
		if ($call[1] > $end_pos )	{
			$num++;
			print OUT "$_";
			close OUT;
			open OUT, ">$dest$num.txt" or die "could not open $dest$num.txt : $!";
			$start_pos = $end_pos;
			$end_pos = $start_pos + $add;
#			print "$start_pos\n";
#	                print "$end_pos\n";

		}
		else	{
			print  OUT "$_";
		}
	}	
}
close FH;				
close OUT;		
