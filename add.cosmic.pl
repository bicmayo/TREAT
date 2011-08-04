
# Ying Li, 6/9/2011
use strict;
use warnings;

my %db_hash;
my $coord;
my $strand;
my $col_index;
my $c1 = 0;
my $c2 = 0;
my $c3 = 0;
if (scalar(@ARGV) != 6){
	print "usage: check_cosmic.pl <input file with chr and start pos as 1st and 2nd columns> <input start pos base flag: 1 for 1-based, 0 for 0-based> <COSMIC file with selected columns: mutationID,CDS mutation,protein mutation,coord b36, strand b36, coord b37, strand b37,> <reference genome build for input snv file: hg18 or hg19> <total number of header rows in input file> <output>\n";
}
else{
	my $snv=$ARGV[0];
	my $base_flag = $ARGV[1];
	my $db = $ARGV[2];;

	my $num_header=$ARGV[4];
	my $output=$ARGV[5];
	
	open DB, "<$db" or die "can't open $db\n";
	while (my $line = <DB>){
		chomp $line;
		my ($id,$cds,$prot,$coord18,$strand18,$coord19,$strand19) = split (/\t/,$line);
		if ($ARGV[3] eq 'hg18'){
			$coord = $coord18;
			$strand = $strand19;
		}
		elsif ($ARGV[3] eq 'hg19'){
			$coord = $coord19;
			$strand = $strand19;
		}
		if ( $coord =~ m/(\d+)\:(\d+)\-/){
			my $key = $1.'|'.$2;
			$db_hash{$key}=$id.';'.$cds.';'.$prot.';'.$strand;	
		}
	}

	open IN, "<$snv" or die "can't open $snv\n";
	open OUT, ">$output" or die "can't open $output\n";
	my $header='';
	for (my $i=0; $i<$num_header;$i++){
		$header .= <IN>;
	}
	chomp $header;
	print OUT "$header\tCOSMIC\n" unless ($num_header == 0);
	
	my $pos_1b;
	while (my $line=<IN>){
		$c1++;
		chomp $line;
		my ($chr,$pos,$other)=split("\t",$line);
		if ($base_flag == 0){
				$pos_1b = $pos+1;
		}
		elsif ($base_flag == 1) {
			$pos_1b = $pos;
		}
		else{
				print "value should be either 1 or 0";
	}
		
		my $new_key=$chr.'|'.$pos_1b;
		if ( exists $db_hash{$new_key} ){
			print OUT "$line\t$db_hash{$new_key}";
			$c2++;
		}
		else{
			print OUT "$line\t-";
			$c3++;
		}
		print OUT "\n";
	}
	print "total line count: $c1 \t matched: $c2 \t unmatched: $c3\n";

}
