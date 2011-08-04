#script to comibine all sift results to get combine over all samples
use strict;	
#Usage: perl merge.sift.results.pl <siftid file> <path to sift reports> > merged.sift.result

open(ID,"$ARGV[0]");  # siftids
my $filepath="$ARGV[1]";
my $which_chr="$ARGV[2]";
my $head;
my $sift_size;
my %sift=();
while(my $l = <ID>)	{
	chomp $l;
	my @a = split(/=/,$l);
#	print "$a[0]\n";
	my @chr=split(/\./,$a[0]);
#	print "$chr[$#chr]\n";
#	<STDIN>;
#	print "$chr[$#chr]\n";
	if($chr[$#chr] eq $which_chr )	{
		open(FILE,"$filepath/$a[$#a]/$a[$#a]_predictions.tsv");
		while(my $m = <FILE>)	{
			chomp $m;
			if($. == 1)	{
				$head=$m;
				my @b=split(/\t/,$m);
				$sift_size = scalar(@b);
			}
			else	{
				my @b=split(/\t/,$m);
				my @c;
				for(my $i = 0; $i < $sift_size; $i++)	{
					my $len = length($b[$i]);
					if($len == 0)	{
						$b[$i] = '-';
					}
				}	
				$sift{$b[0]} = join("\t",@b);
			}
		}	
		close FILE;	
	}
}				
close ID;
print "$head\n";
foreach my $key (keys %sift)	{
	print "$sift{$key}\n";
}
undef %sift;

	
