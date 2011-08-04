## Perl script to append SeattleSeq results to the List.report results from MAQ
## 10/03/2010 : replace blank columns by underscore

use strict;
use Getopt::Std;

our ($opt_i, $opt_s, $opt_c, $opt_p, $opt_r ,$opt_a, $opt_o);
print "INFO: script to add sseq results to the variant report\n";
print "RAW paramters: @ARGV\n";
getopt('iscprao');
if ( (!defined $opt_i) && (!defined $opt_s) && (!defined $opt_c) && (!defined $opt_p) && (!defined $opt_r) && (!defined $opt_a) && (!defined $opt_o) ) {
	die ("Usage: $0 \n\t-i [variant file] \n\t-s [sseq] \n\t-c [chr column] \n\t-p [position col] \n\t-r [ref position] \n\t-a [alt position] \n\t-o [output file] \n");
}
else    {
	my $source = $opt_i;
	my $sseq = $opt_s;
	my $chr = $opt_c;$chr=$chr-1;
	my $pos = $opt_p;$pos=$pos-1;
	my $ref = $opt_r;$ref=$ref-1;
	my $alt = $opt_a;$alt=$alt-1;
	my $dest = $opt_o;
	my %hashreport=();
	my %hashsseq=();
	my $num_columns_sift;
	my $len =0;
	#Form a unique key with chr_pos from merged list.report
	open REPORT, "<$source" or die " can not open $source : $! \n";
	open OUT, ">$dest" or die "can not open $dest :$! \n";
	my $len_header=0;
	while(my $line = <REPORT>)	{
		if ($. == 1)	{
			chomp $line;
			print OUT "$line"; 
			print OUT "\t"x20 ;
			print OUT "SeattleSeq Annotation\n";
		}	
		elsif($. == 2)	{
			chomp $line;
			print OUT "$line";
			my @header=split(/\t/,$line);
			$num_columns_sift = scalar(@header);
			my $left = $num_columns_sift - 5;
		}	
		else	{
			chomp $line;
			my @array = split(/\t/,$line);
			for (my $i = 0 ;$i < $num_columns_sift; $i++)	{ 
				$len = length($array[$i]);
				if($len == 0)	{
					$array[$i] = '-';	
				}	
			}
			my $uniq = $array[$chr]."_".$array[$pos]."_".$array[$ref]."_".$array[$alt];
			push( @{$hashreport{$uniq}},join("\t",@array) );
		}
	}	
	close REPORT;

	#Form a unique key with chr_pos from seattle seq, push the duplicates per key into array
	open SSEQ, "<$sseq" or die " can not open $sseq :$! \n";
	while(my $line = <SSEQ>)	{
		next if($line =~ /^# number|^# geneDataSource |^# HapMapFreqType/);
		if($. == 1)	{
			chomp $line;
			print OUT "\t$line\n";
		}
		else	{
			chomp $line;
			my @array = split('\t',$line);
			# make a unique id using chr and position as a set
			my $uniq = "chr".$array[1]."_".$array[2]."_".$array[3]."_".$array[4];
			push( @{$hashsseq{$uniq}},join("\t",@array));
		}
	}
	close SSEQ;

	#Loop over unique key from %hashreport and compare with %hashsseq;
	
	foreach my $find (sort keys %hashreport)	{
		if(defined $hashsseq{$find} )	{
			my $count = scalar(@{$hashsseq{$find}});
			my $count_report= scalar(@{$hashreport{$find}});
				for(my $j = 0; $j <= $count_report-1; $j++)	{
					print OUT "${$hashreport{$find}}[$j]";
					print OUT "\t${$hashsseq{$find}}[0]\n";
					if($count > 1)	{
						for(my $i = 1; $i <= $count-1; $i++)	{
							print OUT "\t"x$num_columns_sift;
							print OUT "${$hashsseq{$find}}[$i]\n";
						}	
					}
				}							
		}
	}
	undef %hashreport;
	undef %hashsseq;
}
	

