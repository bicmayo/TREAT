use strict;
use warnings;

if (scalar(@ARGV) != 5)	
{
	die ( "Usage: matching_ucsc_tracks.pl <List with SNVs in bed frmt-full path> < UCSC track in bed frmt - full path> <ouputfile-full path> <name of track, eg: Regulation> <chromosome>" );
}

my %hashtrack=();
my $which_chr=$ARGV[4];
my $comp="chr".${which_chr};
open (TRACK,"$ARGV[1]");
while(my $track = <TRACK>)
{
	chomp $track;
	my @a2 = split (/\t/, $track);
	if ($a2[0] eq $comp)	{
		my $uniq2 = $a2[0]."_".$a2[6];
		$hashtrack{$uniq2}=join("\t", $uniq2);
	}	
}
close TRACK;

open (OUT, ">$ARGV[2]");
print OUT "\n";
print OUT "$ARGV[3]\n";
open (SNV, "$ARGV[0]");
while(my $snv = <SNV>)
{
	chomp $snv;
	my @a1 = split (/\t/,$snv);
	my $uniq1 = $a1[0]."_".$a1[2];
	if(defined $hashtrack{$uniq1} )
	{
		print OUT "1\n";
	}
	else
	{
		print OUT "0\n";
	}
}

close SNV;		
close OUT;


