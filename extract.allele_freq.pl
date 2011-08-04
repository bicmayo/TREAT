use strict;
use warnings;
use Getopt::Std;

our ($opt_i, $opt_f, $opt_o, $opt_v);
print "INFO: script to extract frequneceis and arranging the columns\n";
print "RAW paramters: @ARGV\n";
getopt('ifov');
if ( (!defined $opt_i) && (!defined $opt_f) && (!defined $opt_o) && (!defined $opt_v) ) {
        die ("Usage: $0 \n\t-i [nput file] \n\t-f [raw file] \n\t-o [utput file] \n\t-v [ariant_type] \n");
}
else    {
	my $source = $opt_i;
	my $raw = $opt_f;
	my $dest = $opt_o;
	my $variant = $opt_v;
	open FH, "<$source" or die "can not open $source :$! \n";
	open RAW, "<$raw" or die "can not open $raw :$! \n";
	open OUT, ">$dest" or die " can not open $dest : $!\n";
	my @data;
	my $i =0;
	while (my $l = <RAW>)	{
		chomp $l;
		my @a = split(/\t/,$l);
		$data[$i]= join("\t",@a);
		$i++;
	}
	my $size=0;
	if($variant eq 'SNV')	{
		print OUT "\t\t\t\t\tAllele Frequency\t\t\t";
	}
	elsif ($variant eq 'INDEL')	{
	#	print OUT "\t\t\t\tAllele Frequency";
	}
	while (my $m = <FH>)	{
		if ($. == 1)	{
			chomp $m;
			print OUT "$m\n";
		}
		elsif($. == 2)	{
			chomp $m;
			my @b=split('\s',$m);
			$size=scalar(@b);
			last;
		}
	}
	close FH;
	open FH, "<$source" or die "can not open $source :$! \n";
	while(my $q = <FH>)	{
		chomp $q;
		next unless ( $. > 1);
		my @qw = split(/\t/,$q);
		my $pos= $. -2;
		my @columns;
		if($variant eq 'SNV')	{
			@columns=(5..$size-1);
			print OUT "$data[$pos]\t";
		}
		if($variant eq 'INDEL')	{
			@columns=(6..$size-1);
			print OUT "$data[$pos]\t";
		}
		print OUT join("\t",@qw[@columns]);
		print OUT "\n";			
	}
	close OUT;
	close FH;
}
## end of the script	

		

