#! /usr/bin/perl
use warnings;
#use strict;
use Getopt::Std;

our ($opt_i, $opt_c, $opt_p, $opt_b, $opt_e, $opt_g, $opt_s, $opt_o, $opt_r);
print "Raw parameters: @ARGV\n";
getopt('igscpbeor');

unless ( (defined $opt_i) && (defined $opt_s) && (defined $opt_c) && (defined $opt_p) && (defined $opt_b) && (defined $opt_o) && (defined $opt_r) ){
	die ("Usage: $0 [-i input file containing chr and pos in tab delimited format -full path][-c column# of chr in the input file] [-p column# of pos ] [-b pos base, 1 for 1-based, 0 for 0-based] [-e population, CEU, YRI or JPT+CHB] [-s hapmap file (0-based) including all chr] [-g 1000genome file (0-based) -full path] [-o output file path] [ -r chromomsome]\n");
}

my $infile = $opt_i;
my $hapmap_file = $opt_s;
my $kgenome = $opt_g;
my $population = $opt_e;
my $chr_col = $opt_c;
my $pos_col = $opt_p;
my $base1 = $opt_b;
my $outfile = $opt_o;
my $input_chr=$opt_r;

my %hapmap_hash;
my %kgenome_hash;
my %hapmap_ref;
my %kgenome_ref;


####################################################
# parse HapMap file and store info in a hash
####################################################

#`gunzip $kgenome.gz`;
`dos2unix $infile`;
open SNP, "<$hapmap_file" or die "can not open file $hapmap_file: $!\n";
my $line = <SNP>;
while ( $line = <SNP> ) {
	chomp $line;
	my ($rsid,$chr,$pos,$ref_allele,$ref_af,$other_allele,$other_af ) = split (/[ \t]+/, $line);
	$chr =~ s/chr//gi;
	if($chr eq $input_chr)	{
	$hapmap_hash{$chr}{$pos}{$ref_allele} = $ref_af;
	$hapmap_hash{$chr}{$pos}{$other_allele} = $other_af;

	#check if reference is consistent
	$hapmap_ref{$chr}{$pos}{'ref_allele'} = $ref_allele;
	$hapmap_ref{$chr}{$pos}{'rsid'} = $rsid;
	}
}
close SNP;

####################################################
# parse 1KGenome file and store info in a hash
####################################################

open SNP, "<$kgenome" or die "can not open file $kgenome: $!\n";
my $line1 = <SNP>;
while ( $line = <SNP> ) {
	chomp $line;
	my ($rsid,$chr,$pos,$ref_allele,$ref_af,$other_allele,$other_af ) = split (/[ \t]+/, $line);
	$chr =~ s/chr//gi;
	if($chr eq $input_chr)	{
	$kgenome_hash{$chr}{$pos}{$ref_allele} = $ref_af;
	$kgenome_hash{$chr}{$pos}{$other_allele} = $other_af;

	#check if reference is consistent
	$kgenome_ref{$chr}{$pos}{'ref_allele'} = $ref_allele;
	$kgenome_ref{$chr}{$pos}{'rsid'} = $rsid;
	}
}
close SNP;


open IN, "<$infile" or die "can not open file $infile: $!\n";
open OUT, ">$outfile" or die "can not open file $outfile: $!\n";
#open REF, ">inconsistent_ref.txt" or die "can not open file $outfile: $!\n";

my $header .= <IN>;
chomp $header;
$header .= "\tHapMap_".$population."_allele_freq\t1kgenome_".$population."_allele_freq";
print OUT "$header\n";
#print REF "chr\tpos\trsid\tdefault_ref\thapmap_ref\t1kgenome_ref\n";

while ( $line = <IN> ) {
	chomp $line;
	my @cols = split (/[ \t]+/, $line);
	my $chr = $cols[$chr_col-1];
	$chr =~ s/chr//gi;
	my $pos = $cols[$pos_col-1];
	my $string = "$line\t";
	if ($base1 == 1){
		$pos_1b = $pos;
	}
	elsif ($base1 == 0) {
		$pos_1b = $pos+1;
	}
	else{
		print "value should be either 1 or 0";
	}

	# get reference
	my $rsid_b130 = $cols[2];
#	print "$rsid_b130\n";
#	<STDIN>;
	my $ref = $cols[3];
#	print "default ref: $ref\n";

	#print REF "$chr\t$pos\t$rsid_b130\t$ref\t";
	
	# add hapmap allele frequency column
	if (exists $hapmap_hash{$chr}{$pos_1b} ) {
		my ($k,$af);
		for my $al (sort {${$hapmap_hash{$chr}{$pos_1b}}{$a} cmp ${$hapmap_hash{$chr}{$pos_1b}}{$b} } keys %{$hapmap_hash{$chr}{$pos_1b}}) {
			$k .= $al."/";
			$af .= $hapmap_hash{$chr}{$pos_1b}{$al}."/";
#			print "output hapmap: $chr,$pos,$al:$af\n";
		}
		$k =~ s|/$||;
		$af =~ s|/$||;
		$string .= "$k,$af\t";

		#check ref allele consistency
#		print REF "$hapmap_ref{$chr}{$pos}{'rsid'}\t";
#		if ($ref eq $hapmap_ref{$chr}{$pos}{'ref_allele'} ){
#			print REF "-\t";
#		}
#		else{
#			print REF "$hapmap_ref{$chr}{$pos}{'ref_allele'}\t";	
#		}
	}
	else {
		$string .= "-\t";
	}
	
	# add 1000genome allele frequency column
	if (exists $kgenome_hash{$chr}{$pos_1b} ) {			# need sort by value
		# display by allele1/allele2,af1/af2
		my ($k,$af);
		for my $al (sort {${$kgenome_hash{$chr}{$pos_1b}}{$a} cmp ${$kgenome_hash{$chr}{$pos_1b}}{$b} } keys %{$kgenome_hash{$chr}{$pos_1b}}) {
			$k .= $al."/";
			$af .= $kgenome_hash{$chr}{$pos_1b}{$al}."/";
#			print "output 1kgenome:$chr,$pos,$al:$af\n";
		}
		$k =~ s|/$||;
		$af =~ s|/$||;
		$string .= "$k,$af";
		$string =~ s/\;$//;

		#check ref allele consistency
#		print REF "$kgenome_ref{$chr}{$pos}{'id'}\t"; 
#		if ($ref eq $kgenome_ref{$chr}{$pos}{'ref_allele'} ){
#			print REF "-";
#		}
#		else{
#			print REF "$kgenome_ref{$chr}{$pos}{'ref_allele'}";	
#		}
	}
	else {
		$string .= "-";
	}	
#	print REF "\n";
	
	print OUT "$string\n";
}
close IN;
close OUT;
#close REF;
undef %hapmap_hash;
undef %kgenome_hash;
undef %hapmap_ref;
undef %kgenome_ref;
#`gzip $kgenome`;
