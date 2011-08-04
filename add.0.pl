use strict;
use warnings;

open FH, "$ARGV[0]" or die " can not open $ARGV[0]: $! \n";

while(my $l = <FH>)	{
	chomp $l;
	if($. == 1)	{
		print "$l\tDiseaseVariant\n";
	}
	else	{
		print "$l\t0\n";
	}
}
close FH;	