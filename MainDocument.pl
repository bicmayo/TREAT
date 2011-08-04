## contact :Saurabh Baheti 
## Script to make a html report for analysis

use strict;
#use warnings;
use Getopt::Std;
our ($opt_r,$opt_p);
print "RAW paramters: @ARGV\n";
getopt('rp');
if ( (!defined $opt_r) && (!defined $opt_p) ) {
        die ("Usage: $0 \n\t-r [ un info file ] \n\t-p [ ath output folder ] \n");
}
else    {
	my ($run_info) = $opt_r;chomp $run_info;
	my ($path) = $opt_p;chomp $path;
	my $desc = $path."/StatiticsDesciption.html";
	open DESC, ">$desc" or die "can not open $desc : $!\n";
	my @line=split(/=/,`perl -ne "/^DISEASE/ && print" $run_info`);
	my $disease=$line[$#line];chomp $disease;
	@line=split(/=/,`perl -ne "/^DATE/ && print" $run_info`);
	my $date=$line[$#line];chomp $date;
	@line=split(/=/,`perl -ne "/^SAMPLENAMES/ && print" $run_info`);
	my $sampleNames=$line[$#line];chomp $sampleNames;
	my @sampleArray = split(/:/,$sampleNames);
	@line=split(/=/,`perl -ne "/^LANEINDEX/ && print" $run_info`);
	my $laneNumbers=$line[$#line];chomp $laneNumbers;
	my @laneArray = split(/:/,$laneNumbers);
	@line=split(/=/,`perl -ne "/^PAIRED/ && print" $run_info`);
	my $paired=$line[$#line];chomp $paired;
	@line=split(/=/,`perl -ne "/^GENOMEBUILD/ && print" $run_info`);
	my $GenomeBuild=$line[$#line];chomp $GenomeBuild;
	@line=split(/=/,`perl -ne "/^TYPE/ && print" $run_info`);
	my $tool=$line[$#line];chomp $tool;
	@line=split(/=/,`perl -ne "/^ANALYSIS/ && print" $run_info`);
	my $analysis=$line[$#line];chomp $analysis;
	@line=split(/=/,`perl -ne "/^SAMPLEINFORMATION/ && print" $run_info`);
	my $sampleinfo=$line[$#line];chomp $sampleinfo;
	@line=split(/=/,`perl -ne "/^OUTPUT_FOLDER/ && print" $run_info`);
	my $run_num=$line[$#line];chomp $run_num;
	@line=split(/=/,`perl -ne "/^TOOL_INFO/ && print" $run_info`);
	my $tool_info=$line[$#line];chomp $tool_info;
	@line=split(/=/,`perl -ne "/^dbSNP_SNV_rsIDs/ && print" $tool_info`);
	my $dbsnp_file=$line[$#line];chomp $dbsnp_file;
	$dbsnp_file =~ m/.+dbSNP(\d+)/;
	my $dbsnp_v = $1;
	@line=split(/=/,`perl -ne "/^TREAT_PATH/ && print" $tool_info`);
	my $script_path=$line[$#line];chomp $script_path;
	my ($read_length, $variant_type, $target_region, $SNV_caller, $Aligner, $ontarget, $fastqc, $fastqc_path, $server, $upload_tb );
	@line=split(/=/,`perl -ne "/^UPLOAD_TABLEBROWSER/ && print" $run_info`);
	my $upload_tb=$line[$#line];chomp $upload_tb;
	@line=split(/=/,`perl -ne "/^TABLEBROWSER_PORT/ && print" $run_info`);
	my $port=$line[$#line];chomp $port;
	@line=split(/=/,`perl -ne "/^TABLEBROWSER_HOST/ && print" $run_info`);
	my $host=$line[$#line];chomp $host;
	
	if ($analysis eq 'alignment' )	{
		@line=split(/=/,`perl -ne "/^READLENGTH/ && print" $run_info`);
		$read_length=$line[$#line];chomp $read_length;
		@line=split(/=/,`perl -ne "/^ALIGNER/ && print" $run_info`);
		$Aligner=$line[$#line];chomp $Aligner;
		@line=split(/=/,`perl -ne "/^FASTQC/ && print" $run_info`);
		$fastqc=$line[$#line];chomp $fastqc;
		@line=split(/=/,`perl -ne "/^HTTP_SERVER/ && print" $tool_info`);
		$server=$line[$#line];chomp $server;	
	}	
	if ( ( $analysis eq 'all' ) || ( $analysis eq 'variant' ) || ($analysis eq 'mayo') )	{
		@line=split(/=/,`perl -ne "/^READLENGTH/ && print" $run_info`);
		$read_length=$line[$#line];chomp $read_length;
		@line=split(/=/,`perl -ne "/^ALIGNER/ && print" $run_info`);
		$Aligner=$line[$#line];chomp $Aligner;
		@line=split(/=/,`perl -ne "/^VARIANT_TYPE/ && print" $run_info`);
		$variant_type=$line[$#line];chomp $variant_type;
		@line=split(/=/,`perl -ne "/^SNV_CALLER/ && print" $run_info`);
		$SNV_caller=$line[$#line];chomp $SNV_caller;
		@line=split(/=/,`perl -ne "/^CAPTUREKIT/ && print" $tool_info`);
		$ontarget=$line[$#line];chomp $ontarget;
		$target_region=`awk '{sum+=\$3-\$2+1; print sum}' $ontarget | tail -1`;chomp $target_region;
		@line=split(/=/,`perl -ne "/^FASTQC/ && print" $run_info`);
		$fastqc=$line[$#line];chomp $fastqc;
		@line=split(/=/,`perl -ne "/^HTTP_SERVER/ && print" $tool_info`);
		$server=$line[$#line];chomp $server;	
	}
	elsif ( $analysis eq 'annotation' )	{
		@line=split(/=/,`perl -ne "/^VARIANT_TYPE/ && print" $run_info`);
		$variant_type=$line[$#line];chomp $variant_type;
		@line=split(/=/,`perl -ne "/^SNV_CALLER/ && print" $run_info`);
		$SNV_caller=$line[$#line];chomp $SNV_caller;
	}	
	print "Run : $run_num \n";
	print "Result Folder : $path \n";
	my $numbers=$path."/numbers";
	print "Disease: $disease\n";
	print "Date: $date\n";
	print "Samples: $sampleNames\n";
	print "lanes: $laneNumbers\n";
	print "Region: $target_region\n";
	print "PairedEnd: $paired\n";
	print "Type of Tool: $tool\n";
	print "ReadLength: $read_length\n";
	print "AnalysisType: $analysis\n";
	print "TargetRegion: $target_region\n";
	sub CommaFormatted
	{
		my $delimiter = ','; # replace comma if desired
		my($n,$d) = split /\./,shift,2;
		my @a = ();
		while($n =~ /\d\d\d\d/)
		{
			$n =~ s/(\d\d\d)$//;
			unshift @a,$1;
		}
		unshift @a,$n;
		$n = join $delimiter,@a;
		$n = "$n\.$d" if $d =~ /\d/;
		return $n;
	}
	sub get_file_data {	## subroutine to get data from file
		my ($filename) = @_;
		my @filedata = ( );  ##initialize variables
		unless( open(GET_FILE_DATA, $filename) )	{
			print STDERR " Cannot open file \"$filename\"\n\n";
		}
		@filedata= <GET_FILE_DATA>;
		close GET_FILE_DATA;
		return @filedata;
	}
	sub parse_file_data	{	## subrountine to parse the file and get the required information
		my($filename) = $_[0];
		my($first) = $_[1];
		my($last) = $_[2];
		unless( open (PARSE_FILE_DATA,"$filename"))	{
			print STDERR " Cannot open file \"$filename\"\n\n";
		}
		my @filedata =( );
		my $data = ' ' ;
		my $data1;
		@filedata= <PARSE_FILE_DATA>;
		close PARSE_FILE_DATA;
		my $count=0;
		foreach my $line (@filedata)	{
			$line =~ s/<([^>]|\n)*>//g ;
			$line =~ s/^\s+// ;
			if ($line =~ /^.*$last/)	{	last;	}
			elsif($count)	{	$data .=$line;	}
			elsif($line =~ /^.*$first/)		{	$count =1;	}
		}
		return $data;
	}
	my $output = "$path/Main_Document.html";
	print "Generating the Document... \n";
	open (OUT,">$output");
	print OUT "<html>"; 
	print OUT "<head>"; 
	print OUT "<title>${tool} Capture Analysis Main Document for $run_num</title>"; 
	print OUT "<style>";
	print OUT "table.helpT	{ text-align: center;font-family: Verdana;font-weight: normal;font-size: 11px;color: #404040;width: auto;
	background-color: #fafafa;border: 1px #6699CC solid;border-collapse: collapse;border-spacing: 0px; }
	td.helpHed	{ border-bottom: 2px solid #6699CC;border-left: 1px solid #6699CC;background-color: #BEC8D1;text-align: left;
	text-indent: 5px;font-family: Verdana;font-weight: bold;font-size: 11px;color: #404040; }
	td.helpBod	{ border-bottom: 1px solid #9CF;border-top: 0px;border-left: 1px solid #9CF;border-right: 0px;text-align: left;
	text-indent: 10px;font-family: Verdana, sans-serif, Arial;font-weight: normal;font-size: 11px;color: #404040;
	background-color: #fafafa; }
	table.sofT	{ text-align: center;font-family: Verdana;font-weight: normal;font-size: 11px;color: #404040;width: 580px;
	background-color: #fafafa;border: 1px #6699CC solid;border-collapse: collapse;border-spacing: 0px; }"; 
	print OUT "</style>";
	print OUT "</head>";
	print OUT "<body>";
	print DESC "<html>"; 
	print DESC "<head>"; 
	print OUT "<title>${tool} Column Description for the Statistics per sample</title>"; 
	print DESC "<style>";
	print DESC "table.helpT	{ text-align: center;font-family: Verdana;font-weight: normal;font-size: 11px;color: #404040;width: auto;
	background-color: #fafafa;border: 1px #6699CC solid;border-collapse: collapse;border-spacing: 0px; }
	td.helpHed	{ border-bottom: 2px solid #6699CC;border-left: 1px solid #6699CC;background-color: #BEC8D1;text-align: left;
	text-indent: 5px;font-family: Verdana;font-weight: bold;font-size: 11px;color: #404040; }
	td.helpBod	{ border-bottom: 1px solid #9CF;border-top: 0px;border-left: 1px solid #9CF;border-right: 0px;text-align: left;
	text-indent: 10px;font-family: Verdana, sans-serif, Arial;font-weight: normal;font-size: 11px;color: #404040;
	background-color: #fafafa; }
	table.sofT	{ text-align: center;font-family: Verdana;font-weight: normal;font-size: 11px;color: #404040;width: 580px;
	background-color: #fafafa;border: 1px #6699CC solid;border-collapse: collapse;border-spacing: 0px; }"; 
	print DESC "</style>";
	print DESC "</head>";
	print DESC "<body>";
	
	print OUT "<p align='center'> §§§ <b>Mayo BIC PI Support</b> §§§   </p>";
	## making the index for the document
	print OUT "<a name=\"top\"></a>";
	print OUT "
	<table id=\"toc\" class=\"toc\" ><tr><td><div id=\"toctitle\"><h2>Contents</h2></div>
	<ul>
	<li class=\"toclevel-1\"><a href=\"#Project Title\"><span class=\"tocnumber\">1</span>
	<span class=\"toctext\">Project Title</span></a></li>
	<li class=\"toclevel-1\"><a href=\"#Project Description\"><span class=\"tocnumber\">2</span>
	<span class=\"toctext\">Project Description</span></a></li>
	<ul>
	<li class=\"toclevel-2\"><a href=\"#Background\"><span class=\"tocnumber\">2.1</span>
	<span class=\"toctext\">Background</span></a></li>
	<li class=\"toclevel-2\"><a href=\"#Study design\"><span class=\"tocnumber\">2.2</span>
	<span class=\"toctext\">Study design</span></a></li>
	</ul>
	<li class=\"toclevel-1\"><a href=\"#Analysis plan\"><span class=\"tocnumber\">3</span>
	<span class=\"toctext\">Analysis plan</span></a></li>
	<li class=\"toclevel-1\"><a href=\"#Received Data\"><span class=\"tocnumber\">4</span>
	<span class=\"toctext\">Received Data</span></a></li>
	<ul>
	<li class=\"toclevel-2\"><a href=\"#Sample Summary\"><span class=\"tocnumber\">4.1</span>
	<span class=\"toctext\">Sample Summary</span></a></li>
	</ul>
	<li class=\"toclevel-1\"><a href=\"#Results Summary\"><span class=\"tocnumber\">5</span>
	<span class=\"toctext\">Results Summary</span></a></li>
	<ul>
	<li class=\"toclevel-2\"><a href=\"#Statistics based on per sample analysis\"><span class=\"tocnumber\">5.1</span>
	<span class=\"toctext\">Statistics based on per sample analysis</span></a></li>";
	if ( ( $analysis eq 'variant' ) || ( $analysis eq 'all' ) )
	{
		print OUT "
		<li class=\"toclevel-2\"><a href=\"#Percent coverage of target region\"><span class=\"tocnumber\">5.2</span>
		<span class=\"toctext\">Percent coverage of target region</span></a></li>";
	}
	print OUT "
	</ul>
	<li class=\"toclevel-1\"><a href=\"#Results and Conclusions\"><span class=\"tocnumber\">6</span>
	<span class=\"toctext\">Results and Conclusions</span></a></li>
	<li class=\"toclevel-1\"><a href=\"#Results Delivered\"><span class=\"tocnumber\">7</span>
	<span class=\"toctext\">Results Delivered</span></a></li>
	<li class=\"toclevel-1\"><a href=\"#Useful Links\"><span class=\"tocnumber\">8</span>
	<span class=\"toctext\">Useful Links</span></a></li></ul><br>
	</td></tr></table>
	</script>";
	print OUT "<a name=\"Project Title\" id=\"Project Title\"></a><p align='left'><b><u> I. Project Title : </p></b></u>\n";
	print OUT "<ul><table cellspacing=\"0\" class=\"sofT\"> <tr> <td class=\"helpHed\">NGS Bioinformatics for ${tool} sequencing</td> </tr> </table> <br></ul>\n";
	my $read_call;	if($paired == 1)	{	$read_call = 'PE';	}	else	{	$read_call = 'SR';	}	
	my $num_samples=scalar(@sampleArray);
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;   ## to pull todays date
	$year += 1900;$mon++;
	print OUT "<a name=\"Project Description\" id=\"Project Description\"></a><p align='left'><b><u> II. Project Description</p></b></u>";
	print OUT "<ul><a name=\"Background\" id=\"Background\"></a><p align='left'> 1. Background</p>";
	print OUT "<table cellspacing=\"0\" class=\"sofT\"><tr>
	<td class=\"helpHed\">Item</td>
	<td class=\"helpHed\">Description</td></tr>
	<td class=\"helpBod\">Disease Type</td><td class=\"helpBod\">$disease</td></tr>
	<td class=\"helpBod\">Number of Samples</td><td class=\"helpBod\">$num_samples</td></tr>";
	if ($analysis ne 'annotation')	{
		print OUT "<td class=\"helpBod\">Read Length</td><td class=\"helpBod\">$read_length</td></tr>
		<td class=\"helpBod\">PairedEnd(PE)/SingleRead(SR)</td><td class=\"helpBod\">$read_call</td></tr>";
	}
	print OUT "<td class=\"helpBod\">Genome Build (hg18/hg19)</td><td class=\"helpBod\">$GenomeBuild</td></tr>
	<td class=\"helpBod\">StartDate</td><td class=\"helpBod\">$date</td></tr>
	<td class=\"helpBod\">EndDate</td><td class=\"helpBod\">$mon/$mday/$year</td></tr>
	</table>";
	print OUT "Note: Further raw NGS data will be used for statistical analysis<br>\n";
	my $loc=$path;
	$loc =~ s/\//\\/g;
	my @TREAT_ver=split(/\//,$script_path);
	print OUT "Location:: <b><u>\\\\rcfcluster-cifs$loc</b></u> <br>";
	print OUT "(Data is available for 60 Days from the Delivered Date)<br>";
	print OUT "<a name=\"Study design\" id=\"Study design\"></a><p align='left'> 2. Study design</p>";
	print OUT "<ul>
	<li><b> What are the samples? </b><br>
	${sampleinfo}
	<li><b> Goals of the project</b><br>";
	if ($analysis eq 'alignment')	{
		print OUT "Aligning sequencing samples using ${Aligner}";
	}
	else	{	
		print OUT "Identify how well ${tool} sequencing worked on these samples,and obtain the list of variants with annotations using SIFT and SSeq ";
	}	
	print OUT "</ul></ul>\n";
	print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
	print OUT "<a name=\"Analysis Plan\" id=\"Analysis Plan\"></a><p align='left'><b><u> III. Analysis Plan</p></b></u><br>\n";
	print OUT "<b><P ALIGN=\"CENTER\">What's new: New features and updates </b> <a href= \"http://bioinformatics.mayo.edu/BMI/bin/view/Main/BioinformaticsCore/Analytics/TREAT\"target=\"_blank\">TREAT</a></P>";
	print OUT "<P ALIGN=\"CENTER\"><img border=\"0\" src=\"${tool}_workflow.JPG\" width=\"354\" height=\"478\"><b><u><caption align=\"bottom\">$TREAT_ver[-1]</caption></b></u></p>";
	print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
	print OUT "<a name=\"Received Data\" id=\"Received Data\"></a><p align='left'><b><u> IV. Received Data</p></b></u> 
	<ul>
	1. Run Name<br>
	<br><table cellspacing=\"0\" class=\"sofT\"><tr><td class=\"helpHed\">Run #</td><td class=\"helpBod\">$run_num</td> </table><br>\n";
	## printing the samples information table
	
	print OUT "<a name=\"Sample Summary\" id=\"Sample Summary\"></a> 2. Sample Summary<br>
	<br><table cellspacing=\"0\" class=\"sofT\"><tr>
	<td class=\"helpHed\">Lane</td><td class=\"helpHed\">Sample Names</td></tr>";
	for (my $i = 0; $i < $num_samples; $i++)	{
		my @LaneNumbers= split(/,/,$laneArray[$i]);
		my $len_lanes = scalar(@LaneNumbers);
		for (my $j =0; $j < $len_lanes; $j++)	{
			print OUT "<td class=\"helpBod\">$LaneNumbers[$j]</td><td class=\"helpBod\">$sampleArray[$i]</td></tr>\n";	
		}
	}	
	print OUT "<td class=\"helpHed\"></td><td class=\"helpHed\"></td></tr>";
	print OUT "</table>";	
	if ( $analysis eq 'mayo' )	{
		print OUT "<b><u>NOTE:</u></b>Meta Data Information available for samples in the form of Lab Tracking Report(<u><a href=\"LTR.xls\"target=\"_blank\">LTR</a></u>)<br>";
	}	
	print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
	print OUT "</ul>
	<a name=\"Results Summary\" id=\"Results Summary\"></a><p align='left'><u><b> V.  Results Summary:</p></u></b>\n";
	if ( ($analysis eq "mayo") || ($analysis eq "all" ) || ($analysis eq "alignment") )	{
		if($fastqc eq "YES")	{
			print OUT "
			<ul>
			<li><a name=\"QC steps\" id=\"QC steps\"></a> QC steps - FastQC-report
			<ul>
			FastQC aims to provide a simple way to do some quality control checks on raw sequence data coming from high throughput sequencing pipelines. It provides a modular set of analyses which you can use to give a quick impression of whether your data has any problems of which you should be aware before doing any further analysis.
			<u> <a href= \"fastqc\"target=\"_blank\">ClickMe</a></u>
			<br><b><u>NOTE:</b></u>FastQC runs a series of tests and will flag up and potential problems with your data<br>\n";
			print OUT "</ul></ul>";
		}
		else	{
			print OUT "
			<ul>
			<li><a name=\"QC steps\" id=\"QC steps\"></a> QC steps - FastQC-report
			<ul>
			FastQC aims to provide a simple way to do some quality control checks on raw sequence data coming from high throughput sequencing pipelines. It provides a modular set of analyses which you can use to give a quick impression of whether your data has any problems of which you should be aware before doing any further analysis.
			<u> <a href= \"http://${server}/reports/$run_num/fastqc/ \"target=\"_blank\"><br>ClickMe</a></u>
			<br><b><u>NOTE:</b></u>FastQC runs a series of tests and will flag up and potential problems with your data<br>\n";
		print OUT "</ul></ul>";
		}	
	}
	print OUT"
	<ul><li><a name=\"Statistics based on per sample analysis\" id=\"Statistics based on per sample analysis\"></a>Statistics based on per Sample Analysis(<u><a href=\"StatiticsDesciption.html\"target=\"_blank\">ColumnDescription</a></u>)<br>\n";
	print OUT "<br><table cellspacing=\"0\" class=\"sofT\"><tr><td class=\"helpHed\"><p align='center'></td>";
	my %sample_numbers=();
	my $uniq;
	## storing all the numbers in a Hash per sample (opne hash)
	for(my $k = 0; $k < $num_samples;$k++)	
	{
		print OUT "<td class=\"helpHed\"><p align='center'>$sampleArray[$k]</td>";
		my $file="$path/numbers/$sampleArray[$k].out";
		open SAMPLE, "<$file", or die "could not open $file : $!";
		print"reading numbers from $sampleArray[$k]\n";
		my $id=0;
		while(my $l = <SAMPLE>)	
		{			
			chomp $l;
			if ( $l !~ /^\d/)	{
				$uniq = $id;
				$id++;
			}	
			else	{
				push (@{$sample_numbers{$uniq}},$l);
			}
			
		}	
		close SAMPLE;
	}
	print OUT "</tr>";
	my @To_find;
	my ( $avg_per, $avg_mapped_reads, $per_ontarget, $per_mapped, $per_mapped_reads, $per_ontarget_q20, $per_ontarget_re_q20 );
	my @what;
	## header description
	if ( ( $analysis ne 'annotation' ) && ( $analysis ne 'alignment' ) ) {
		@what=("Total number of reads obtained","Number of reads mapped to the reference using ${Aligner}","Number of reads mapped to the reference using ${Aligner} (Q>=20)","Number of reads after recalibration and realignment using GATK (Q>=20)","Number of Reads covering the Target region","SNVs obtained using ${SNV_caller} and discarding homozygour reference calls (probability >=0.8)","SNVs in target region(s) defined","SNVs in the CaptureKit region(s) used in sequencing","Transtitions over number of Transversions. Transition is defined as a change among purines or pyrimidines (A to G, G to A, C to T, and T to C). Transversion is defined as a change from purine to pyrimidine or vice versa (A to C, A to T, G to C, G to T, C to A, C to G, T to A, and T to G)","SNVs found in dbSNP$dbsnp_v","SNVs not in dbSNP$dbsnp_v","Total number of INDELs found using GATK","INDELs found along the target region(s) defined","INDELs in CaptureKit region(s) used in sequencing","Indels leading to frameshift mutation;resulting in a completely different translation from the original","Indels in coding region but not frameshift mutation","Indels in Splice Site","SNVs found in dbSNP$dbsnp_v","Probability of a transtition over probability of a transversion","SNVs that lead to a stop codon","SNVs that lead to codons coding for different amino acids","SNVs that lead to codon change without changing the amino acid","Number of SNVs that lead to codon change, but number of coding bases is not a multiple of 3","SNVs where the two alleles at that position are identical","Number of SNVs where the two alleles at that position are different","SNVs not in dbSNP$dbsnp_v","Probability of a transtition over probability of a transversion","SNVs that lead to a stop codon","SNVs that lead to codons coding for different amino acids","SNVs that lead to codon change without changing the amino acid","SNVs that lead to codon change, but number of coding bases is not a multiple of 3","SNVs where the two alleles at that position are identical","SNVs where the two alleles at that position are different" );
	}
	elsif($analysis eq 'alignment' )	{
		@what=("Total number of reads obtained","Number of reads mapped to the reference using ${Aligner}","Number of reads mapped to the reference using ${Aligner} (Q>=20)");
	}
	elsif (  $analysis eq 'annotation' )	{
		if ( $variant_type eq 'BOTH' )	{
			@what=("SNVs in target region(s) defined","Transtitions over number of Transversions. Transition is defined as a change among purines or pyrimidines (A to G, G to A, C to T, and T to C). Transversion is defined as a change from purine to pyrimidine or vice versa (A to C, A to T, G to C, G to T, C to A, C to G, T to A, and T to G)","SNVs found in dbSNP$dbsnp_v","SNVs not in dbSNP$dbsnp_v","INDELs found along the target region(s) defined","Indels leading to frameshift mutation;resulting in a completely different translation from the original","Indels in coding region but not a frameshift mutation","Indels in Splice Site","SNVs found in dbSNP$dbsnp_v","Probability of a transtition over probability of a transversion","SNVs that lead to a stop codon","SNVs that lead to codons coding for different amino acids","SNVs that lead to codon change without changing the amino acid","Number of SNVs that lead to codon change, but number of coding bases is not a multiple of 3","SNVs not in dbSNP$dbsnp_v","Probability of a transtition over probability of a transversion","SNVs that lead to a stop codon","SNVs that lead to codons coding for different amino acids","SNVs that lead to codon change without changing the amino acid","SNVs that lead to codon change, but number of coding bases is not a multiple of 3");
		}
		elsif ( $variant_type eq 'SNV' )	{
			@what=("SNVs in target region(s) defined","Transtitions over number of Transversions. Transition is defined as a change among purines or pyrimidines (A to G, G to A, C to T, and T to C). Transversion is defined as a change from purine to pyrimidine or vice versa (A to C, A to T, G to C, G to T, C to A, C to G, T to A, and T to G)","SNVs found in dbSNP$dbsnp_v","SNVs not in dbSNP$dbsnp_v","SNVs found in dbSNP$dbsnp_v","Probability of a transtition over probability of a transversion","SNVs that lead to a stop codon","SNVs that lead to codons coding for different amino acids","SNVs that lead to codon change without changing the amino acid","Number of SNVs that lead to codon change, but number of coding bases is not a multiple of 3","SNVs not in dbSNP$dbsnp_v","Probability of a transtition over probability of a transversion","SNVs that lead to a stop codon","SNVs that lead to codons coding for different amino acids","SNVs that lead to codon change without changing the amino acid","SNVs that lead to codon change, but number of coding bases is not a multiple of 3");
		}
		elsif ( $variant_type eq 'INDEL' )	{
			@what=("INDELs found along the target region(s) defined","Indels leading to frameshift mutation;resulting in a completely different translation from the original","Indels in coding region but not a frameshift mutation","Indels in Splice Site");
		}
	}	
	
	## header name
	if ( $analysis eq 'alignment' )	{
		@To_find=("Total Reads","Mapped Reads","Mapped Reads (Q >= 20)");
	}		
	elsif ( ( $analysis ne 'alignment' ) && ( $analysis ne 'annotation' ) ) {
		@To_find=("Total Reads","Mapped Reads","Mapped Reads (Q >= 20)","Used Reads","Mapped Reads in the Target region","Called SNVs (${SNV_caller})","SNVs in Target region","SNVs in CaptureKit region","Transition To Transversion Ratio","In dbSNP$dbsnp_v","NotIn dbSNP$dbsnp_v","Called Indels (GATK)","Indels in Target region","Indels in CaptureKit region","Indels leading to frameshift mutations","Indels in coding regions not frameshift","Indels in splice sites","Total Known SNVs","Transition To Transversion Ratio","Nonsense","Missense","coding-synonymous","coding-notMod3","Homozygous","Heterozygous","Total Novel SNVs","Transition To Transversion Ratio","Nonsense","Missense","coding-synonymous","coding-notMod3","Homozygous","Heterozygous");
	}
	elsif ( $analysis eq 'annotation' )	{
		if ( $variant_type eq 'BOTH' )	{
			@To_find=("SNVs in Target region","Transition To Transversion Ratio","In dbSNP$dbsnp_v","NotIn dbSNP$dbsnp_v","Indels in Target region","Indels leading to frameshift mutations","Indels in coding regions not frameshift","Indels in splice sites","Total Known SNVs","Transition To Transversion Ratio","Nonsense","Missense","coding-synonymous","coding-notMod3","Total Novel SNVs","Transition To Transversion Ratio","Nonsense","Missense","coding-synonymous","coding-notMod3");
		}
		elsif ( $variant_type eq 'SNV' )	{
			@To_find=("SNVs in Target region","Transition To Transversion Ratio","In dbSNP$dbsnp_v","NotIn dbSNP$dbsnp_v","Total Known SNVs","Transition To Transversion Ratio","Nonsense","Missense","coding-synonymous","coding-notMod3","Total Novel SNVs","Transition To Transversion Ratio","Nonsense","Missense","coding-synonymous","coding-notMod3");
		}
		elsif ( $variant_type eq 'INDEL' )	{
			@To_find=("Indels in Target region","Indels leading to frameshift mutations","Indels in coding regions not frameshift","Indels in splice sites");
		}	
	}	
	foreach my $key (sort {$a <=> $b} keys %sample_numbers)	{
		print OUT "<td class=\"helpHed\"><p align='left'><a href=\"#$To_find[$key]\" title=\"$what[$key]\">$To_find[$key]</a></td>";
		if ( $key eq '1')	{
			if ( $analysis ne 'annotation')	{
				for (my $c=0; $c < $num_samples;$c++)	{
					my $per_mapped = sprintf("%.1f",(${$sample_numbers{$key}}[$c] / ${$sample_numbers{0}}[$c]) * 100);
					my $print=CommaFormatted(${$sample_numbers{$key}}[$c]);
					print OUT "<td class=\"helpBod\">$print <br> <b>($per_mapped \%) <b></td>";
					$avg_mapped_reads=$avg_mapped_reads + ${$sample_numbers{$key}}[$c];
					$per_mapped_reads = $per_mapped_reads + $per_mapped; 
				}	
				$avg_mapped_reads=$avg_mapped_reads/$num_samples;$avg_mapped_reads=int($avg_mapped_reads/1000000);
				$per_mapped_reads =$per_mapped_reads/$num_samples;
				print OUT "</tr>\n";
			}
		}	
		if ( ( $key eq '2' ) || ( $key eq '3' ) )	{
			if ( $analysis ne 'annotation' )	{
				for (my $c=0; $c < $num_samples;$c++)	{
					my $per_mapped = sprintf("%.1f",(${$sample_numbers{$key}}[$c]/${$sample_numbers{0}}[$c])*100);
					my $print=CommaFormatted(${$sample_numbers{$key}}[$c]);
					print OUT "<td class=\"helpBod\">$print <br><b>($per_mapped \%)<b></td>";
				}
				print OUT "</tr>\n";
			}
		}		
		if ( $key eq '4' )	{
			if ( $analysis ne 'annotation' )	{
				for (my $c=0; $c < $num_samples;$c++)	{
					$per_ontarget = sprintf("%.1f",(${$sample_numbers{$key}}[$c]/${$sample_numbers{0}}[$c])*100);
					my $print=CommaFormatted(${$sample_numbers{$key}}[$c]);
					print OUT "<td class=\"helpBod\">$print <br> <b>($per_ontarget \%)</b></td>";
					$avg_per = $avg_per + $per_ontarget;
				}
				$avg_per=$avg_per/$num_samples;$avg_per=sprintf("%.2f",$avg_per);
				print OUT "</tr>\n";
			}
		}		
		
		if ($analysis ne 'annotation' )	{
			for ( my $c=0; $c < $num_samples; $c++ )	{
				if ( ( $key eq '1') || ( $key eq '2' ) || ( $key eq '3' ) || ( $key eq '4' ) )	{
				}
				else	{
					my $print=CommaFormatted(${$sample_numbers{$key}}[$c]);
					print OUT "<td class=\"helpBod\">$print</td>\n";	
				}
			}
		}
		else	{
			for ( my $c=0; $c < $num_samples; $c++ )	{
				my $print=CommaFormatted(${$sample_numbers{$key}}[$c]);
				print OUT "<td class=\"helpBod\">$print</td>\n";
			}
		}	
		print OUT "</tr>";
		## key 1 is for mapped reads
		## key 2 is for mapped reads ontarget
		if ( ( $analysis eq 'all' ) || ( $analysis eq 'variant' ) || ($analysis eq 'mayo') ) {	
			if ($key eq '16' )	{
				print OUT "<td class=\"helpBod\">KNOWN VARIANTS(in dbSNP$dbsnp_v)</td>";
				for (my $c=0; $c < $num_samples;$c++)	{
					print OUT "<td class=\"helpHed\"></td>";
				}		
				print OUT "</tr>\n";
			}	
			if ($key eq '24' )	{
				print OUT "<td class=\"helpBod\">NOVEL VARIANTS(Notin dbSNP$dbsnp_v)</td>";
				for (my $c=0; $c < $num_samples;$c++)	{
					print OUT "<td class=\"helpHed\"></td>";
				}		
				print OUT "</tr>\n";
			}
		}
		elsif ($analysis eq 'annotation')	{
			if ($variant_type eq 'BOTH')	{
				if ($key eq '7' )	{
					print OUT "<td class=\"helpBod\">KNOWN VARIANTS(in dbSNP$dbsnp_v)</td>";
					for (my $c=0; $c < $num_samples;$c++)	{
						print OUT "<td class=\"helpHed\"></td>";
					}		
					print OUT "</tr>\n";
				}	
				if ($key eq '13' )	{
					print OUT "<td class=\"helpBod\">NOVEL VARIANTS(Notin dbSNP$dbsnp_v)</td>";
					for (my $c=0; $c < $num_samples;$c++)	{
						print OUT "<td class=\"helpHed\"></td>";
					}		
					print OUT "</tr>\n";
				}
			}
			elsif( $variant_type eq 'SNV' )	{
				if ($key eq '3' )	{
					print OUT "<td class=\"helpBod\">KNOWN VARIANTS(in dbSNP$dbsnp_v)</td>";
					for (my $c=0; $c < $num_samples;$c++)	{
						print OUT "<td class=\"helpHed\"></td>";
					}		
					print OUT "</tr>\n";
				}	
				if ($key eq '9' )	{
					print OUT "<td class=\"helpBod\">NOVEL VARIANTS(Notin dbSNP$dbsnp_v)</td>";
					for (my $c=0; $c < $num_samples;$c++)	{
						print OUT "<td class=\"helpHed\"></td>";
					}		
					print OUT "</tr>\n";
				}
			}		
		}
	print OUT "</tr>";
	}	
	undef %sample_numbers;
	
	print OUT "</table>";
	print DESC "
	<p align='left'><b> Row description for Statistics Table:</p></b>
	<table cellspacing=\"0\" class=\"sofT\"><tr><td class=\"helpHed\">Column</td><td class=\"helpHed\">Description</td></tr>";
	if ($analysis eq 'alignment' )	{
		print DESC"
		<td class=\"helpBod\">Total Reads</td><td class=\"helpBod\">Total number of reads obtained</td></tr>
		<td class=\"helpBod\">Mapped Reads</td><td class=\"helpBod\">Number and percentage of reads mapped to reference genome(${GenomeBuild})</td></tr>
		<td class=\"helpBod\">Mapped Reads (Q >= 20)</td><td class=\"helpBod\">Number and percenatge of Mapped reads with a quality >= 20 mapped to reference genome(${GenomeBuild})</td></tr>
		</table></ul>";	
	}	
	
	if ( ($analysis eq "all") || ($analysis eq "variant" ) || ($analysis eq "mayo")  )	{
		print DESC"
		<td class=\"helpBod\">Total Reads</td><td class=\"helpBod\">Total number of reads obtained</td></tr>
		<td class=\"helpBod\">Mapped Reads</td><td class=\"helpBod\">Number and percentage of reads mapped to reference genome(${GenomeBuild})</td></tr>
		<td class=\"helpBod\">Mapped Reads (Q >= 20)</td><td class=\"helpBod\">Number and percenatge of Mapped reads with a quality >= 20 mapped to reference genome(${GenomeBuild})</td></tr>
		<td class=\"helpBod\">Used Reads</td><td class=\"helpBod\">Number and percenatge of reads after recalibration and realignemnt with a quality >= 20 mapped to reference genome(${GenomeBuild})</td></tr>
		<td class=\"helpBod\">Mapped Reads in the Target region </td><td class=\"helpBod\">Number and Percenatge of reads mapping to the target region(s) defined in the study</td></tr>
		<td class=\"helpBod\">Called SNVs ${SNV_caller}</td><td class=\"helpBod\">Total number of SNVs obtained using ${SNV_caller} using probability threshold (>=0.8)and discarding homozygous reference calls </td></tr>
		<td class=\"helpBod\">SNVs in CaptureKit region</td><td class=\"helpBod\">Number of SNVs in the capturekit region(s) used during sequencing</td></tr>
		<td class=\"helpBod\">Called Indels (GATK)</td><td class=\"helpBod\">Number of indels called using GATK</td></tr>
		<td class=\"helpBod\">Indels in CaptureKit region</td><td class=\"helpBod\">Number of indels in target region designed for study</td></tr>";
	}
	if ( ( $variant_type eq 'BOTH' ) || ( $variant_type eq 'SNV' ) )	{
		print DESC "
		<td class=\"helpBod\">SNVs in Target region</td><td class=\"helpBod\">Number of SNVs in the target region(s) defined by Study</td></tr>
		
		<td class=\"helpBod\">Transition to Transversion ratio</td><td class=\"helpBod\">Number of transtitions over number of transversions. Transition is defined as a change among purines or pyrimidines (A to G, G to A, C to T, and T to C). Transversion is defined as a change from purine to pyrimidine or vice versa (A to C, A to T, G to C, G to T, C to A, C to G, T to A, and T to G)</td></tr>
		<td class=\"helpBod\">In dbSNP$dbsnp_v</td><td class=\"helpBod\">Number of SNVs found in dbSNP$dbsnp_v and are known</td></tr>
		<td class=\"helpBod\">Not in dbSNP$dbsnp_v</td><td class=\"helpBod\">Number of SNVs not in dbSNP$dbsnp_v and are novel</td></tr>";
	}	
	if ( ( $variant_type eq 'BOTH' ) || ( $variant_type eq 'INDEL' ) )	{
		print DESC "
		<td class=\"helpBod\">Indels in Traget region</td><td class=\"helpBod\">Number of INDELs found along the target region(s) defined by Study</td></tr>";
	}
	if ( ( $variant_type eq 'BOTH' ) || ( $variant_type eq 'SNV' ) )	{
		print DESC "
		<td class=\"helpHed\">Known Variants</td><td class=\"helpHed\"></td></tr>
		<td class=\"helpBod\">Total Known Variants</td><td class=\"helpBod\">Number of SNVs found in dbSNP$dbsnp_v and are known</td></tr>
		<td class=\"helpBod\">Transition to Transversion ratio</td><td class=\"helpBod\">Probability of a transtition over probability of a transversion.</td></tr>
		<td class=\"helpBod\">Nonsense</td><td class=\"helpBod\">Number of SNVs that lead to a stop codon</td></tr>
		<td class=\"helpBod\">Missense</td><td class=\"helpBod\">Number of SNVs that lead to codons coding for different amino acids</td></tr>
		<td class=\"helpBod\">Coding-synonymous</td><td class=\"helpBod\">Number of SNVs that lead to codon change without changing the amino acid</td></tr>
		<td class=\"helpBod\">Coding-notMod3</td><td class=\"helpBod\">Number of SNVs that lead to codon change, but number of coding bases is not a multiple of 3</td></tr>
		<td class=\"helpBod\">Homozygous</td><td class=\"helpBod\">Number of SNVs where the two alleles at that position are identical</td></tr>
		<td class=\"helpBod\">Heterozygous</td><td class=\"helpBod\">Number of SNVs where the two alleles at that position are different</td></tr>
		<td class=\"helpHed\">Novel Variants</td><td class=\"helpHed\"></td></tr>
		<td class=\"helpBod\">Total Novel Variants</td><td class=\"helpBod\">Number of SNVs not in dbSNP$dbsnp_v and are novel</td></tr>
		<td class=\"helpBod\">Transition to Transversion ratio</td><td class=\"helpBod\">Probability of a transtition over probability of a transversion.</td></tr>
		<td class=\"helpBod\">Nonsense</td><td class=\"helpBod\">Number of SNVs that lead to a stop codon</td></tr>
		<td class=\"helpBod\">Missense</td><td class=\"helpBod\">Number of SNVs that lead to codons coding for different amino acids</td></tr>
		<td class=\"helpBod\">Coding-synonymous</td><td class=\"helpBod\">Number of SNVs that lead to codon change without changing the amino acid</td></tr>
		<td class=\"helpBod\">Coding-notMod3</td><td class=\"helpBod\">Number of SNVs that lead to codon change, but number of coding bases is not a multiple of 3</td></tr>
		<td class=\"helpBod\">Homozygous</td><td class=\"helpBod\">Number of SNVs where the two alleles at that position are identical</td></tr>
		<td class=\"helpBod\">Heterozygous</td><td class=\"helpBod\">Number of SNVs where the two alleles at that position are different</td></tr>
		</table></ul>";
	}
	print DESC "</ul>";
	print DESC "</body>\n"; 
	print DESC "</html>\n"; 
	close DESC;
	print OUT "</ul>";
	print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
	if ( ( $analysis eq "all" ) || ( $analysis eq "variant") || ($analysis eq "mayo")   )	{
		my $target=$target_region/1000000;$target=sprintf("%.2f",$target);
		print OUT "
		<ul><li><a name=\"Percent coverage of target region\" id=\"Percent coverage of target region\"></a>Percent coverage of target region
		<ul>
		The Probes target a region of $target Mbp. The figure below lists the percentage of that target region which is covered by at least N depth of coverage.
		</ul></ul>";
		print OUT "<P ALIGN=\"CENTER\"><img border=\"0\" src=\"Coverage.JPG\" width=\"704\" height=\"628\"></P> <P ALIGN=\"left\">";
		print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";		
	}
	print OUT "<a name=\"Results and Conclusions\" id=\"Results and Conclusions\"></a><p align='left'><u><b> VI.  Results and Conclusions:</p></u></b>";
	if  ($analysis ne "annotation") 	{
		print OUT"
		<ul>
		<li> $per_mapped_reads % of the data has been mapped to the genome (see section V.3 - row 3).
		<li> A high throughput with approximately $avg_mapped_reads millions passed filtering (see section V.3 - column 3).
		";
	}	
	if ($analysis ne "alignment"){
		print OUT "
		<li> Please note that the variants and annotation reports indicated in this main document may not be accurate since we have been observing inconsistent results with SIFT. SIFT and PolyPhen are currently under evaluation and we shall get back to you if we observe any changes with the variants and annotation results, as reported here.
		</ul>";
		print OUT "<b><u><ul> IGV Visualization</b></u><br>
		The SNV and INDEL annotation reports (both standard and filtered) include visualization links to IGV to enable a realistic view of the variants. Please follow steps in the following link to setup IGV (takes less than 5 minutes) and utilize this feature.<br>
		<a href= \"IGV_Setup.doc\"target=\"_blank\">IGV setup for variant visualization</a><br><br>";
		print OUT "<b><u>Synonymous codon change</b></u><br>
		Genetic code associates a set of sibling codons to the same amino acid, some codons occur more frequently than others in gene sequences. Biased codon usage results from a diversity of factors such as:
		<ul>
		<li>GC-content
		<li>preference for codons with G or C at the third nucleotide position
		<li>leading strand richer in G+T than lagging strand
		<li>translational bias frequently observed in fast growing organisms
		</ul>";
		print OUT "<br><b><u>BGI-Danish200 Exome Dataset</b></u><br>
		The data is from Exome resequencing of 200 individuals of Danish nationality, a collaborative project between BGI and Danish researchers. 
		<ul>
		<li>The BGI200exome column shows the two alleles and their frequencies (minor allele/major allele)
		</ul>";
		print OUT "<br><b><u>COSMIC Dataset</b></u><br>
		COSMIC (Catalogue of Somatic Mutations In Cancer) is a comprehensive source of somatic mutations and associated data found in human cancer. It's developed and maintained by the Cancer Genome Project (CGP) at the Wellcome Trust Sanger Institute. The curated data come from scientific papers in the literature and large scale experimental screens from CGP. 
			<ul>
			<li>The COSMIC column shows the COSMIC mutation ID; Mutation CDS; Mutation AA; strand
		</ul>";
	}	
	print OUT "</ul>";
	print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
	print OUT "<a name=\"Results Delivered\" id=\"Results Delivered\"></a><p align='left'><u><b> VIII. Results Delivered</p></u></b>";
	if (( $analysis eq "all") || ($analysis eq "variant") || ($analysis eq "mayo")  )	{
		print OUT "<ul>
		<li>Merged ${SNV_caller} results along with SIFT and SeattleSeq SNP annotation and Indel Annotation from Seattle Seq for all samples(<u><a href=\"ColumnDescription_Reports.xls\"target=\"_blank\">Column Description for Reports</a></u>)<br>
		<u> <a href= \"Reports/SNV.cleaned_annot.xls\"target=\"_blank\">SNV Report</a></u> <br>	
		<u> <a href= \"Reports/INDEL.cleaned_annot.xls\"target=\"_blank\">INDEL Report</a></u> <br><br>";
		print OUT " 
		<li>The filtered reports comprise of a much smaller list of variants for investigation and are based on the following criteria:
		<ul>
		- dbSNP$dbsnp_v column does not have an rs ID (novel), OR<br>
		- functionGVS column having 'missense', 'nonsense', 'splice-3', 'splice-5', 'coding-notMod3', 'utr-3' or 'utr-5' (intron, intergenic and coding-synonymous removed using SeattleSeq annotation, OR<br>
		- any variant reported within +/-2bp of an exon edge using 'distance' report for variants
		</ul>
		<u> <a href= \"Reports/SNV.cleaned_annot_filtered.xls\"target=\"_blank\">Filtered SNV Report</a></u> <br>
		<u> <a href= \"Reports/INDEL.cleaned_annot_filtered.xls\"target=\"_blank\">Filtered INDEL Report</a></u> <br></ul> ";
	}
	if ($analysis eq 'annotation')	{
		print OUT "<ul>Filtered report comprise of a much smaller list of variants based on following criterion:
		<ul>
		- dbSNP$dbsnp_v column does not have an rs ID (novel), OR<br>
		- functionGVS column having 'missense', 'nonsense', 'splice-3', 'splice-5', 'coding-notMod3', 'utr-3' or 'utr-5' (intron, intergenic and coding-synonymous removed using SeattleSeq annotation, OR<br>
		- any variant reported within +/-2bp of an exon edge using 'distance' report for variants
		</ul></ul>";
	}	
	if ($analysis ne 'alignment')	{
		print OUT "<ul>
		<li>Per sample SNV and INDEL files are available here comprises of filtered and unfiltered reports<br>
		<u> <a href= \"Reports_per_Sample\"target=\"_blank\">Per Sample Reports</a></u></ul>";
	}
	if ( ($analysis eq 'all') || ($analysis eq 'variant' ) || ($analysis eq "mayo")  )	{
		print OUT "<ul>
			<li>The variant distance for SNPs and INDEls (the distance to closest Exon) are recored in two files <br>
		<u> <a href= \"Reports/variantLocation_SNVs\"target=\"_blank\">SNV VariantDistance Report</a></u> <br>
		<u> <a href= \"Reports/variantLocation_INDELs\"target=\"_blank\">INDEL VariantDistance Report</a></u></ul> ";
	}
	print OUT "</ul>";
	if ($analysis eq 'alignment')	{
		print OUT "<ul>
		<li>Alignment and sorted BAM<br>
		<u> <a href= \"Alignment\"target=\"_blank\">Aligned Bam</a></u></ul>";
	}	
	print OUT "<ul>
		<li>Statistics based on per Sample Analysis are recorded in the tab delimited file<br>
		<u> <a href= \"SampleStatistics.tsv\"target=\"_blank\">SampleStatistics</a></u></ul>";
	
	if ($upload_tb eq 'YES')	{
		print OUT "<ul>
		<li>Variant calls can be visualized and filtered using TableBrowser<br>
		<u> <a href= \"http://${host}:${port}/TREATTableBrowser/\"target=\"_blank\">TableBrowser</a></u></ul>";
	}
	print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
	print OUT "<a name=\"Useful Links\" id=\"Useful Links\"></a><p align='left'><b><u> VII. Useful Links</p></b></u>
	<ul>
	<li><a href= \"http://sift.jcvi.org/www/SIFT_help.html\"target=\"_blank\">SIFT</a>
	<li><a href= \"http://gvs.gs.washington.edu/GVS/HelpSNPSummary.jsp\"target=\"_blank\">SeattleSeq </a>
	<li><a href= \"http://www.broadinstitute.org/software/igv/\"target=\"_blank\">Integrative Genomics Viewer</a>
	<li><a href= \"http://www.genecards.org/\"target=\"_blank\">GeneCards</a>
	<li><a href= \"http://www.ncbi.nlm.nih.gov/geo/\"target=\"_blank\">Gene Expression Omnibus</a>
	<li><a href= \"http://genome.ucsc.edu/\"target=\"_blank\">UCSC Genome Browser</a>
	</ul><br>";
	print OUT "
	<b><u>Authorship Consideration</u></b>: Advancing scientific research is a primary motivation of all bioinformaticians and acknowledgment of contribution through authorship on manuscripts arising from this analysis is one way our work is assessed and attributed. We request to be considered for authorship on any manuscripts using the analysis results provided if you believe we have made substantive intellectual contributions to the study.  
	";
	print OUT "
	<p align='center'> §§§ <b>Powered by Mayo BIC PI Support</b> §§§  </p> ";
	print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
 	print OUT "</body>\n"; 
	print OUT "</html>\n"; 
	close OUT;
	print "Document is generated with path as $output.......... \n";
}
