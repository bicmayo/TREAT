#!/bin/sh
##	INFO
##	to merge the scripts to call in one script to control sapnning jobs
if [ $# != 8 ]
then
	echo "Usage: <run info> <sample> <which chr> <Temp reports> <Output OnTarget> <sift> <sseq> <output dir>";
else
	set -x
	echo `date`			
	run_info=$1 
	sample=$2
	which_chr=$3 
	TempReports=$4 
	output_OnTarget=$5 
	sift=$6 
	sseq=$7 
	output_dir=$8 
	
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	variant_type=$( cat $run_info | grep -w '^VARIANT_TYPE' | cut -d '=' -f2)
	analysis=$( cat $run_info | grep -w '^ANALYSIS' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	email=$( cat $run_info | grep -w '^EMAIL' | cut -d '=' -f2)
	analysis=`echo "$analysis" | tr "[A-Z]" "[a-z]"`
	variant_type=`echo "$variant_type" | tr "[a-z]" "[A-Z]"`
	
	## indel file format
	if [ $analysis == "all" -o $analysis == "variant" ]
	then
		indel_file=${sample}.chr${which_chr}.raw.indels.bed.i.ToMerge
	elif [ $analysis == "annotation" -o $variant_type == "BOTH" -o $variant_type = "INDEL" ]
	then
		indel_file=${sample}.chr${which_chr}.raw.indels
	fi	
	## prepocessing the input file from variant module or user added 
	$script_path/preprocess.persample.sh $sample $sift $sseq $TempReports $run_info $output_OnTarget $which_chr
	if [ $variant_type == "BOTH" -o $variant_type == "SNV" ]
	then
		snv_var=${sample}.chr${which_chr}.snv
		indel_var=${sample}.chr${which_chr}.indel
		## add rsids
		$script_path/add.rsids.sh $TempReports $snv_var $indel_var $which_chr $run_info
		## add allele frequency
		$script_path/add.frequencies.sh $TempReports $snv_var $which_chr $run_info
		## merge sift sseq codon UCSC tracks
		$script_path/merge.snv.sh $TempReports $sample $which_chr $sift $sseq $snv_var $run_info
	fi
	if [ $variant_type == "BOTH" -o $variant_type = "INDEL" ]
	then	
		indel_var=${sample}.chr${which_chr}.indel
		## merge sseq to indel report
		$script_path/merge.indel.sh $TempReports $sample $which_chr $sseq $indel_var $output_OnTarget $run_info	
	fi
	echo `date`
fi	
	



		