use strict;
use warnings;

my $infile ="$ARGV[0]";
my $dbsnp_file = "$ARGV[2]";
$dbsnp_file =~ m/b(\d+)\_/;
my $dbsnp_v = $1;
my $chr_col = "$ARGV[3]";
my $pos_col = "$ARGV[4]";
my $base1 = "$ARGV[1]";
my $outfile = "$ARGV[5]";

my %rsid_hash;
my $line = '';

open SNP, "<$dbsnp_file" or die "can not open file $dbsnp_file: $!\n";
my $line1 = <SNP>;
while ( $line1 = <SNP> ) {
	chomp $line1;
	my ($rsid,$chr,$pos,$strand) = split (/[ \t]+/, $line1);
	my $rsid_n = 'rs'.$rsid;
	$rsid_hash{$chr}{$pos}{'rsid'} = $rsid_n;
}
close SNP;


open IN, "<$infile" or die "can not open file $infile: $!\n";
open OUT, ">$outfile" or die "can not open file $outfile: $!\n";

#my $header .= <IN>;
#chomp $header;
#$header .= "\tdbSNP".$dbsnp_v;
#print OUT "$header\n";

while ( $line = <IN> ) {
	chomp $line;
	my $flag = 0;
	my @cols = split (/[ \t]+/, $line);
	my $chr = $cols[$chr_col-1];
	$chr =~ s/chr//gi;
	my $pos = $cols[$pos_col-1];
	my $string = $line."\t";
	my $pos_0b;
	if ($base1 == 1){
		$pos_0b = $pos-1;
	}
	elsif ($base1 == 0) {
		$pos_0b = $pos;
	}
	else{
		print "value should be either 1 or 0";
	}

#	print "chr,0base: $chr, $pos_0b\n";
	if (exists $rsid_hash{$chr}{$pos_0b} ) {
		my $rsid = $rsid_hash{$chr}{$pos_0b}{'rsid'};
		$string .= "$rsid";
#		print "****** $rsid ******\n";
		$flag = 1;
	}
	else {
		$string .= "-";
	}
	print OUT "$string\n";
}
close IN;
close OUT;
undef %rsid_hash;


