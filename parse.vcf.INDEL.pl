	
	## parse VCF to create old GATK format file
	##06/13/2011
	## baheti.saurabh@mayo.edu
	## GTAK updated the format of the VCF so needs and update to parsing script
	#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  sampleA
	#chr1    12811188        .       G       GC      252.31  .       AC=2;AF=1.00;AN=2;Dels=0.00;HRun=3;HaplotypeScore=0.0000;MQ=43.31;MQ0=0;QD=31.54;SB=-83.88
	#     GT:AD:DP:GQ:PL  1/1:1,7:8:21.07:294,21,0
	use strict;
	use warnings;
	use Getopt::Std;

	our($opt_i, $opt_o, $opt_s);
	print "INFO: script to parse the VCF indel to output old GATK format\n";
	print "RAW paramters: @ARGV\n";
	getopt('ios');
	if ( (!defined $opt_i) && (!defined $opt_o) && (!defined $opt_s) )	{
		die ("Usage: $0 \n\t-i [nput vcf file] \n\t-o [utput gatk format] \n\t-s[ample name] \n");
	}		
	else	{
		my $source=$opt_i;
		my $output=$opt_o;
		my $sample=$opt_s;chomp $sample;
		open FH, "<$source" or die "can not open $source :$! \n";
		open OUT, ">$output" or die "can not open $output : $! \n";		
	#	print "Chr\tStart\tStop\tInformation\n";
		my ($header_len,$sample_col,$format_col,$chr,$ReadDepth,$GenoType,$AllelicDepth,$format_len);
		my (@alt_reads,@format_data,@sample_data);
		while( my $l = <FH>)	{
			chomp $l;
			next if ( $l =~ /^##/ );   ## skipping header of the VCF format
			my @call = split(/\t/,$l);
			if( $l =~ /^#/)	{		## reading the header to get header information
				$header_len=scalar(@call);
				for( my $i = 0; $i < $header_len ; $i++ )	{	## to get the position of sample specific data	
					if($call[$i] eq 'FORMAT')	{
						$format_col=$i;
					#	print"FORMAT:$format_col\n";
					}	
					if($call[$i] eq $sample)	{
						$sample_col=$i;
					#	print "SAMPLE:$sample_col\n";
					}	
				}		
				next;	
			}	
			$chr=$call[0];
			@format_data = split(/:/,$call[$format_col]);
			@sample_data = split(/:/,$call[$sample_col]);
			$format_len=scalar(@format_data);
			for( my $i = 0; $i < $format_len ; $i++ )	{			## to get genotype and allelic depth columns
				if($format_data[$i] eq 'GT')	{
					$GenoType = $i;
				}
				if($format_data[$i] eq 'AD')	{
					$AllelicDepth = $i;
				}
			}	
			@alt_reads=split(/,/,$sample_data[$AllelicDepth]);
			if ($sample_data[$GenoType] ne '0/0' )	{
				# to get INS or DEL information and bases
				my $ref_len=length($call[3]);
				my $alt_len=length($call[4]);
				my $INDEL;
				my $Bases;
				my $Start;
				my $Stop;
				if ( $ref_len < $alt_len )	{
					$INDEL = '+';
					$Bases = substr( $call[4],1,$alt_len );
					$Start = $call[1];
					$Stop = $Start;
				}
				else	{
					$INDEL = '-';
					$Bases=substr( $call[3],1,$ref_len );
					$Start = $call[1];
					$Stop = $Start + length($Bases);
				}
				$ReadDepth=$alt_reads[0]+$alt_reads[$#alt_reads];
				print OUT "$chr\t$Start\t$Stop\t$INDEL$Bases:$alt_reads[$#alt_reads]/$ReadDepth\n";
			}
		}
		close FH;
		close OUT;
	}		
## END of script		