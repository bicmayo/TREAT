## scrip to add BGI frequencies to the SNV data
use strict;
use warnings;
use Getopt::Std;

our ($opt_i,$opt_r,$opt_c,$opt_o);
print "script to add BGI frequencies to the variant report\n";
print "RAW paramters: @ARGV\n";
getopt('irco');
if ( (!defined $opt_i) && (!defined $opt_r) && (!defined $opt_c) && (!defined $opt_o) )	{
	die ("Usage: $0 \n\t-i [ input snv file with chr and pos as 1st and 2nd columns ] \n\t-r [ BGI reference ] \n\t-c [ chromosome] \n\t-o [ output file ] \n");
}
else	{
	my $snv = $opt_i;
	my $bgi = $opt_r;
	my $chr = $opt_c;
	my $comp = "chr".$chr;
	my $output = $opt_o;
	my %bgi_hash;
	my %index;
	$index{0}='A';
	$index{1}='C';
	$index{2}='G';
	$index{3}='T';
	##open the refenence fileopen 
	open BGI, "<$bgi" or die "can't open $bgi : $! \n";
	while (my $line = <BGI>){
		chomp $line;
		my ($chr,$pos,$index_major,$index_minor,$numA,$numC,$numG,$numT,$est_maf) = split (/\t/,$line);
		if ($chr eq $comp)	{
			my $key = $chr.'|'.$pos;
			my $major_af=1-$est_maf;
			$est_maf=sprintf("%0.3f",$est_maf);
			$major_af=sprintf("%0.3f",$major_af);
			$bgi_hash{$key}=$index{$index_minor}.'/'.$index{$index_major}.','.$est_maf.'/'.$major_af;	
		}	
	}
	## open the input and the output file
	open IN, "<$snv" or die "can't open $snv : $! \n";
	open OUT, ">$output" or die "can't open $output : $! \n";
	my $header .= <IN>;
	chomp $header;
	$header .= "\tBGI200_Danish";
	print OUT "$header\n";
	while (my $line=<IN>){
		chomp $line;
		my ($chr,$pos,$other)=split("\t",$line);
		my $new_key=$chr.'|'.$pos;
		if ( exists $bgi_hash{$new_key} ){
			print OUT "$line\t$bgi_hash{$new_key}";
		}
		else{
			print OUT "$line\t-";
		}
		print OUT "\n";
	}
	close IN;
	close OUT;	
}
