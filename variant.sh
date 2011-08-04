#!/bin/sh
##	INFO
##	wrap up script to do realignment first and then call variants using Variant Calling tools and Intersecting with OnTarget (optional)
##	Capture Kits to get variant on Target	
## 	this step includes realignment AND variant calling : indel by GATK and SNV by SNVMix

########################### 
#       $1      =       Output directroy
#		$2		=		run information
###########################

if [ $# != 2 ];
then
	echo "Usage: <output dir> <run info>"
else	
	set -x
	echo `date`
	output_dir=$1
	run_info=$2
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	sample_info=$( cat $run_info | grep -w '^SAMPLE_INFO' | cut -d '=' -f2)
	samples=$( cat $run_info | grep -w '^SAMPLENAMES' | cut -d '=' -f2)
	email=$( cat $run_info | grep -w '^EMAIL' | cut -d '=' -f2)
	analysis=$( cat $run_info | grep -w '^ANALYSIS' | cut -d '=' -f2)
	queue=$( cat $run_info | grep -w '^QUEUE' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	lqueue=$( cat $run_info | grep -w '^LQUEUE' | cut -d '=' -f2)
	chrs=$( cat $run_info | grep -w '^CHRINDEX' | cut -d '=' -f2)
	analysis=`echo "$analysis" | tr "[A-Z]" "[a-z]"`
	#creating folder structure
	mkdir $output_dir/realignment
	output_realign=$output_dir/realignment
	mkdir $output_dir/variants
	output_variants=$output_dir/variants
	mkdir $output_variants/logs
	mkdir $output_dir/realigned_data
	output_realign_data=$output_dir/realigned_data
	mkdir $output_realign_data/logs
	mkdir $output_variants/INDEL
	mkdir $output_variants/SNV
	mkdir $output_dir/OnTarget
	output_OnTarget=$output_dir/OnTarget
	
	#extracting samples and chr
	sampleNames=$( echo $samples | tr ":" "\n" )
	chrIndexes=$( echo $chrs | tr ":" "\n" )
	i=1
	for sample in $sampleNames
	do
		sampleArray[$i]=$sample
		let i=i+1
	done
	i=1
	for chr in $chrIndexes
	do
		chrArray[$i]=$chr
		let i=i+1
	done
	
	if [ $analysis == "variant" ]
	then
		echo `date`
		input=$( cat $run_info | grep -w INPUT_DIR | cut -d '=' -f2)
		mkdir $output_dir/alignment
		output_align=$output_dir/alignment
		mkdir $output_align/logs
		for i in $(seq 1 ${#sampleArray[@]})
		do
			mkdir $output_align/${sampleArray[$i]}
			bam=$( cat $sample_info | grep -w ${sampleArray[$i]} | cut -d '=' -f2)
			## reformating the BAMs to make sure it has all the information to process further
			qsub -V -wd $output_align/logs -q $lqueue -m a -M $email -l h_vmem=8G -l h_stack=10M $script_path/reformat.BAMs.sh ${sampleArray[$i]} $output_align $bam $run_info >> $output_dir/job_ids/reformat_bams_jobs
		done
		job_ids=$( cat $output_dir/job_ids/reformat_bams_jobs | cut -d ' ' -f3  | tr "\n" "," )
	else	
		output_align=$output_dir/alignment
		job_ids=$( cat $output_dir/job_ids/ALIGNMENT | cut -d ' ' -f3  | tr "\n" "," )
	fi
	
	## running the wrapper script for variant module to reduce the numbe of jobs spanning on the cluster
	for i in $(seq 1 ${#sampleArray[@]})
	do
		mkdir $output_realign/${sampleArray[$i]}
		mkdir $output_realign/${sampleArray[$i]}/temp
		for j in $(seq 1 ${#chrArray[@]})
		do
			qsub -V -wd $output_variants/logs -q $lqueue -hold_jid $job_ids -m a -M $email -l h_vmem=8G -l h_stack=10M $script_path/variant_per_chr.sh ${sampleArray[$i]} ${chrArray[$j]} $output_align $output_realign $output_variants $output_OnTarget $run_info >> $output_dir/job_ids/VARIANTS
		done
	done	
	
	job_ids=$(cat $output_dir/job_ids/VARIANTS | cut -d ' ' -f3  | tr "\n" "," )
	#Merge the realigned bam file and index it for IGV session
	for i in $(seq 1 ${#sampleArray[@]})
	do
		mkdir $output_realign_data/${sampleArray[$i]}
		qsub -V -wd $output_realign_data/logs -q $lqueue -hold_jid $job_ids -m a -M $email -l h_vmem=8G -l h_stack=10M $script_path/merge.bam.igv.sh $output_dir $output_realign ${sampleArray[$i]} $run_info >> $output_dir/job_ids/IGV
	done

	echo `date`
fi	


#### END OF VARIANT MODULE	
	
	

	
