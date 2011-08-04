## Saurabh Baheti: 09/16/2010
## Take .snv.ToMerge files from various lanes / samples and merge them into single file
## ls *.raw.snvs.bed.i.ToMerge | sort > list.snvs
## Usage: perl snvs.merger.pl list.snvs > output.txt

use strict;
use warnings;
use Getopt::Std;

our ($opt_i, $opt_c, $opt_o);
print "RAW paramters: @ARGV\n";
getopt('ico');
if ( (!defined $opt_i) && (!defined $opt_c) && (!defined $opt_o) ) {
        die ("Usage: $0 \n\t-i [file with all the input files] \n\t-c [last column ] \n\t-o [output file]\n");
}
else    {
	my $source = $opt_i;
	my $last_col = $opt_c;chomp $last_col;
	my $dest = $opt_o;
	open OUT, ">$dest" or die "can not open $dest : $! \n";
	print OUT "\t\t\t\t\t";
	open LIST, "<$source" or die "can not open $source : $! \n";
	while (my $file=<LIST>)	{
		chomp $file;
		my @filename = split (/\//,$file);
		my @sample = split (/\./,$filename[$#filename]);
		print OUT "$sample[0]\t\t\t\t\t";
	}
	close LIST;
	print OUT "\n";
	print OUT "Chr\tStart\tInCaptureKit\tRef\tAlt\t"; ## Output format
	my %snv;
	my $i = 0; ## Track of which sample the call comes from; to make sure newer indel calls get adequate tabs
	open LIST, "<$source" or die "can not open $source : $! \n"; ## List of file-names to merge...
	foreach my $f (<LIST>)	{
		chomp $f;
	    print OUT "GenotypeClass\tAlt-SupportedReads\tRef-SupportedReads\tReadDepth\t${last_col}\t"; ## Output format
		my $list = '';
    	foreach my $k (keys %snv)	{
			$list .= " $k ";
    	}
		## Keep track of all positions called for this sample
		my $positions; 
    	open (F, $f);
    	while (my $l = <F>) {
			chomp $l;
			my @a = split (/\t/,$l);
			## Make a combination of columns to make a unique key
			## Chr_pos_ref_alt_InCaptureKit
			my $uniq = $a[0]."_".$a[1]."_".$a[9]."_".$a[2]."_".$a[3];
			if ($list =~ / $uniq /)	{
				$snv{$uniq} .= "$a[4]\t$a[5]\t$a[6]\t$a[7]\t$a[8]\t";		
			}
			else	{
				$snv{$uniq} = "$a[0]\t$a[1]\t$a[9]\t$a[2]\t$a[3]\t";  ## Common chr pos ref alt in capture kit	
			    for (my $j=0; $j<$i; $j++)	{
					$snv{$uniq}.="n/a\tn/a\tn/a\tn/a\tn/a\t";
				}
				$snv{$uniq}.= "$a[4]\t$a[5]\t$a[6]\t$a[7]\t$a[8]\t";
			}
			$positions .= " $uniq "; ## List of all positions called for this sample
    	}
   	 	close F;
		foreach my $k (sort keys %snv)	{
			## This sample does not contain this snv call; print all samples
			if ($positions !~ / $k /)	{
				$snv{$k} .="n/a\tn/a\tn/a\tn/a\tn/a\t"; 		
			}
		}
   	 	$i++;
	}
	close LIST;
	print OUT "\n"; ## Header line
	foreach my $k (sort keys %snv)	{
	    print OUT "$snv{$k}\n";
	}
	undef %snv;
	exit;	
}
