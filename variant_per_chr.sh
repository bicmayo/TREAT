#!/bin/sh
##	INFO
##	merge all the realign, call snvs, call indes format variants, on target to cut down the number of jobs we submit

if [ $# != 7 ]
then
	echo "Usage: <sample> <which chr> <output alignment> <output realignment> <output variant> <output On Target> <run info>";
else	
	set -x 
	echo `date`
	sample=$1
	which_chr=$2
	output_align=$3 
	output_realign=$4 
	output_variants=$5 
	output_OnTarget=$6
	run_info=$7
	## greping the file names
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	
	#realignment using chr chopped BAM
	$script_path/realign.sh $output_align/$sample/$sample-sorted.bam $output_realign/$sample $which_chr $run_info
	# call indels
	$script_path/call.indels.sh $sample $output_variants $output_realign/$sample $which_chr $run_info
	#call snvs
	$script_path/call.snvs.sh $sample $output_variants $output_realign/$sample $which_chr $run_info
	#format variants
	$script_path/format.variants.sh $sample $output_variants $which_chr $run_info
	# OnTarget SNVs 
	$script_path/OnTarget.SNV.sh $output_variants/SNV $which_chr $output_OnTarget $sample $run_info
	# OnTarget INDELs
	$script_path/OnTarget.INDEL.sh $output_variants/INDEL $which_chr $output_OnTarget $sample $run_info
	# OnTarget BAMs
	$script_path/OnTarget.BAM.sh $output_realign/$sample $which_chr $output_OnTarget $sample $run_info
	# OnTarget Pileup for Coverage plot
	$script_path/OnTarget.PILEUP.sh $output_realign/$sample $which_chr $output_OnTarget $sample $run_info
	echo `date`
fi	
		
	
	
	
	