#!/bin/sh
#	INFO
#	merge indel report	
###############################
#		$1		=	indel folder
#		$2		=	sseq folder
#		$3		=	output dir
#		$4		=	run number
#		$5		=	run info
################################

if [ $# != 5 ]
then
	echo "Usage:<Tempreports><sseq dir><chromsome><variant file><run info>";
else	
	set -x 	
	echo `date`
	TempReports=$1
	sseq=$2
	which_chr=$3
	indel_file=$4
	run_info=$5
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)	
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )	
	GeneIdMap=$( cat $tool_info | grep -w '^GeneIdMap' | cut -d '=' -f2)
	GenomeBuild=$( cat $run_info | grep -w '^GENOMEBUILD' | cut -d '=' -f2)
	cosmic=$( cat $tool_info | grep -w '^COSMIC_INDEL_REF' | cut -d '=' -f2)
	
	touch $TempReports/$indel_file.rsIDs.forfrequencies
	cat $TempReports/$indel_file.rsIDs > $TempReports/$indel_file.rsIDs.forfrequencies
	sed -i '1d' $TempReports/$indel_file.rsIDs.forfrequencies
	cut -f 1,2,3,4,5 $TempReports/$indel_file.rsIDs.forfrequencies > $TempReports/$indel_file.rsIDs.forfrequencies.temp
	perl $script_path/add.cosmic.pl $TempReports/$indel_file.rsIDs.forfrequencies.temp 0 $cosmic $GenomeBuild 1 $TempReports/$indel_file.cosmic.txt
	rm $TempReports/$indel_file.rsIDs.forfrequencies.temp
	rm $TempReports/$indel_file.rsIDs.forfrequencies
	perl $script_path/extract.allele_freq.pl -i $TempReports/$indel_file.rsIDs -f $TempReports/$indel_file.cosmic.txt -o $TempReports/$indel_file.rsIDs.frequencies -v INDEL
	rm $TempReports/$indel_file.cosmic.txt
	chr=`awk -F '\t' '{ for(i=1;i<=NF;i++){ if ($i == "Chr") {print i} } }' $TempReports/$indel_file.rsIDs.frequencies`
	pos=`awk -F '\t' '{ for(i=1;i<=NF;i++){ if ($i == "Start") {print i} } }' $TempReports/$indel_file.rsIDs.frequencies`
	ref=`awk -F '\t' '{ for(i=1;i<=NF;i++){ if ($i == "Ref") {print i} } }' $TempReports/$indel_file.rsIDs.frequencies`
	alt=`awk -F '\t' '{ for(i=1;i<=NF;i++){ if ($i == "Alt") {print i} } }' $TempReports/$indel_file.rsIDs.frequencies`
	perl $script_path/MergeIndelReport_SSeq.pl $TempReports/$indel_file.rsIDs.frequencies $sseq/sseq.indels.out.allsamples.chr${which_chr}.merge $chr $pos $ref $alt > $TempReports/$indel_file.INDEL.report 
	rm $sseq/sseq.indels.out.allsamples.chr${which_chr}.merge
	report=$TempReports/$indel_file.INDEL.report
	perl $script_path/add_entrezID.pl -i $report -m $GeneIdMap -o $report.entrezid
	mv $report.entrezid $report
	perl $script_path/to.exclude.redundant.columns.from.report.pl $report $report.formatted
	mv $report.formatted $report	
	echo `date`
fi	