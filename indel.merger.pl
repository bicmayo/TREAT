## Saurabh Baheti: 09/16/2010
## Take .indel files from various lanes / samples and merge them into single file
## ls *.indels.raw.bed > list
## Usage: indel.merger.pl list > output.txt

use strict;
use warnings;
use Getopt::Std;

our ($opt_i, $opt_o);
print "RAW paramters: @ARGV\n";
getopt('io');
if ( (!defined $opt_i) && (!defined $opt_o) ) {
        die ("Usage: $0 \n\t-i [file with all the input files] \n\t-o [output file]\n");
}
else    {
	my $source = $opt_i;
	my $dest = $opt_o;
	open OUT, ">$dest" or die "can not open $dest : $! \n";
	print OUT "\t\t\t\t\t\t\t";
	open LIST, "<$source" or die "can not open $source : $! \n";
	while (my $file=<LIST>)	{
		chomp $file;
		my @ac = split (/\//,$file);
		my @ac1 = split (/\./,$ac[$#ac]);
		print OUT "$ac1[0]\t\t";
	}
	close LIST;
	print OUT "\n";
	print OUT "Chr\tStart\tStop\tInCaptureKit\tRef\tAlt\tBase-Length\t"; ## Output format
	my %indel;
	my $i = 0; ## Track of which sample the call comes from; to make sure newer indel calls get adequate tabs
	open LIST, "<$source" or die "can not open $source : $! \n"; ## List of file-names lane1.indel lane2.indel...
	foreach my $f (<LIST>)	{
		chomp $f;
	    print OUT "Indel-supportedRead\tReadDepth\t"; ## Output format
		my $list = '';
    	foreach my $k (keys %indel)	{
			$list .= " $k ";
    	}
		## Keep track of all positions called for this sample
		my $positions; 
    	open (F, $f);
    	while (my $l = <F>) {
			chomp $l;
			my @a = split (/[:\/\s]/,$l);
			$a[7] = substr($a[3],1);
			my $bases=length($a[7]);
			my $reference;
			my $alternate;
			if($a[3] =~ m/(\W)/)	{
				$a[3]=$1;
				if($a[3] eq '+')	{ 
					$reference='-'; $alternate=$a[7];
				}
				else	{	
					$reference=$a[7]; $alternate='-'; 	
				}
			}	
			## Make a combination of columns to make a unique key
			## Chr_start_stop_InCaptureKit_bases_base-length_indel
			my $uniq = $a[0]."_".$a[1]."_".$a[2]."_".$a[6]."_".$reference."_".$alternate."_".$bases;
			if ($list =~ / $uniq /)	{
				$indel{$uniq} .= "$a[4]\t$a[5]\t";		
			}
			else	{
				$indel{$uniq} = "$a[0]\t$a[1]\t$a[2]\t$a[6]\t$reference\t$alternate\t$bases\t";  ## Common chr start stop Bases	
			    for (my $j=0; $j<$i; $j++)	{
					$indel{$uniq}.="n/a\tn/a\t";
	    		}
				$indel{$uniq}.= "$a[4]\t$a[5]\t";
			}
	
			$positions .= " $uniq "; ## List of all positions called for this sample
    		}
   	 	close F;
		foreach my $k (keys %indel)	{
		## This sample does not contain this indel call; print all samples
			if ($positions !~ / $k /)	{
		    	$indel{$k} .="n/a\tn/a\t"; 		
			}
   	 	}
   	 	$i++;
	}
	close LIST;
	print OUT "\n"; ## Header line
	foreach my $k (sort keys %indel)	{
	    print OUT "$indel{$k}\n";
	}
	undef %indel;
	exit;
}
