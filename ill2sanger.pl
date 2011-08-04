## INFO
## script to convert illumina to sanger quality
## SaurabhBaheti	
## 06/06/2011

use strict;
use warnings;
use Getopt::Std;

our ($opt_i, $opt_o);
print "\nINFO - Script to convert illumina scores to sanger score\n";
print "RAW paramters: @ARGV\n";
getopt('io');
if ( (!defined $opt_i) && (!defined $opt_o) ) {
        die ("Usage: $0 \n\t -i [ nput fastq ]  \n\t -o [ utput fastq ]\n");
}
else	{
	my $source=$opt_i;
	my $dest=$opt_o;
	open FH, "<$source" or die "can not open $source : $!\n";
	open OUT, ">$dest" or die "can not open $dest : $!\n";
	while (my $l = <FH>)	{
		chomp $l;
		if ( $. % 4 == 0 )	{	
			$l =~ tr/\x40-\xff\x00-\x3f/\x21-\xe0\x21/;
			print OUT "$l\n";
		}
		else	{
			print OUT "$l\n";
		}
	}
	close FH;
	close OUT;
}
	
