## Use tab-delim file from SIFT predictions with SNP file to
## Combine variant report with SNP annotation

use strict;
use warnings;
use Getopt::Std;

our ($opt_i, $opt_s, $opt_c, $opt_p, $opt_r ,$opt_a, $opt_o);
print "INFO: script to add sift results to the variant report\n";
print "RAW paramters: @ARGV\n";
getopt('iscprao');
if ( (!defined $opt_i) && (!defined $opt_s) && (!defined $opt_c) && (!defined $opt_p) && (!defined $opt_r) && (!defined $opt_a) && (!defined $opt_o) ) {
	die ("Usage: $0 \n\t-i [variant file] \n\t-s [sift] \n\t-c [chr column] \n\t-p [position col] \n\t-r [ref position] \n\t-a [alt position] \n\t-o [output file] \n");
}
else    {
	my $source = $opt_i;
	my $sift = $opt_s;
	my $chr = $opt_c;$chr=$chr-1;
	my $pos = $opt_p;$pos=$pos-1;
	my $ref = $opt_r;$ref=$ref-1;
	my $alt = $opt_a;$alt=$alt-1;
	my $dest = $opt_o;
	my %sift;
	open FH, "<$sift" or die "can not open the $sift : $! \n";  ## SIFT TSV predictions
	open OUT, ">$dest" or die " can not open the $dest : $! \n";
	my $l = <FH>; # header
	chomp $l; my $hdr = "$l";
	my @head=split(/\t/,$hdr);
	my $len_sift_header=scalar(@head);
	$len_sift_header=$len_sift_header-1;
	while ($l = <FH>) {
		chomp $l;
		my @a = split('\t', $l);
		my @c = split('\,', $a[0]);
		my @d = split('\/', $c[3]);
		$c[0] ="chr".$c[0];
		$sift{$c[0]}{$c[1]}{$d[0]}{$d[1]} = $l;
	}
	close FH;
	open SOURCE, "<$source" or die "can not open the $source : $! \n"; ## Variant file
	my $d = <SOURCE>;
	chomp $d; my $hdr1 = "$d";
	print OUT "$hdr1\t\t\t\t\tSIFT Annotation\n";
	while ($l = <SOURCE>) {
		chomp $l;
		if($.== 2)	{
			print OUT "$l\t$hdr\n";
		}
		else	{	
			my @a = split(/\t/, $l);
			if (defined $sift{$a[$chr]}{$a[$pos]}{$a[$ref]}{$a[$alt]}) {
				print OUT "$l\t$sift{$a[$chr]}{$a[$pos]}{$a[$ref]}{$a[$alt]}\n";
			} 
			else { 	
				print OUT "$l\t";
				print OUT "-\t"x$len_sift_header;
				print OUT "\n";
			}
		}
	}
	close SOURCE;
	close OUT;
}
## end of script
