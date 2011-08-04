#script to comibine all sseq results for indels to get combine over all samples
use strict;
# usage: ls *.snv.*.out > list
#Usage: perl merge.sseq.results.indels.pl <list > <path to sseq reports> > merged.sseq.result.indels.using.script

open(ID,"$ARGV[0]");  # list
#my $filepath="$ARGV[1]";
my $head;
my $sseq_size;
my %sseq=();
while(my $l = <ID>)	{
	chomp $l;
#	open(FILE,"$filepath/$l");
	open(FILE,"$l");
	while(my $m = <FILE>)	{
		chomp $m;
		next if($m =~ /^# number|^# geneDataSource |^# HapMapFreqType | ^# Count /);
		if($. == 1)	{
			$head=$m;
			my @b=split(/\t/,$m);
			$sseq_size = scalar(@b);
		}
		else	{
			my @b=split(/\t/,$m);
			my @c;
			for(my $i = 0; $i < $sseq_size; $i++)	{
				my $len = length($b[$i]);
				if($len == 0)	{
					$b[$i] = '-';
				}
			}	
			my $uniq = $b[1]."_".$b[2]."_".$b[3]."_".$b[4]."_".$b[5]."_".$b[6];
			$sseq{$uniq} = join("\t",@b);
		}
	}	
	close FILE;	
}				
close ID;
print "$head\n";
foreach my $key (keys %sseq)	{
	print "$sseq{$key}\n";
}
undef %sseq;

	
