## Perl script to pull percent codon usage and find the difference

use strict;
use warnings;

#check for presence of all i/p and o/p files
if (scalar(@ARGV) != 3)	
{
	die ( "Usage:\ncodon_pref.pl <codon preference table> <file containing list of codon changes from SIFT, column 16 only> <Ouput file>\n" );
}

my %hash1=();
# my %hash2=();

#Reading the master file containing percentage codon usage
open (FIRST,"$ARGV[0]");
while(my $line = <FIRST>)	
{
	next if ($line =~ m/Percentage|of|Codon|Synonymous|Usage|in|Mammals/);
	chomp $line;
	my @array = split('\t',$line);
	my $uniq = $array[0];
	$hash1{$uniq} = $array[1];
}
close FIRST;

#Reading column from SIFT "Codons" and outputting respective codon usage and difference
open (SECOND,"$ARGV[1]");
open (OUT, ">$ARGV[2]");
print OUT "\n";
print OUT "SynonymousCodonUsage\tDifference\n";
while(my $line = <SECOND>)	
{
	next if ($line =~ m/Codons|SNP Type/);
	next if ($. == 1);
	if ($line !~ m/Synonymous/) # Filling in for '-'
	{
		chomp $line;
		# $line=~ s/\s+//;
		print OUT "-\t-\n";
	}
	else
	{
		chomp $line;
		my @temp = split ('\t',$line);
		my $uc_line = uc($temp[0]); # converting to upper case
		chomp $uc_line;
		$uc_line=~ s/\s+//;
		my @array = split('-',$uc_line);
		$array[0] =~ s/\s+//g;
		$array[1] =~ s/\s+//g;
		$hash1{$array[0]} =~ s/\s+//g;
		$hash1{$array[1]} =~ s/\s+//g;
		my $diff = sprintf("%.1f",($hash1{$array[0]} - $hash1{$array[1]})); # finding difference
		# my @original = split('-',$temp[0]);
		# $original[0] =~ s/\s+//g;
		# $original[1] =~ s/\s+//g;
		# print OUT "$original[0]\-$original[1]\t$hash1{$array[0]}\%\ - $hash1{$array[1]}\%\t$diff\%\n";
		print OUT "$hash1{$array[0]}\%\ - $hash1{$array[1]}\%\t$diff\%\n";

	}
}
close SECOND;
close OUT;




