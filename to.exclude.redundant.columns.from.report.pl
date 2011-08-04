# script to remove columns from final report
# Coordinates	chromosome	position	referenceBase	sampleGenotype	functionDBSNP	nickLab	dbSNPValidation	clinicalAssociation	 

use strict;
#use warnings;


open(REPORT,"$ARGV[0]");

my $hdr=<REPORT>;

my $hdr1=<REPORT>;
my $j=0;
my @header_array = split (/\t/,$hdr1);
my $header_len = @header_array;
#print"$header_len\n";
my @ColToDel;
for (my $i=0; $i<$header_len; $i++){
	if ( ($header_array[$i] =~ /Coordinates/) || ($header_array[$i] =~ /chromosome/) || ($header_array[$i] =~ /position/) || 
		($header_array[$i] =~ /referenceBase/) || ($header_array[$i] =~ /sampleGenotype/) || ($header_array[$i] =~ /functionDBSNP/) || 
		($header_array[$i] =~ /nickLab/) || ($header_array[$i] =~ /dbSNPValidation/) || ($header_array[$i] =~ /clinicalAssociation/) || ($header_array[$i] =~ /^rsID/) || ($header_array[$i] =~ /^dbSNP ID/))
	{
		 $ColToDel[$j]= $i;
		 $j++;
	}
}
print "Columns Numbers to remove : @ColToDel\n";
my $columnsToDel=@ColToDel;
close REPORT;
my $count=0;

open(OUT,">$ARGV[1]");
open(REPORT1,"$ARGV[0]");
my $hdr_new=<REPORT1>;
print OUT "$hdr_new";

while(my $l = <REPORT1>)	{
	chomp $l;
	my @a= split(/\t/,$l);
	for (my $i=0; $i<$header_len; $i++)	{
		$count=0;
		for(my $j=0; $j<$columnsToDel;$j++)	{
			if($i == $ColToDel[$j])	{
			#	print "Column Skipped\n";
				$count=1;
			}
		}
		if($count == 0)	{
			if($i == $header_len - 1 )	{
				print OUT "$a[$i]";
			}
			else	{	
				print OUT "$a[$i]\t";
			}	
		}
	}
	print OUT "\n";
	#print <STDIN>;
}
close REPORT1;		