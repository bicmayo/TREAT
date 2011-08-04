use strict;
use warnings;
use Getopt::Std;

our ($opt_i,$opt_s);
getopt('is');

unless ( (defined $opt_i) && (defined $opt_s) ){
	die ("Usage: $0 n\t -i[ input BAM] \n\t-s [ path to samtools]\n");
}
my $infile = $opt_i;
my $samtools = $opt_s;
my $sort_flag=0;
my $RG_flag=0;
my @a=`$samtools/samtools view -H $infile`;
if(grep {$_ =~ "SO:coordinate"} @a)	{
	$sort_flag=1;
}
else	{
	$sort_flag=0;
}	

if(grep {$_ =~ "^\@RG"} @a)	{
	$RG_flag=1;
}
else	{
	$RG_flag=0;
}	

if( ($sort_flag == 1) && ($RG_flag == 1) )	{
	print"1\n";
}
else	{
	print "0\n";
}	