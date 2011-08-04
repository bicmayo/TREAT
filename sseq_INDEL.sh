#!/bin/sh

##	INFO
##	script used to annotate both SNVs and INDELs by submitting Auto Web submission using a JAVA script

###############################
#	$1		=		sseq output directory	
#	$2		=		sample name
#	$3		=		INDEL file
#	$4		=		directory for input file
#	$5		=		chromosome
#	$6		=		Email
#	$7		=		run info
################################# 

if [ $# != 7 ];
then
	echo "Usage:<sseq dir> <samplename> <indel file> <input dir><email> <run info>";
else
	set -x
	echo `date`
	sseq=$1
	sample=$2
	indel_file=$3
	input=$4
	which_chr=$5
	email=$6
	run_info=$7
	indel_input=$input
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2) 
	java=$( cat $tool_info | grep -w '^JAVA' | cut -d '=' -f2)
	genome_version=$(cat $run_info | grep -w '^GENOMEBUILD' | cut -d '=' -f2)
	
	# making files in acceptable sseq online submission using batch mode
	echo "#autoFile $indel_file" > $sseq/$sample.chr${which_chr}.indels.temp_file
	cat $indel_input/$indel_file >> $sseq/$sample.chr${which_chr}.indels.temp_file
	mv $sseq/$sample.chr${which_chr}.indels.temp_file $sseq/$indel_file
	num_indels=`cat $sseq/$indel_file | wc -l`
	if [ $num_indels -le 1 ]
	then
		touch $sseq/$sample.chr${which_chr}.indels.sseq
		echo -e "# inDBSNPOrNot\tchromosome\tposition\treferenceBase\tsampleGenotype\taccession\tfunctionGVS\tfunctionDBSNP\trsID\taminoAcids\tproteinPosition\tpolyPhen\tnickLab\tgeneList\tdbSNPValidation\tclinicalAssociation" >> $sseq/$sample.chr${which_chr}.indels.sseq
	else	
		$java/java -Xmx2g -Xms512m -jar $script_path/sseq_submit.jar $sseq/$indel_file $sseq/$sample.chr${which_chr}.indels.sseq indel $genome_version $email
	fi	
	echo `date`
fi	