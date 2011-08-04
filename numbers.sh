#!/bin/sh
#	INFO
#	wrapper script to get numbers per sample level

##################################################
#		$1		=		output folder
#		$2		=		run info
###################################################


if [ $# != 2 ]
then
	echo "Usage:<output run folder>	<run info>";
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
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2)
	OnTarget=$( cat $tool_info | grep -w '^ONTARGET' | cut -d '=' -f2)
	queue=$( cat $run_info | grep -w '^QUEUE' | cut -d '=' -f2)
	analysis=`echo "$analysis" | tr "[A-Z]" "[a-z]"`
	
	mkdir $output_dir/numbers
	numbers=$output_dir/numbers
	mkdir $numbers/logs
	# extract samples
	sampleNames=$( echo $samples | tr ":" "\n" )
	i=1
	for sample in $sampleNames
	do
		sampleArray[$i]=$sample
		let i=i+1
	done
	if [ $analysis == "alignment" ]
	then
		job_ids=$( cat $output_dir/job_ids/ALIGNMENT | cut -d ' ' -f3  | tr "\n" "," )
	else	
		job_ids=$( cat $output_dir/job_ids/ANNOTATION | cut -d ' ' -f3  | tr "\n" "," )
	fi	
	for i in $(seq 1 ${#sampleArray[@]})
	do
		qsub -V -wd $numbers/logs -q $queue -hold_jid $job_ids -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/sample.numbers.sh $output_dir $numbers ${sampleArray[$i]} $sample_info $analysis $run_info >> $output_dir/job_ids/NUMBERS	
	done	
	job_ids=$( cat $output_dir/job_ids/NUMBERS | cut -d ' ' -f3  | tr "\n" "," )
	
	qsub -V -wd $output_dir/logs -q $queue -hold_jid $job_ids -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/generate.html.sh $output_dir $run_info 
	
	echo `date`	
fi	
			
			
			
			
			
		
		
		
		
	