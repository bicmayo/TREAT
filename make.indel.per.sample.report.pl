# script to parse the indel output from GATK to make per sample output report
use strict;
use warnings;
use Getopt::Std;

our ($opt_i, $opt_s, $opt_o, $opt_a);
print "INFO: file to parse the INDEL old GATK format \n";
print "RAW paramters: @ARGV\n";
getopt('isoa');
if ( (!defined $opt_i) && (!defined $opt_s) && (!defined $opt_o) && (!defined $opt_a) ) {
        die ("Usage: $0 \n\t-i [nput file] \n\t-s [sample] \n\t-o [utput file] \n\t -a [analysis tyep]\n");
}
else    {
	my $input = $opt_i;
	my $sample = $opt_s;
	my $output = $opt_o;
	my $analysis = $opt_a;
	open FH, "<$input" or die " can not open $input :$! \n";
	open OUT, ">$output" or die " can not open $output :$! \n"; 
	my ($sign,$ref,$alt,$bases,$capture);
	print OUT "\t\t\t\t\t\t\t$sample\n";
	if($analysis eq 'annotation')	{
			print OUT "Chr\tStart\tStop\tRef\tAlt\tBase-Length\tIndel-supportedRead\tReadDepth\n";
	}
	else	{
		print OUT "Chr\tStart\tStop\tInCaptureKit\tRef\tAlt\tBase-Length\tIndel-supportedRead\tReadDepth\n";
	}
	while(my $l = <FH>)	{
		chomp $l;
		my @a = split (/[:\/\s]/,$l);
		$capture=$a[$#a];
		$a[6] = substr($a[3],1);
		$bases=length($a[6]);
		if($a[3] =~ m/(\W)/)	{
			$sign=$1;
			if($sign eq '+')	{
				$ref='-';
				$alt=$a[6];
			}
			else	{
				$ref=$a[6];
				$alt='-';
			}
		}
		if($analysis eq 'annotation')	{
			print OUT "$a[0]\t$a[1]\t$a[2]\t$ref\t$alt\t$bases\t$a[4]\t$a[5]\n";
		}
		else	{
			print OUT "$a[0]\t$a[1]\t$a[2]\t$capture\t$ref\t$alt\t$bases\t$a[4]\t$a[5]\n";
		}	
	}
	close FH;
}	