#! /usr/bin/perl
use warnings;
use strict;
use Getopt::Std;

our ($opt_i, $opt_s, $opt_c, $opt_p, $opt_x, $opt_b, $opt_o, $opt_r);
print "INFO: script to add rsids for indel calls assumptions is that indels are in 1 base coordiate[start is included but stop is excluded]\n ";
print "Raw parameters: @ARGV\n";
getopt('iscpxbor');

unless ( (defined $opt_i) && (defined $opt_s) && (defined $opt_c) && (defined $opt_p) && (defined $opt_x) && (defined $opt_b) && (defined $opt_o) && (defined $opt_r) ){
	die ("Usage: $0 [-i input file containing chr and pos in tab delimited format -full path]  [-b pos base in input file, 1 for 1-based, 0 for 0-based] [-s dbSNP UCSChg##dbSNP### file use chromStart 0-based, current rsids only] [-c column# of chr in the input file] [-p column# of start ] [-x column# of stop] [-o output file path] [-r chromosome ]\n");
}

my $infile = $opt_i;
my $dbsnp_file = $opt_s;
$dbsnp_file =~ m/.+dbSNP(\d+)/;
my $dbsnp_v = $1;
my $chr_col = $opt_c;
my $pos_col = $opt_p;
my $end_col = $opt_x;
my $base1 = $opt_b;
my $outfile = $opt_o;
my $input_chr = $opt_r;

my $comp = "chr".$input_chr;
my %rsid_hash;
my $line = '';

#`flip -u $infile`;
open SNP, "<$dbsnp_file" or die "can not open file $dbsnp_file: $!\n";
#my $line1 = <SNP>;
while ( my $line1 = <SNP> ) {
	chomp $line1;
	my ($bin,$chr,$start,$end,$rsid,$score,$strand,$refNCBI,$refUCSC,$observed,$other) = split (/[\t]+/, $line1);
#	if ($rsid eq 'rs72477211'){
#		print "$chr,$start,$rsid\n";
#	}
	my $value="$rsid\t$observed";
	if ($chr eq $comp){
	$rsid_hash{$chr}{$start}{$end}{'rsid'} = $value; }
 }
close SNP;


open IN, "<$infile" or die "can not open file $infile: $!\n";
open OUT, ">$outfile" or die "can not open file $outfile: $!\n";

my $header .= <IN>;
chomp $header;
$header .= "\tdbSNP".$dbsnp_v."\tdbSNP".$dbsnp_v."Alleles";
print OUT "$header\n";
my @output;

while ( $line = <IN> ) {
	chomp $line;
#	my $flag = 0;
	my @cols = split (/[ \t]+/, $line);
	my $chr = $cols[$chr_col-1];
	my $pos_0b;
	my $end_0b;
#	$chr =~ s/chrM/MT/gi;
#	$chr =~ s/chr//gi;
	my $pos = $cols[$pos_col-1];
	my $end = $cols[$end_col-1];
#	print "chr:$chr, pos:$pos\n";
	if ($base1 == 1){
		$pos_0b = $pos;
		$end_0b = $end;
	}
	elsif ($base1 == 0) {
		$pos_0b = $pos-1;
		$end_0b = $end-1;
	}
	else{
		print "value should be either 1 or 0";
	}

#	print "chr,0base: $chr, $pos_0b\n";
	if (exists $rsid_hash{$chr}{$pos_0b}{$end_0b} ) {
		my $rsid = $rsid_hash{$chr}{$pos_0b}{$end_0b}{'rsid'};
#		$string .= "$rsid";
		print OUT "$line\t$rsid\n";
#		print "****** $rsid ******\n";
#		$flag = 1;
	}
	else {
#		$string .= "-";
		print OUT "$line\t-\t-\n";
	}
#	print OUT "$string\n";
}
close IN;
close OUT;



