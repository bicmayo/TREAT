
#script to add rsIDs to the 4th column of the SNV report

use strict;
use warnings;
use Getopt::Std;

our ($opt_i, $opt_r, $opt_o, $opt_v);
print "INFO: script to extract rsids and arranging the columns\n";
print "RAW paramters: @ARGV\n";
getopt('irov');
if ( (!defined $opt_i) && (!defined $opt_r) && (!defined $opt_o) && (!defined $opt_v) ) {
        die ("Usage: $0 \n\t-i [nput file] \n\t-r [raw file] \n\t-o [utput file] \n\t-v [variant type] \n");
}
else    {

	my $source = $opt_i;
	my $raw = $opt_r;
	my $dest = $opt_o;
	my $variant = $opt_v;

	open FH, "<$source" or die "can not open $source :$! \n";
	open RAW, "<$raw" or die "can not open $raw :$! \n";
	open OUT, ">$dest" or die " can not open $dest : $!\n";

	my @b;
	my $i=0;
	while(my $l = <RAW>)	{		## rsids file
		chomp $l;
		my @a=split(/\t/,$l);
		$b[$i]="$a[-3]\t$a[-2]\t$a[$#a]";	
		$i++;
	}
	close RAW;
	my $size=0;
	while(my $k=<FH>)	{		##	report file	
		if($. == 2)	{
			chomp $k;
			my @c = split(/\t/,$k);
			$size = scalar(@c);
			last;
		}
	}
	close FH;
	open FH, "<$source" or die "can not open $source :$! \n";
	while(my $m = <FH>)	{
		chomp $m;
		if ($. == 1)	{
			print OUT "\t\t\t$m\n";
		}
		else	{
			my @qw = split(/\t/,$m);
			my @columns; 
			my $pos= $. -2;
			if($variant eq 'SNV')	{
				@columns=(2..$size-1);
				print OUT "$qw[0]\t$qw[1]\t$b[$pos]\t";
			}
			elsif($variant eq 'INDEL')	{
				@columns=(3..$size-1);
				print OUT "$qw[0]\t$qw[1]\t$qw[2]\t$b[$pos]\t";
			}
			print OUT join("\t",@qw[@columns]);
			print OUT "\n";
		}
	}	
	close FH;
	close OUT;
}	
