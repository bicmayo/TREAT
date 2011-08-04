use strict;
use warnings;
use Getopt::Std;

our ($opt_i,$opt_s);
#print "Raw parameters: @ARGV\n";
getopt('is');

unless ( (defined $opt_i) && (defined $opt_s) ){
	die ("Usage: $0 n\t -i[ input BAM] \n\t-s [ path to samtools]\n");
}
my $infile = $opt_i;
my $samtools = $opt_s;
my @a=`$samtools/samtools view -H $infile`;
if(grep {$_ =~ "SO:coordinate"} @a)	{
	print"1\n";
}
else	{
	print "0\n";
}	
## end of script