# script to calculate transition to trnsversion ratio

#Transition [ A-G G-A C-T T-C ]
#Transversion [ C-G G-C G-T T-G A-T T-A C-A A-C ]

use strict;
use warnings;

open (DAT,"$ARGV[0]");
my $transition=0;
my $transversion=0;
while ( my $l = <DAT>)		{
	chomp $l;
	my @a = split ('\s+',$l);
	$a[2] =~ tr/[a-z]/[A-Z]/;
	$a[3] =~ tr/[a-z]/[A-Z]/;
	if( (($a[2] eq 'A') && ($a[3] eq 'G')) || 
		(($a[2] eq 'G') && ($a[3] eq 'A')) ||
		(($a[2] eq 'C') && ($a[3] eq 'T')) ||
		(($a[2] eq 'T') && ($a[3] eq 'C')) )	{
			$transition++;
	}
	else	{
		$transversion++;
	}
}
my $ratio=$transition/$transversion;$ratio=sprintf ("%.2f",$ratio);
print "$ratio\n";
		
