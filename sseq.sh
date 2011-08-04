#!/bin/sh

##	INFO
##	script used to annotate both SNVs and INDELs by submitting Auto Web submission using a JAVA script

###############################
#	$1		=		sseq output directory	
#	$2		=		sample name
#	$3		=		SNV input file
#	$4		=		INDEL file
#	$5		=		directory for input file
#	$6		=		chromosome
#	$7		=		Email
#	$8		=		run_innfo
################################# 

if [ $# != 8 ];
then
	echo "Usage:<sseq dir> <samplename> <snv file> <indel file> <input dir><email><run_info> ";
else
	set -x
	echo `date`
	sseq=$1
	sample=$2
	snv_file=$3
	indel_file=$4
	input=$5
	which_chr=$6
	email=$7
	run_info=$8
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	
	snv_input=$input
	indel_input=$input
	
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2) 
	java=$( cat $tool_info | grep -w '^JAVA' | cut -d '=' -f2)
	genome_version=$(cat $run_info | grep -w '^GENOMEBUILD' | cut -d '=' -f2)
	
	# making files in acceptable sseq online submission using batch mode
	cat $snv_input/$snv_file | cut -f 1,2,3,4 > $sseq/$snv_file.sseq
	echo "#autoFile $snv_file.sseq" > $sseq/$sample.chr${which_chr}.temp_file
	cat $sseq/$snv_file.sseq >> $sseq/$sample.chr${which_chr}.temp_file
	mv $sseq/$sample.chr${which_chr}.temp_file $sseq/$snv_file.sseq
	
	echo "#autoFile $indel_file" > $sseq/$sample.chr${which_chr}.indels.temp_file
	cat $indel_input/$indel_file >> $sseq/$sample.chr${which_chr}.indels.temp_file
	mv $sseq/$sample.chr${which_chr}.indels.temp_file $sseq/$indel_file
	
	num_snvs=`cat $sseq/$snv_file.sseq | wc -l`
	if [ $num_snvs -le 1 ]
	then
		touch $sseq/$sample.chr${which_chr}.snv.sseq
		echo -e "# inDBSNPOrNot\tchromosome\tposition\treferenceBase\tsampleGenotype\taccession\tfunctionGVS\tfunctionDBSNP\trsID\taminoAcids\tproteinPosition\tpolyPhen\tnickLab\tgeneList\tdbSNPValidation\tclinicalAssociation" >> $sseq/$sample.chr${which_chr}.snv.sseq

	else	
		$java/java -Xmx2g -Xms512m -jar $script_path/sseq_submit.jar $sseq/$snv_file.sseq $sseq/$sample.chr${which_chr}.snv.sseq snp $genome_version $email
	fi

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