use strict;
use warnings;
use Getopt::Std;
##	INFO
##	script to create IGV session for NGS visualization
our ($opt_o, $opt_s, $opt_u, $opt_a,$opt_g);
print "RAW paramters: @ARGV\n";
getopt('osuag');
if ( (!defined $opt_o) && (!defined $opt_s) && (!defined $opt_u) && (!defined $opt_a) && (!defined $opt_g)) {
	die ("Usage: $0 \n\t -o [ output folder] \n\t -s [ samples (:sperated) ] \n\t -u [ tracks (:seperated)full path ] \n\t -a [ analysis type ] \n\t -g [ genome hg18/hg19) ] \n");   
}
else {
	my $output = $opt_o;   # output folder
	my $samples = $opt_s;	# samples
	my $tracks = $opt_u;	# tracks
	my $analysis = $opt_a;	# analaysis
	my $genome = $opt_g;	# genome

	my $dest = $output . "/igv_session.xml";
	my $loc=$dest;$loc =~ s/\//\\/g;
	open FH , ">$dest" or die "can not open $dest : $! \n";
	print FH "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>
		<Global genome=\"$genome\" locus=\"All\" version=\"4\">
	    	<Resources> ";
	my @sampleNames=split(/:/,$samples);
	my @trackNames=split(/:/,$tracks);
	for(my $i = 0 ; $i <= $#sampleNames; $i++)	{
		my $loc_path=$output."/realigned_data";
		#	$loc_path =~ s/\/data2\/bsi/http:\/\/bsidev01/g;
			print FH "\n<Resource name=\"$sampleNames[$i].igv-sorted.bam\" path=\"$loc_path/$sampleNames[$i]/$sampleNames[$i].igv-sorted.bam\" />";
	}
	for (my $i = 0 ; $i <= $#trackNames ; $i++ )	{
		#$tracks =~ s/\/data2\/bsi/http:\/\/bsidev01/g;
		print FH "\n<Resource path=\"$tracks\" />
			</Resources> 
			</Global>";
	}
	
}
close FH;
