#! /usr/bin/perl
################################################################################
# add_entrezID.pl
#	author: Ying Li
#	the script will look for "geneList" column which should contain gene symbols
#	inputs: 
#		1. a file containing gene symbol. 
#		2. file containing entrezID mapping to gene name, synonyms and gene description
#			this file can be updated using the following command on updated gene_info.gz
#			% wget ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz
#			% gunzip -c gene_info.gz |grep '^9606'|cut -f2-3,5,9 > ../human_gene_id_name_desc.txt 
#	output:
#		files with entrez_ID and gene description columns added
################################################################################
use strict;
#use warnings;
use Getopt::Std;

our ($opt_i, $opt_m, $opt_o);
print "Raw parameters: @ARGV\n";
getopt('imo');

unless ( (defined $opt_i) && (defined $opt_m) && (defined $opt_o) ){
	die ("Usage: $0 [-i tab-delimited input file containing gene symbol] [-m gene symbol and entrezID mapping file] [-o output file]\n");
}

my $infile = $opt_i;
my $mapfile = $opt_m;
my $gene_col;
my $outfile = $opt_o;


my %gene_name_hash;
my %alt_name_hash;
my $line = '';

`dos2unix $infile`;
open MAP, "<$mapfile" or die "can not open file $mapfile: $!\n";
my $line1 = <MAP>;
while ( $line1 = <MAP> ) {
	chomp $line1;
	my ($gene_id,$gene_name,$gene_synonym,$gene_desc) = split (/[\t]/, $line1);
	$gene_name_hash{$gene_name}{'gene_id'} = $gene_id;
	$gene_name_hash{$gene_name}{'gene_desc'} = $gene_desc;
#	print "debug: $gene_id, $gene_name,$gene_synonym,$gene_desc\n";

	my @syn = split (/\|/,$gene_synonym);
	for my $gene_syn (@syn){
		$alt_name_hash{$gene_syn}{'gene_id'} = $gene_id;
		$alt_name_hash{$gene_name}{'gene_desc'} = $gene_desc;
	}	
}
close MAP;


open IN, "<$infile" or die "can not open file $infile: $!\n";
open OUT, ">$outfile" or die "can not open file $outfile: $!\n";

my $header1 = <IN>;
#chomp $header;
my $header2 = <IN>;
my $header =$header1.$header2;
my @header_array = split (/\t/,$header2);
my $header_len = @header_array;
for (my $i=0; $i<$header_len; $i++){
	if ($header_array[$i] =~ /geneList/){
		$gene_col = $i;
		print "gene col: $gene_col\n";
	}
}

chomp $header;
$header .= "\tEntrez_id\tGene_title";
#print "$header\n";
print OUT "$header\n";
my $line_c = 1;

while ( my $line = <IN> ) {
	chomp $line;
	my @cols = split (/\t/, $line);
	my $gene_name = $cols[$gene_col];
	my @gene_list = split(/,/,$gene_name);
	my $string = $line."\t";
	my $entrez_id;
	my $gene_description='';
	my $flag = 0;
	for my $gene (@gene_list){
#		print "gene if more than 1: $gene\n";
		if ( exists $gene_name_hash{$gene}{'gene_id'} ) {
			$entrez_id = $gene_name_hash{$gene}{'gene_id'};
			$gene_description = $gene_name_hash{$gene}{'gene_desc'};
			if($gene_description eq ''){
				$gene_description = "-";
			}
			last;
		}
		elsif( exists $alt_name_hash{$gene}{'gene_id'} ) {
			$entrez_id = $alt_name_hash{$gene}{'gene_id'};
			$gene_description = $alt_name_hash{$gene}{'gene_desc'};
			if($gene_description eq '' ){
				$gene_description = "-";
			}
			last;
		}
		else {
			$entrez_id = "-";
			$gene_description = "-";
		}
#		print "entrez id: $entrez_id, gene: $gene\n";
	}	$string .= "$entrez_id\t$gene_description";
	print OUT "$string\n";
	$line_c++
}
close IN;
close OUT;



