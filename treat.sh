#!/bin/sh
## 	INFO
## 	wrapper script to do exome capture analaysis
##	contact: SaurabhBaheti
##	email: baheti.saurabh@mayo.edu
##	Last Updated: 	6/7/2011

########################### 
#		$1		=		run infomation file
###########################


if [ $# != 1 ]
then	
	echo "Usage: <run info file> ";
else
	set -x
	echo `date`	
	run_info=$1
	dos2unix $run_info
	
	### extracting the input paramters from the run info file supplied 
	### take a look at the example file before creating the run info file
	input=$( cat $run_info | grep -w '^INPUT_DIR' | cut -d '=' -f2)
	output=$( cat $run_info | grep -w '^BASE_OUTPUT_DIR' | cut -d '=' -f2)
	PI=$( cat $run_info | grep -w '^PI' | cut -d '=' -f2)
	email=$( cat $run_info | grep -w '^EMAIL' | cut -d '=' -f2)
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	sample_info=$( cat $run_info | grep -w '^SAMPLE_INFO' | cut -d '=' -f2)
	analysis=$( cat $run_info | grep -w '^ANALYSIS' | cut -d '=' -f2)
	samples=$( cat $run_info | grep -w '^SAMPLENAMES' | cut -d '=' -f2)
	tool=$( cat $run_info | grep -w '^TYPE' | cut -d '=' -f2)
	queue=$( cat $run_info | grep -w '^QUEUE' | cut -d '=' -f2)
	run_num=$( cat $run_info | grep -w '^OUTPUT_FOLDER' | cut -d '=' -f2)
	dos2unix $sample_info
	dos2unix $tool_info
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2)
	analysis=`echo "$analysis" | tr "[A-Z]" "[a-z]"`
	tool=`echo "$tool" | tr "[A-Z]" "[a-z]"`
	
	## creating and checking the file structure
	if [ -d $output/$PI ]
	then
		echo "$PI is there"
	else
		mkdir $output/$PI
	fi
	if [ -d $output/$PI/$tool ]
	then 	
		echo "analysis type already there"
	else
		mkdir $output/$PI/$tool
	fi
	if [ -d $output/$PI/$tool/$run_num ]
	then
		echo "output run folder already exist"
		exit 1;
	else 
		mkdir $output/$PI/$tool/$run_num
	fi
	
	## creating the folder structure
	mkdir $output/$PI/$tool/$run_num/logs
	output_dir=$output/$PI/$tool/$run_num
	mkdir $output/$PI/$tool/$run_num/job_ids
	job_ids_dir=$output/$PI/$tool/$run_num/job_ids
	
	# copying the tool_info, sample info and run info file to the output folder
	touch $output_dir/tool_info.txt
	cat $tool_info > $output_dir/tool_info.txt
	touch $output_dir/sample_info.txt
	cat $sample_info > $output_dir/sample_info.txt
	touch $output_dir/run_info.txt
	cat $run_info > $output_dir/run_info.txt
	cp $script_path/exome_workflow.JPG $output_dir/exome_workflow.JPG
	cp $script_path/IGV_Setup.doc $output_dir/IGV_Setup.doc
	cp $script_path/ColumnDescription_Reports.xls $output_dir/ColumnDescription_Reports.xls
	
	if [ $analysis == "mayo" ]
	then
		touch $output_dir/LTR.xls
		cat /data2/delivery/ltr_none/$run_num.xls > $output_dir/LTR.xls
	fi
	
	# parameter file
	echo -e "Stated with the ${tool} analysis for the input data for ${PI} " >> $output_dir/log.txt
	START=`date`
	echo -e "Analysis Started " >> $output_dir/log.txt
	echo -e "${START}" >>  $output_dir/log.txt
	
	## FOUR modules to the workflow starts here , this script act as a wrapper script for running each module 
	if [ $analysis == "mayo" -o $analysis == "all" ]
	then
		# part 1 do the alignment first
		echo `date`
		ALIGNMENT=`qsub -V -wd $output_dir/logs -q $queue -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/alignment.sh $output_dir $run_info`
		job_ids=`echo $ALIGNMENT | cut -d ' ' -f3`
		# part 2 variants and do realignment
		echo `date`
		VARIANT=`qsub -V -wd $output_dir/logs -q $queue -hold_jid $job_ids -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/variant.sh $output_dir $run_info`
		job_ids=`echo $VARIANT | cut -d ' ' -f3`
		#part 3 annotate the variants
		echo `date`
		ANNOTATE=`qsub -V -wd $output_dir/logs -q $queue -hold_jid $job_ids -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/annotation.sh $output_dir $run_info`
		job_ids=`echo $ANNOTATE | cut -d ' ' -f3`
		#part 4 get the numbers for the HTML page
		echo `date`
		NUMBER=`qsub -V -wd $output_dir/logs -q $queue -hold_jid $job_ids -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/numbers.sh $output_dir $run_info`
		echo `date`
	elif [ $analysis == "alignment" ]
	then
		# part 1 do the alignment first
		echo `date`
		ALIGNMENT=`qsub -V -wd $output_dir/logs -q $queue -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/alignment.sh $output_dir $run_info`
		job_ids=`echo $ALIGNMENT | cut -d ' ' -f3`
		#part 2 get the numbers for the HTML page
		echo `date`
		NUMBER=`qsub -V -wd $output_dir/logs -q $queue -hold_jid $job_ids -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/numbers.sh $output_dir $run_info`
		echo `date`
	elif [ $analysis == "variant" ]
	then
		# part 1 variants and do realignment
		echo `date`
		VARIANT=`qsub -V -wd $output_dir/logs -q $queue -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/variant.sh $output_dir $run_info`
		job_ids=`echo $VARIANT | cut -d ' ' -f3`
		#part 2 annotate the variants
		echo `date`
		ANNOTATE=`qsub -V -wd $output_dir/logs -q $queue -hold_jid $job_ids -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/annotation.sh $output_dir $run_info`
		job_ids=`echo $ANNOTATE | cut -d ' ' -f3`
		#part 3 get the numbers for the HTML page
		echo `date`
		NUMBER=`qsub -V -wd $output_dir/logs -q $queue -hold_jid $job_ids -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/numbers.sh $output_dir $run_info`
	elif [ $analysis == "annotation" ] 
	then
		#part 1 run annotation module
		echo `date`
		ANNOTATE=`qsub -V -wd $output_dir/logs -q $queue -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/annotation.sh $output_dir $run_info`
		job_ids=`echo $ANNOTATE | cut -d ' ' -f3`
		#part 2 get the numbers for the HTML page
		echo `date`
		NUMBER=`qsub -V -wd $output_dir/logs -q $queue -hold_jid $job_ids -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/numbers.sh $output_dir $run_info`
		echo `date`
	else
		echo `date`
		echo -e "\nPlease Specify the correct Analysis type(alignment,variant,annotation,all,mayo)\n"
		echo `date`
	fi	
fi
 
