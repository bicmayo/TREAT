## Saurabh Baheti 12/23/2010
## Script to make a html report for exome capture analysis

use strict;
use warnings;

if(scalar(@ARGV) != 9)	
{
	die "\nUsage: SNVMix_workflow_main.doc.html.pl <Run Number> <Output folder Path> <disease type> <date from sequencing core> <sample names used colon seperated> <lanes used colon seperated> <target region> <paired> <indexed>";
}
else	
{
	my ($run_num) = $ARGV[0];chomp $run_num;
	my ($path) = $ARGV[1];chomp $path;
	my ($disease) = $ARGV[2];chomp $disease;
	my ($date) = $ARGV[3];chomp $date;
	my ($sampleNames) = $ARGV[4]; chomp $sampleNames;
	my @sampleArray=split(/:/,$sampleNames);
	my ($laneNumbers)= $ARGV[5];chomp $laneNumbers;
	my @laneArray=split(/:/,$laneNumbers);	
	my ($target_region)=$ARGV[6];chomp $target_region;
	my $paired = $ARGV[7];chomp $paired;
	my $indexed= $ARGV[8];chomp $indexed;
	print "@sampleArray\n";
	print "Run : $run_num \n";
	print "Result Folder : $path \n";
	my $numbers=$path."/numbers";
	sub get_file_data 
	{	## subroutine to get data from file
		use strict;
		use warnings;
		my ($filename) = @_;
		my @filedata = ( );  ##initialize variables
		unless( open(GET_FILE_DATA, $filename) )	
		{
			print STDERR " Cannot open file \"$filename\"\n\n";
		}
		@filedata= <GET_FILE_DATA>;
		close GET_FILE_DATA;
		return @filedata;
	}

	sub parse_file_data	
	{	## subrountine to parse the file and get the required information
		use strict;
		use warnings;	
		my($filename) = $_[0];
		my($first) = $_[1];
		my($last) = $_[2];
		unless( open (PARSE_FILE_DATA,"$filename"))	
		{
			print STDERR " Cannot open file \"$filename\"\n\n";
		}
		my @filedata =( );
		my $data = ' ' ;
		my $data1;
		@filedata= <PARSE_FILE_DATA>;
		close PARSE_FILE_DATA;
		my $count=0;
		foreach my $line (@filedata)	
		{
			$line =~ s/<([^>]|\n)*>//g ;
			$line =~ s/^\s+// ;
			if ($line =~ /^.*$last/)	
			{
				last;
			}
			elsif($count)	
			{
				$data .=$line;
			}
			elsif($line =~ /^.*$first/)	
			{
				$count =1;
			}
		}
		return $data;
	}

	my $output = "$path/Main_Document.html";
	print "Generating the Document... \n";
	open (OUT,">$output");
	print OUT "<html>"; 
	print OUT "<head>"; 
	print OUT "<title>Exome Capture Analysis Main Document for $run_num</title>"; 
	print OUT "<style>";
	print OUT "table.helpT	{ text-align: center;font-family: Verdana;font-weight: normal;font-size: 11px;color: #404040;width: 500px;
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
	## making the index for the document
	print OUT "<a name=\"top\"></a>";
	print OUT "
	<table id=\"toc\" class=\"toc\" ><tr><td><div id=\"toctitle\"><h2>Contents</h2></div>
	<ul>
	<li class=\"toclevel-1\"><a href=\"#Project Title\"><span class=\"tocnumber\">1</span>
	<span class=\"toctext\">Project Title</span></a></li>
	<li class=\"toclevel-1\"><a href=\"#Initial meeting/email and Timeline\"><span class=\"tocnumber\">2</span>
	<span class=\"toctext\">Initial meeting/email and Timeline</span></a></li>
	<li class=\"toclevel-1\"><a href=\"#Project Description\"><span class=\"tocnumber\">3</span>
	<span class=\"toctext\">Project Description</span></a></li>
	<ul>
	<li class=\"toclevel-2\"><a href=\"#Background\"><span class=\"tocnumber\">3.1</span>
	<span class=\"toctext\">Background</span></a></li>
	<li class=\"toclevel-2\"><a href=\"#Study design\"><span class=\"tocnumber\">3.2</span>
	<span class=\"toctext\">Study design</span></a></li>
	</ul>
	<li class=\"toclevel-1\"><a href=\"#Analysis plan\"><span class=\"tocnumber\">4</span>
	<span class=\"toctext\">Analysis plan</span></a></li>
	<li class=\"toclevel-1\"><a href=\"#Received Data\"><span class=\"tocnumber\">5</span>
	<span class=\"toctext\">Received Data</span></a></li>
	<ul>
	<li class=\"toclevel-2\"><a href=\"#Gerald folder \"><span class=\"tocnumber\">5.1</span>
	<span class=\"toctext\">Gerald folder</span></a></li>
	<li class=\"toclevel-2\"><a href=\"#Sample Summary\"><span class=\"tocnumber\">5.2</span>
	<span class=\"toctext\">Sample Summary</span></a></li>
	<li class=\"toclevel-2\"><a href=\"#Lane results summary\"><span class=\"tocnumber\">5.3</span>
	<span class=\"toctext\">Lane results summary</span></a></li>
	</ul>
	<li class=\"toclevel-1\"><a href=\"#Results Summary\"><span class=\"tocnumber\">6</span>
	<span class=\"toctext\">Results Summary</span></a></li>
	<ul>
	<li class=\"toclevel-2\"><a href=\"#QC steps\"><span class=\"tocnumber\">6.1</span>
	<span class=\"toctext\">QC steps</span></a></li>
	<li class=\"toclevel-2\"><a href=\"#Statistics based on per sample analysis\"><span class=\"tocnumber\">6.2</span>
	<span class=\"toctext\">Statistics based on per sample analysis</span></a></li>
	<li class=\"toclevel-2\"><a href=\"#Percent coverage of target region\"><span class=\"tocnumber\">6.3</span>
	<span class=\"toctext\">Percent coverage of target region</span></a></li>
	</ul>
	<li class=\"toclevel-1\"><a href=\"#Results and Conclusions\"><span class=\"tocnumber\">7</span>
	<span class=\"toctext\">Results and Conclusions</span></a></li>
	<li class=\"toclevel-1\"><a href=\"#Results Delivered\"><span class=\"tocnumber\">8</span>
	<span class=\"toctext\">Results Delivered</span></a></li></ul><br>
	</td></tr></table>
	</script>";

	print OUT "<a name=\"Project Title\" id=\"Project Title\"></a><p align='left'><b><u> I. Project Title : </p></b></u><br>";
	print OUT "<table cellspacing=\"0\" class=\"sofT\"> <tr> <td class=\"helpHed\">NGS Bioinformatics for Exome sequencing</td> </tr> </table> <br><br>";
	print OUT "<a name=\"Initial meeting/email and Timeline\" id=\"Initial meeting/email and Timeline\"></a><p align='left'><b><u> II. Initial Meetings and Time line:</p></b></u><br>";
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;   ## to pull todays date
	$year += 1900;$mon++;
	print OUT "<table cellspacing=\"0\" class=\"sofT\"> <tr> <td class=\"helpHed\">Item</td><td class=\"helpHed\">Date</td></tr>
	<td class=\"helpBod\">Email(transfer complete date)</td><td class=\"helpBod\">$date</td></tr>
	<td class=\"helpBod\">Deadline</td><td class=\"helpBod\">$mon/$mday/$year</td></tr>
	<td class=\"helpBod\">Completed</td><td class=\"helpBod\">$mon/$mday/$year</td></tr>
	<td class=\"helpBod\">Results Delivered</td><td class=\"helpBod\">$mon/$mday/$year</td></tr></table><br>";
	print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
	open(META,"/data2/bsi/reports/metadata/html/$run_num.xml.html");
	my @metadata1 =<META>;
	my $read_call;
	if(grep /PAIRED/,@metadata1)	
	{
		$read_call = 'PE';
	}
	else	
	{
		$read_call = 'SR';
	}	
	close META;	
	
	my $num_samples=scalar(@sampleArray);
	print OUT "<a name=\"Project Description\" id=\"Project Description\"></a><p align='left'><b><u> III. Project Description</p></b></u><br>";
	print OUT "<a name=\"Background\" id=\"Background\"></a><p align='left'><b> 1. Background</p></b><br>";
	my $read_length = parse_file_data("/data2/bsi/reports/metadata/html/$run_num.xml.html", "Cycle", "Flowcell");
	my $feature_part = parse_file_data("/data2/bsi/reports/metadata/html/$run_num.xml.html", "Read type", "Date");
	
	print OUT "<table cellspacing=\"0\" class=\"sofT\"><tr>
	<td class=\"helpHed\">Item</td>
	<td class=\"helpHed\">Description</td></tr>
	<td class=\"helpBod\">Disease Type</td><td class=\"helpBod\">$disease</td></tr>
	<td class=\"helpBod\">Number of Samples</td><td class=\"helpBod\">$num_samples</td></tr>
	<td class=\"helpBod\">Read Length</td><td class=\"helpBod\">$read_length</td></tr>
	<td class=\"helpBod\">PE or SR</td><td class=\"helpBod\">$read_call</td></tr></table>";
	# if ($paired eq '1')	
	#{
		# print "<td class=\"helpBod\">PE or SR</td><td class=\"helpBod\">Paired-end Samples</td></tr></table>";
	# }
	# else	
	#{
		# print "<td class=\"helpBod\">PE or SR</td><td class=\"helpBod\">SingleRead Samples</td></tr></table>";
	# }	
	print OUT "Note: Further raw NGS data will be used for statistical analysis<br>";
	my $loc=$path;
	$loc =~ s/\//\\/g;
	print OUT "Location:: <b><u>\\\\rcfcluster-cifs$loc</b></u> <br>";
	print OUT "(Data is available for 60 Days from the Delivered Date)<br><br>";
	print OUT "<a name=\"Study design\" id=\"Study design\"></a><p align='left'><b> 2. Study design</p></b><br>";
	print OUT "<ul>
	<li><b> What are the samples? </b><br>
	NA
	<li><b> Goals of the project</b><br>
	Identify how well exome sequencing worked on these samples,and obtain the list of variants with annotations using SIFT and SSeq 
	</ul>";
	print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
	print OUT "<a name=\"Analysis Plan\" id=\"Analysis Plan\"></a><p align='left'><b><u> IV. Analysis Plan</p></b></u><br>";
	print OUT "<P ALIGN=\"CENTER\"><img border=\"0\" src=\"exome_workflow.JPG\" ></P>";
	print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
	print OUT "<a name=\"Received Data\" id=\"Received Data\"></a><p align='left'><b><u> V. Received Data</p></b></u> 
	<ul>
	<li> <a name=\"Gerald folder\" id=\"Gerald folder\"></a> 1. Run Number from Sequencing Core<br>
	<br><table cellspacing=\"0\" class=\"sofT\"><tr><td class=\"helpHed\">Run #</td><td class=\"helpBod\">$run_num</td> </table><br>
	<li> <a name=\"Sample Summary\" id=\"Sample Summary\"></a> 2. Sample Summary(From LTR file)<br>";
	print OUT "<br><table cellspacing=\"0\" class=\"sofT\"><tr>
	<td class=\"helpHed\">Lane</td>
	<td class=\"helpHed\">Sample Names</td>
	<td class=\"helpHed\">Sample ID</td>
	<td class=\"helpHed\">Sample Name Used</td></tr>";
	open(META,"/data2/bsi/reports/metadata/html/$run_num.xml.html");
	
	my @samples;
	# for indexed or non indexed runs
	# one lane per sample is simple case
	# multiple lanes per sample is alternate case	
	print "@sampleArray\n";
	while(my $l =<META>)	
	{
		
		chomp $l;
		if ($l =~ /^<td class=\"helpBod\">.* /) 
		{
			$l =~ s/<td class=\"helpBod\">//g;
			$l=~ s/<\/td>/\t/g;
			@samples = split( /\t/,$l);	
			for (my $i = 0 ; $i < $num_samples; $i++)		
			{
				my @split_lanes=split(/,/,$laneArray[$i]);
				if ($samples[1] == $split_lanes[0])	
				{
					if($indexed eq 'indexed'){
						print OUT "<td class=\"helpBod\">$samples[2]</td>
						<td class=\"helpBod\">$samples[0]</td>
						<td class=\"helpBod\">$samples[4]</td>
						<td class=\"helpBod\">$sampleArray[$num_samples]</td></tr>";
						$num_samples++;
					}
					else	
					{
						print OUT "<td class=\"helpBod\">$samples[1]</td>
						<td class=\"helpBod\">$samples[0]</td>
						<td class=\"helpBod\">$samples[3]</td>
						<td class=\"helpBod\">$sampleArray[$i]</td></tr>";
						# $num_samples++;	
					}
					
				}	
			}	
		}		
	}
	close META;
	print OUT "</table><br>";	
	print OUT "<li><a name=\"Lane results Summary\" id=\"Lane results Summary\"></a>3. Lane results Summary (from summary.html in Gerald folder)for Run# $run_num<br>";
	my @geralddata = ( ); 
	my @geralddata_R2 = ( );
	opendir(IMD, "/data2/bsi/reports/$run_num/BaseCalls/") or die ("Cannot open Directory\n");
	my @BaseCallsfiles= readdir(IMD);
	close(IMD);

print "Very close to deliver the data .... \n";
	my $fastqc_file;
	my @error;
	print "Hello\n";
	if($paired eq '0')	
	{
		print "Hello\n";
		my $gerald_file;
		foreach my $f (@BaseCallsfiles)	
		{
			if($f =~ /summary/)	
			{
				$gerald_file = $f;	
			}
			if($f =~ /fastqc/)	
			{
				$fastqc_file =$f;
			}
		}
	#	print "$fastqc_file\n";
		unless( open(SUMMARY, "/data2/bsi/reports/$run_num/BaseCalls/$gerald_file") )	
		{
			print STDERR "Error: $! \n\n";
		
		}
		##TO PARSE THE DATA
		my $data1 =' ';
		my $in_data1 = 0;
		@geralddata = <SUMMARY>;
		foreach my $line1(@geralddata)     
		{
			if($line1 =~ /^.*Expanded Lane Summary/)  
			{
				last;
			}
			elsif($in_data1) 
			{
				$line1 =~ s/"/\"/g;
				$line1 =~ s/cellpadding="5">/cellpadding="0">/g;
				$data1 .= $line1;
			}
			elsif($line1 =~ /^.*Lane Results Summary/)    
			{
				$line1 =~ s/"/\"/g;
				$line1 =~ s/cellpadding="5">/cellpadding="0">/g;
				$data1 .=$line1;
				$in_data1 = 1;
			}
		}
		print OUT "$data1";
	}
	else	
	{
		my $gerald_files;
		foreach my $f (@BaseCallsfiles)	
		{
			if($f =~ /summary/)	
			{
				$gerald_files=$f;
			}
			if($f =~ /fastqc/)	
			{
				$fastqc_file =$f;
			}
	#		print "$fastqc_file\n";
		}
		unless( open(SUMMARY, "/data2/bsi/reports/$run_num/BaseCalls/$gerald_files") )	
		{
			print STDERR "Error: $! \n\n";
		
		}
		##TO PARSE THE DATA
		my $data1 =' ';
		my $in_data1 = 0;
		@geralddata = <SUMMARY>;
		# @error=grep(/Average/,@geralddata);
		# print join("\n",@error);
		# <STDIN>;
		foreach my $line1(@geralddata)    
		{
			if($line1 =~ /^.*Lane Results Summary : Read 2/) 
			{
				last;
			}
			elsif($in_data1) 
			{
				$line1 =~ s/"/\"/g;
				$line1 =~ s/cellpadding="5">/cellpadding="0">/g;
				$data1 .= $line1;
			}
			elsif($line1 =~ /^.*Lane Results Summary : Read 1/)   
			{
				$line1 =~ s/"/\"/g;
				$line1 =~ s/cellpadding="5">/cellpadding="0">/g;
				$data1 .=$line1;
				$in_data1 = 1;
			}
		}
		print OUT "$data1";
		close SUMMARY;
		unless( open(SUMMARY, "/data2/bsi/reports/$run_num/BaseCalls/$gerald_files") )	
		{
			print STDERR "Error: $! \n\n";
	
		}
		#TO PARSE THE DATA
		my $data1_R2 =' ';
		my $in_data1_R2 = 0;
		@geralddata_R2 = <SUMMARY>;
		
		foreach my $line1_R2(@geralddata_R2)     
		{
			if($line1_R2 =~ /^.*Expanded Lane Summary : Read 1/) 
			{
				last;
			}
			elsif($in_data1_R2) {
				$line1_R2 =~ s/"/\"/g;
				$line1_R2 =~ s/cellpadding="5">/cellpadding="0">/g;
				$data1_R2 .= $line1_R2;
			}
			elsif($line1_R2 =~ /^.*Lane Results Summary : Read 2/)  
			{
				$line1_R2 =~ s/"/\"/g;
				$line1_R2 =~ s/cellpadding="5">/cellpadding="0">/g;
				$data1_R2 .=$line1_R2;
				$in_data1_R2 = 1;
			}
		}
		print OUT "$data1_R2";
	}	
	close (SUMMARY);
	
	print "Data from the Sequencing core is Extracted and printed ...... \n";
	print OUT "<p align='left'><b> Column description for Lane Results Summary Table:</p></b>\n";
 
	print OUT "<table cellspacing=\"0\" class=\"sofT\"><tr><td class=\"helpHed\">Column</td><td class=\"helpHed\">Description</td></tr>
	<td class=\"helpBod\">Lane Yield</td><td class=\"helpBod\">The number of bases (in kbases)</td></tr>
	<td class=\"helpBod\">Clusters (raw)</td><td class=\"helpBod\">The number of clusters detected by the image analysis module of the Pipeline</td></tr>
	<td class=\"helpBod\">Clusters (PF)</td><td class=\"helpBod\">The number of detected clusters that meet the filtering criterion listed in Lane Parameter Summary</td></tr>
	<td class=\"helpBod\">1st Cycle Int (PF)</td><td class=\"helpBod\">The average of the four intensities (one per channel or base type) measured at the first cycle averaged over filtered clusters</td></tr>
	<td class=\"helpBod\">\% Intensity after 20 cycles (PF)</td><td class=\"helpBod\">The corresponding intensity statistic at cycle 20 as a percentage of that at the first cycle</td></tr>
	<td class=\"helpBod\">\% PF Clusters</td><td class=\"helpBod\">The percentage of clusters passing filtering</td></tr>
	<td class=\"helpBod\">\% Align (PF)</td><td class=\"helpBod\">The percentage of filtered reads that were uniquely aligned to the reference</td></tr>
	<td class=\"helpBod\">Alignment Score (PF)</td><td class=\"helpBod\">The average filtered read alignment score (reads with multiple or no alignments effectively contribute scores of 0)</td></tr>
	<td class=\"helpBod\">\% Error Rate (PF)</td><td class=\"helpBod\">The percentage of called bases in aligned reads that do not match the reference</td></tr>
	</table><br></ul>";
	print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
	print OUT "<a name=\"Results Summary\" id=\"Results Summary\"></a><p align='left'><u><b> VI.  Results Summary:</p></u></b>
	<ul>
	<li><a name=\"QC steps\" id=\"QC steps\"></a>1. QC steps - Fastqc-report
	<ul>
	FastQC aims to provide a simple way to do some quality control checks on raw sequence data coming from high throughput sequencing pipelines. It provides a modular set of analyses which you can use to give a quick impression of whether your data has any problems of which you should be aware before doing any further analysis.
	<u> <a href= \"http://bmidev2/reports/$run_num/BaseCalls/$fastqc_file\"target=\"_blank\"><br>HTML Link </a></u>
	</ul>";
	# make arrays for each sample
	
	# print "$number_file\n";
	# print "$num_samples\n";
	# print "$sampleArray[0]\n";
	print OUT "<li><a name=\"Statistics based on per sample analysis\" id=\"Statistics based on per sample analysis\"></a> 2.Statistics based on per Sample Analysis";
	print OUT "<br><table cellspacing=\"0\" class=\"sofT\"><tr>
		<td class=\"helpHed\"><p align='center'></td>";
	my @numbers;
	my @reads;
	my @mappedreads;
	my @percentage;
	my @coverage1;
	my @coverage2;
	my @coverage3;
	my @coverage4;
	my @ontargetReads;
	my @mappedpercentage;
	my @totalSNVs;
	my @filteredSNVs;
	my @ontargetFiltSNVs;
	my @overallTT;
	my @indbSNP;
	my @notindbSNP;
	my @totalINDELs;
	my @ontargetINDELs;
	my @frameshiftINDELs;
	my @codingINDELs;
	my @spliceINDELs;
	my @known;
	my @knownTT;
	my @knownnonsense;
	my @knownmissense;
	my @knowncoding;
	my @knownnotMod3;
	my @knownhomo;
	my @knownhetro;
	my @novel;
	my @novelTT;
	my @novelnonsense;
	my @novelmissense;
	my @novelcoding;
	my @novelnotMod3;
	my @novelhomo;
	my @novelhetro;
	
	my $number_count=0;
	my $number_file = 0;
	my $i = 0;
	for(my $k = 0; $k < $num_samples;$k++)	
	{
		print OUT "<td class=\"helpHed\"><p align='center'>$sampleArray[$k]</td>";
		open(SAMPLE,"<$path/numbers/$sampleArray[$k].out");
		print"reading numbers from $sampleArray[$k]\n";
		while(my $l = <SAMPLE>)	
		{
			chomp $l;
			if( $. == 2)	
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@reads,$numbers);
			}
			elsif($. == 4)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@mappedreads,$numbers);
			}
			elsif($. == 6)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@ontargetReads,$numbers);
			}
			elsif($. == 8)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@coverage1,$numbers);
			}
			elsif($. == 9)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@coverage2,$numbers);
			}
			elsif($. == 10)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@coverage3,$numbers);
			}
			elsif($. == 11)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@coverage4,$numbers);
			}
			
			elsif($. == 13)	
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@totalSNVs,$numbers);
			}
			elsif($. == 15)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@filteredSNVs,$numbers);
			}
			elsif ($. == 17)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@ontargetFiltSNVs,$numbers);
			}
			elsif($. == 19)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@overallTT,$numbers);
			}
			elsif($. == 21)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@indbSNP,$numbers);
			}
			elsif($. == 23)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@notindbSNP,$numbers);
			}
			elsif($. == 25)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@totalINDELs,$numbers);
			}
			elsif($. == 27)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@ontargetINDELs,$numbers);
			}
			elsif($. == 29)	
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@frameshiftINDELs,$numbers);
			}
			elsif($. == 31)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@codingINDELs,$numbers);
			}
			elsif ($. == 33)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@spliceINDELs,$numbers);
			}

			elsif($. == 35)	
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@known,$numbers);
			}
			elsif($. == 37)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@knownTT,$numbers);
			}
			elsif ($. == 39)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@knownnonsense,$numbers);
			}
			elsif($. == 41)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@knownmissense,$numbers);
			}
			elsif($. == 43)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@knowncoding,$numbers);
			}
			elsif($. == 45)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@knownnotMod3,$numbers);
			}
			elsif($. == 47)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@knownhomo,$numbers);
			}
			elsif($. == 49)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@knownhetro,$numbers);
			}
			elsif($. == 51)	
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@novel,$numbers);
			}
			elsif($. == 53)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@novelTT,$numbers);
			}
			elsif ($. == 55)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@novelnonsense,$numbers);
			}
			elsif($. == 57)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@novelmissense,$numbers);
			}
			elsif($. == 59)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@novelcoding,$numbers);
			}
			elsif($. == 61)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@novelnotMod3,$numbers);
			}
			elsif($. == 63)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@novelhomo,$numbers);
			}
			elsif($. == 65)
			{
				$numbers = $l;
				$numbers=~ s/\s+//;
				push(@novelhetro,$numbers);
			}
		}
		close SAMPLE;
	}
	my $avg_mapped=0;
	for (my $p = 0; $p < $num_samples;$p++) 
		{
		$percentage[$p] = sprintf("%.1f",($mappedreads[$p]/$reads[$p])*100);
		$mappedpercentage[$p] = sprintf("%.1f",($ontargetReads[$p]/$mappedreads[$p])*100);
		}
	print OUT "</tr>";
	
	print OUT "<td class=\"helpBod\">Total Number of Reads</td>";
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$reads[$p]</td>";
					}
	print OUT "</tr>";
	my $avg_mapped_reads=0;
	print OUT "<td class=\"helpBod\">Number of Mapped Reads</td>";
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$mappedreads[$p]</td>";
					$avg_mapped_reads=$avg_mapped_reads+$mappedreads[$p];
					}
	$avg_mapped_reads=$avg_mapped_reads/$num_samples;

	$avg_mapped_reads=int($avg_mapped_reads/1000000);

	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Percentage of Mapped Reads</td>";
	my $avg_per=0;
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$percentage[$p]%</td>";
					$avg_per=$avg_per+$percentage[$p];
					}
	$avg_per=$avg_per/$num_samples;$avg_per=sprintf("%.2f",$avg_per);				
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Mapped Reads on Target</td>";
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$ontargetReads[$p]</td>";
					}
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Percentage of Mapped Reads on Target</td>";
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$mappedpercentage[$p]%</td>";
					}
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Coverage at 10X</td>";
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$coverage1[$p]</td>";
					}
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Coverage at 20X</td>";
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$coverage2[$p]</td>";
					}
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Coverage at 30X</td>";
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$coverage3[$p]</td>";
					}
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Coverage at 40X</td>";
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$coverage4[$p]</td>";
					}
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Total SNVs</td>";
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$totalSNVs[$p]</td>";
					}
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Filtered SNVs</td>";
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$filteredSNVs[$p]</td>";
					}
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">On-target Filtered SNVs</td>";
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$ontargetFiltSNVs[$p]</td>";
					}
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Transition to Transversion ratio</td>";
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$overallTT[$p]</td>";
					}
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">In dbSNP130</td>";
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$indbSNP[$p]</td>";
					}
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Not in dbSNP130</td>";
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$notindbSNP[$p]</td>";
					}
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Total INDELs</td>";
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$totalINDELs[$p]</td>";
					}
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">On-target INDELs</td>";
					for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$ontargetINDELs[$p]</td>";
					}
	print OUT "</tr>";					
						
	print OUT "<td class=\"helpHed\"><p align='center'>Known Variants</td>";
				for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpHed\"></td>";
					}
	print OUT "</tr>";	
	print OUT "<td class=\"helpBod\">Total Known variants</td>";
						for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$known[$p]</td>";
					}
	print OUT "</tr>";	
	print OUT "<td class=\"helpBod\">Transition to Tranversion Ratio</td>";
						for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$knownTT[$p]</td>";
					}
	print OUT "</tr>";	
	print OUT "<td class=\"helpBod\">Nonsense</td>";
						for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$knownnonsense[$p]</td>";
					}
	print OUT "</tr>";	
	print OUT "<td class=\"helpBod\">Missense</td>";
						for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$knownmissense[$p]</td>";
					}
	print OUT "</tr>";	
	print OUT "<td class=\"helpBod\">Coding-synonymous</td>";
						for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$knowncoding[$p]</td>";
					}
	print OUT "</tr>";	
	print OUT "<td class=\"helpBod\">Coding-notMod3</td>";
						for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$knownnotMod3[$p]</td>";
					}
	print OUT "</tr>";	
	print OUT "<td class=\"helpBod\">Homozygous</td>";
						for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$knownhomo[$p]</td>";
					}
	print OUT "</tr>";	
	print OUT "<td class=\"helpBod\">Heterozygous</td>";
						for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$knownhetro[$p]</td>";
					}
	print OUT "</tr>";	
	print OUT "<td class=\"helpHed\"><p align='center'>Novel Variants</td>";
				for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpHed\"></td>";
					}
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Total Novel Variants</td>";
						for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$novel[$p]</td>";
					}
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Transition to Transversion ratio</td>";
						for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$novelTT[$p]</td>";
					}
	print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Nonsense</td>";
						for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$novelnonsense[$p]</td>";
					}
					print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Missense</td>";
						for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$novelmissense[$p]</td>";
					}
					print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Coding-synonymous</td>";
						for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$novelcoding[$p]</td>";
					}
					print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Coding-notMod3</td>";
						for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$novelnotMod3[$p]</td>";
					}
					print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Homozygous</td>";
						for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$novelhomo[$p]</td>";
					}
					print OUT "</tr>";
	print OUT "<td class=\"helpBod\">Heterozygous</td>";
						for (my $p = 0; $p < $num_samples;$p++) 
					{
					print OUT "<td class=\"helpBod\">$novelhetro[$p]</td>";
					}
					print OUT "</tr>";
	print OUT "</table><br>";
	$avg_mapped=$avg_mapped/$num_samples;$avg_mapped=int($avg_mapped/1000000);
print OUT "<p align='left'><b> Row description for Statistics Table:</p></b>\n";
 
print OUT "<table cellspacing=\"0\" class=\"sofT\"><tr><td class=\"helpHed\">Column</td>
<td class=\"helpHed\">Description</td></tr>
<td class=\"helpBod\">Total Number of Reads</td><td class=\"helpBod\">Total number of reads obtained</td></tr>
<td class=\"helpBod\">Number of Mapped Reads</td><td class=\"helpBod\">Number of reads mapped to the reference</td></tr>
<td class=\"helpBod\">Percentage of Mapped Reads</td><td class=\"helpBod\">Mapped Reads / Total number of Reads</td></tr>
<td class=\"helpBod\">Mapped Reads on Target</td><td class=\"helpBod\">Total number of reads mapping to the target region(s) defined by Agilent</td></tr>
<td class=\"helpBod\">Percentage of Mapped Reads on Target</td><td class=\"helpBod\">Mapped reads on Target / Mapped Reads</td></tr>
<td class=\"helpBod\">Total SNVs</td><td class=\"helpBod\">Total number of SNVs obtained using SNVMix</td></tr>
<td class=\"helpBod\">Filtered SNVs</td><td class=\"helpBod\">Number of SNVs obtained after applying the SNVMix filtering criteria of 0.8 on probability and selecting genotype classes 2 and 3</td></tr>
<td class=\"helpBod\">On-target Filtered SNVs</td><td class=\"helpBod\">Number of filtered SNVs found along the target region(s) defined by Agilent</td></tr>
<td class=\"helpBod\">Transition to Transversion ratio</td><td class=\"helpBod\">Number of transtitions over number of transversions. Transition is defined as a change among purines or pyrimidines (A to G, G to A, C to T, and T to C). Transversion is defined as a change from purine to pyrimidine or vice versa (A to C, A to T, G to C, G to T, C to A, C to G, T to A, and T to G)</td></tr>
<td class=\"helpBod\">In dbSNP130</td><td class=\"helpBod\">Number of SNVs found in dbSNP130 and are known</td></tr>
<td class=\"helpBod\">Not in dbSNP130</td><td class=\"helpBod\">Number of SNVs not in dbSNP130 and are novel</td></tr>
<td class=\"helpBod\">Total INDELs</td><td class=\"helpBod\">Total number of INDELs found using GATK</td></tr>
<td class=\"helpBod\">On-target INDELs</td><td class=\"helpBod\">Number of INDELs found along the target region(s) defined by Agilent</td></tr>
<td class=\"helpHed\">Known Variants</td><td class=\"helpHed\"></td></tr>
<td class=\"helpBod\">Total Known Variants</td><td class=\"helpBod\">Number of SNVs found in dbSNP130 and are known</td></tr>
<td class=\"helpBod\">Transition to Transversion ratio</td><td class=\"helpBod\">Probability of a transtition over probability of a transversion.</td></tr>
<td class=\"helpBod\">Nonsense</td><td class=\"helpBod\">Number of SNVs that lead to a stop codon</td></tr>
<td class=\"helpBod\">Missense</td><td class=\"helpBod\">Number of SNVs that lead to codons coding for different amino acids</td></tr>
<td class=\"helpBod\">Coding-synonymous</td><td class=\"helpBod\">Number of SNVs that lead to codon change without changing the amino acid</td></tr>
<td class=\"helpBod\">Coding-notMod3</td><td class=\"helpBod\">Number of SNVs that lead to codon change, but number of coding bases is not a multiple of 3</td></tr>
<td class=\"helpBod\">Homozygous</td><td class=\"helpBod\"></td></tr>
<td class=\"helpBod\">Heterozygous</td><td class=\"helpBod\">Number of SNVs where the two alleles at that position are different</td></tr>
<td class=\"helpHed\">Novel Variants</td><td class=\"helpHed\"></td></tr>
<td class=\"helpBod\">Total Novel Variants</td><td class=\"helpBod\">Number of SNVs not in dbSNP130 and are novel</td></tr>
<td class=\"helpBod\">Transition to Transversion ratio</td><td class=\"helpBod\">Probability of a transtition over probability of a transversion.</td></tr>
<td class=\"helpBod\">Nonsense</td><td class=\"helpBod\">Number of SNVs that lead to a stop codon</td></tr>
<td class=\"helpBod\">Missense</td><td class=\"helpBod\">Number of SNVs that lead to codons coding for different amino acids</td></tr>
<td class=\"helpBod\">Coding-synonymous</td><td class=\"helpBod\">Number of SNVs that lead to codon change without changing the amino acid</td></tr>
<td class=\"helpBod\">Coding-notMod3</td><td class=\"helpBod\">Number of SNVs that lead to codon change, but number of coding bases is not a multiple of 3</td></tr>
<td class=\"helpBod\">Homozygous</td><td class=\"helpBod\">Number of SNVs where the two alleles at that position are identical</td></tr>
<td class=\"helpBod\">Heterozygous</td><td class=\"helpBod\">Number of SNVs where the two alleles at that position are different</td></tr>
</table><br></ul>";


	# print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
	# print OUT "
	# <li><a name=\"Average depth of coverage of capture regions\" id=\"Average depth of coverage of capture regions\"></a> 3. Average depth of coverage of capture regions
	# <br>This is calculated by using number of reads mapping in the probe region multiplied by length of read($read_length) and divided by the length of that region<br>\n";
	# print OUT "<table cellspacing=\"0\" class=\"sofT\"><tr><td class=\"helpHed\"><p align='center'># of Probes with at least : </td><td class=\"helpHed\"><p align='center'>10X Coverage</td><td class=\"helpHed\"><p align='center'>20X Coverage</p></td><td class=\"helpHed\"><p align='center'>30X Coverage</p></td><td class=\"helpHed\"><p align='center'>40X Coverage</p></td></tr>";
	# for ($j = 0; $j < $num_samples; $j++)	{
		# my $maq_filename = $path."/results_maq/".$sampleArray[$j].".maq.out";
		# open(MAQ,"<$maq_filename");
		# @maq_stats;
		# $i =0;
		# while($l = <MAQ>)	{
			# chomp $l;
			# next unless ($. > 5);
			# $maq_stats[$i]=$l;	
			# $i++;
		# }	
		# close MAQ;
		# print OUT "<td class=\"helpBod\">$sampleArray[$j]</td><td class=\"helpBod\">$maq_stats[0]</td><td class=\"helpBod\">$maq_stats[1]</td><td class=\"helpBod\">$maq_stats[2]</td><td class=\"helpBod\">$maq_stats[3]</td></tr>";
	# }
	# print OUT "</table>";
	# print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
	 my $target=$target_region/1000000;$target=sprintf("%.1f",$target);
	 print OUT "
	 <li><a name=\"Percent coverage of target region\" id=\"Percent coverage of target region\"></a> 3. Percent coverage of target region
	 <ul>
	 The Probes target a region of $target Mbp. The table below lists the percentage of that target region which is covered by at least N depth of coverage.
	 </ul>";
	# print OUT "<table cellspacing=\"0\" class=\"sofT\"><tr><td class=\"helpHed\"><p align='center'># of Probes with at least : </td><td class=\"helpHed\"><p align='center'>5X Coverage</td><td class=\"helpHed\"><p align='center'>10X Coverage</td><td class=\"helpHed\"><p align='center'>20X Coverage</p></td><td class=\"helpHed\"><p align='center'>30X Coverage</p></td><td class=\"helpHed\"><p align='center'>40X Coverage</p></td></tr>";
	# for ($j = 0; $j < $num_samples; $j++)	{
		# $maq_filename = $path."/results_maq/".$sampleArray[$j].".coverage.maq.out";
		# open(MAQ,"<$maq_filename");
		# @maq_stats;
		# $i=0;
		# while ($l = <MAQ>)	{
			# chomp $l;
			# if ($. == 5)	{
				# $maq_stats[$i] = ($l/$target_region)*100;$maq_stats[$i]=sprintf("%.2f",$maq_stats[$i]);
				# $i++;
			# }
			# elsif( $. % 10 == 0)	{
				# $maq_stats[$i] = ($l/$target_region)*100;$maq_stats[$i]=sprintf("%.2f",$maq_stats[$i]);
				# $i++;
			# }
		# }	
		# close MAQ;
		# print OUT "<td class=\"helpBod\">$sampleArray[$j]</td><td class=\"helpBod\">$maq_stats[0]\%</td><td class=\"helpBod\">$maq_stats[1]\%</td><td class=\"helpBod\">$maq_stats[2]\%</td><td class=\"helpBod\">$maq_stats[3]\%</td><td class=\"helpBod\">$maq_stats[4]\%</td></tr>";
	# }
	# print OUT "</table>";
	 print OUT "<P ALIGN=\"CENTER\"><img border=\"0\" src=\"Coverage.JPG\" ></P> <P ALIGN=\"left\">";
	 print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
		
	print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
	print OUT "<a name=\"Results and Conclusions\" id=\"Results and Conclusions\"></a><p align='left'><u><b> VII.  Results and Conclusions:</p></u></b>";
	print OUT"
	<ul>
	<li> The observed error rate is less than 2 %. (see section V.3 - column 10 for Read1 and Read2).
	<li> $avg_per % of the data has been mapped to the genome (see section V.3 - row 3).
	<li> A high throughput with approximately $avg_mapped_reads millions passed filtering (see section V.3 - column 3).
	<li> Please note that the variants and annotation reports indicated in this main document may not be accurate since we have been observing inconsistent results with SIFT. SIFT and PolyPhen are currently under evaluation and we shall get back to you if we observe any changes with the variants and annotation results, as reported here.
	</ul>";
	
	print OUT "<b> IGV Visualization</b><br><br>
	The SNV and INDEL annotation reports (both standard and filtered) include visualization links to IGV (<a href= \"http://www.broadinstitute.org/software/igv/\"target=\"_blank\">Integrative Genomics Viewer</a>) to enable a realistic view of the variants. Please follow steps in the following link to setup IGV (takes less than 5 minutes) and utilize this feature.<br>
	<a href= \"IGV_Setup.doc\"target=\"_blank\">IGV setup for variant visualization</a><br><br>";
	
	print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
	print OUT "<a name=\"Results Delivered\" id=\"Results Delivered\"></a><p align='left'><u><b> VIII. Results Delivered</p></u></b>";
	print OUT "
	The SNP and Indel annotation reports are in the file <b>$run_num.SNV.cleaned_annot.xls</b> and <b>$run_num.INDEL.cleaned_annot.xls</b> respectively.<br>
	The files include merged SNVMix results along with SIFT and SeattleSeq SNP annotation and Indel Annotation from Seattle Seq for all samples.<br>
	<u> <a href= \"Reports/$run_num.SNV.cleaned_annot.xls\"target=\"_blank\">SNV Report</a></u> <br>	
	<u> <a href= \"Reports/$run_num.INDEL.cleaned_annot.xls\"target=\"_blank\">INDEL Report</a></u> <br><br>";
	print OUT " 
	The filtered reports, <b>$run_num.SNV.cleaned_annot_filtered.xls</b> and <b>$run_num.INDEL.cleaned_annot_filtered.xls</b> comprise of a much smaller list of variants for investigation and are based on the following criteria:
		<ul>
		- dbSNP130 column does not have an rs ID (novel), OR<br>
		- functionGVS column having 'missense', 'nonsense', 'splice-3', 'splice-5', 'coding-notMod3', 'utr-3' or 'utr-5' (intron, intergenic and coding-synonymous removed using SeattleSeq annotation - <a href= \"http://gvs.gs.washington.edu/GVS/HelpSNPSummary.jsp\"target=\"_blank\">(http://gvs.gs.washington.edu/GVS/HelpSNPSummary.jsp)</a>), OR<br>
		- any variant reported within +/-2bp of an exon edge using 'distance' report for variants
	</ul>
	<u> <a href= \"Reports/$run_num.SNV.cleaned_annot_filtered.xls\"target=\"_blank\">Filtered SNV Report</a></u> <br>
	<u> <a href= \"Reports/$run_num.INDEL.cleaned_annot_filtered.xls\"target=\"_blank\">Filtered INDEL Report</a></u> <br><br>
	
	The variant distance for SNPs and INDEls (the distance to closest Exon) are recored in two files <b>variantLocation_SNVs</b> and <b>variantLocation_INDELs</b> respectively. <br>
	<u> <a href= \"Reports/variantLocation_SNVs\"target=\"_blank\">SNV VariantDistance Report</a></u> <br>
	<u> <a href= \"Reports/variantLocation_INDELs\"target=\"_blank\">INDEL VariantDistance Report</a></u> <br><br>";
	
	print OUT "<p align='right'><a href=\"#top\">-top-</a></p>";
	print OUT "</body>\n"; 
	print OUT "</html>\n"; 
	close OUT;

	print "Document is generated with path as $output.......... \n";
}
