	## 	script to parse snvmix result
	## 	Saurabh Baheti
	## 	11/10/2010
	## 	usage: perl $script_path/parse.snvmix.to.snvs.pl <raw snvmix file> > <outputfile>
	## INPUT file looks like
	## chr10:56397	C	T	C:0,T:4,0.0000166367,0.0713358246,0.9286475387,3
	## chr10:64560	T	C	T:0,C:1,0.1111986279,0.2796884109,0.6091129612,3
	## added the uc to ref and alternate allele (capital letters)
	use strict;
	use warnings;
	use Getopt::Std;
	our ($opt_i, $opt_o);
	print "INFO : parse snvmix raw file anf filter using assumption prob >= 0.8 and no reference homozygous calls\n";
	print "RAW paramters: @ARGV\n";
	getopt('io');
	if ( (!defined $opt_i) && (!defined $opt_o) )	{
		die ("Usage: $0 \n\t-i [nput file] \n\t -o [utput file]\n");
	}
	else	{
		my $source=$opt_i;
		my $dest=$opt_o;
		open FH, "<$source" or die "can not open $source :$! \n";
		open OUT, ">$dest" or die "can not open $dest :$! \n";
		#	print "Chr\tPosition\tRef\tAlt\tGenotypeClass\tAlt-SupportedReads\tRef-SupportedReads\tReadDepth\tProbability\n";
		while(my $l = <FH>)	{
			chomp $l;
			my @a = split (/\t/,$l);			#splitting everything
			my @position = split (/:/,$a[0]); 	#splitting first column to get chr and position
			my @prob = split (/,/,$a[$#a]);		#splitting last column so as to get values	
			my @read = split(/:/,$prob[0]);		#splitting the ref call
			my @read1 = split(/:/,$prob[1]);	#splitting the alt call
			my $reads = $read[1]+$read1[1];		#adding total reads ReadDepth
			my $ref = uc($a[1]);				#ref allele capitalized
			my $alt = uc($a[2]);				#alt allele capitalized
			#	Comparing if its homozygous or Heterozygous
			if($prob[$#prob] == 2)	{
				if($prob[3] > 0.8)	{
					my $p3=sprintf("%.2f",$prob[3]);
					print OUT "$position[0]\t$position[1]\t$ref\t$alt\t$ref$alt\t$read1[1]\t$read[1]\t$reads\t$p3\n";
				}
			}
			elsif($prob[$#prob] == 3)	{
				if($prob[4] > 0.8)	{
					my $p4=sprintf("%.2f",$prob[4]);
					print OUT "$position[0]\t$position[1]\t$ref\t$alt\t$alt$alt\t$read1[1]\t$read[1]\t$reads\t$p4\n";
				}
			}
		}
		close FH;
		close OUT;
	}	
## END of script

