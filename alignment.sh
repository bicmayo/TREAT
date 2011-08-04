#!/bin/sh
##	INFO
##	running bwa on the fastq files PE or SR (same script for indexed or non indexed samples as it picks the names from the 
##	sample_info file which has seperate enteries for each sample
##	contact: SaurabhBaheti
##	email: baheti.saurabh@mayo.edu
##	Last Updated: 	6/7/2011	

########################### 
#		$1		=		output directory
#		$2		=		run info 
###########################

if [ $# != 2 ]
then
	echo "\nUsage: <output_dir> <run info file>";
else
	set -x
	echo `date`
	output_run=$1
	run_info=$2
	input=$( cat $run_info | grep -w '^INPUT_DIR' | cut -d '=' -f2)
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	sample_info=$( cat $run_info | grep -w '^SAMPLE_INFO' | cut -d '=' -f2)
	samples=$( cat $run_info | grep -w '^SAMPLENAMES' | cut -d '=' -f2)
	email=$( cat $run_info | grep -w '^EMAIL' | cut -d '=' -f2)
	queue=$( cat $run_info | grep -w '^QUEUE' | cut -d '=' -f2)
	lqueue=$( cat $run_info | grep -w '^LQUEUE' | cut -d '=' -f2)
	Aligner=$( cat $run_info | grep -w '^ALIGNER' | cut -d '=' -f2 )
	paired=$( cat $run_info | grep -w '^PAIRED' | cut -d '=' -f2 )
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	samtools=$( cat $tool_info | grep -w '^SAMTOOLS' | cut -d '=' -f2)
	#convert to upper case from comparsion
	Aligner=`echo "$Aligner" | tr "[a-z]" "[A-Z]"`
	## creating the directory structure
	mkdir $output_run/alignment
	output_align=$output_run/alignment
	mkdir $output_align/logs
	mkdir $output_run/fastq
	mkdir $output_run/fastqc
	## convert : into array items
	sampleNames=$( echo $samples | tr ":" "\n" )
	i=1
	for sample in $sampleNames
	do
		sampleArray[$i]=$sample
		let i=i+1
	done
	
	for i in $(seq 1 ${#sampleArray[@]})
	do
		echo `date`
		sample=${sampleArray[$i]}
		mkdir $output_align/$sample
		output_dir_sample=$output_align/$sample
		if [ $paired -eq 1 ]
		then
			## greping the sampleID from sample info file to adjust for multiple lanes per sample case
			cat $sample_info | grep -w $sample >> $output_dir_sample/sample_file.txt
			num=`cat $output_dir_sample/sample_file.txt | wc -l`
			read1=`perl -ane '@a=split(/=/,$F[0]);print "$a[1] "' $output_dir_sample/sample_file.txt`	
			read2=`perl -ane 'print "$F[1]\t"' $output_dir_sample/sample_file.txt`
			value=`expr $num "+" 1`
			for((i=1;i<$value;i++));
			do
				R1=`echo $read1 | cut -d ' ' -f $i`
				R2=`echo $read2 | cut -d ' ' -f $i`
				if [ $Aligner == "BWA" ]
				then
					echo `date`
					qsub -V -wd $output_align/logs -q $lqueue -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/bwa.splitted.PR.sh $R1 $R2 $output_run $sample $run_info >> $output_run/job_ids/aligner_jobs_splitted	
				elif [ $Aligner == "BOWTIE" ]
				then	
					echo `date`
					qsub -V -wd $output_align/logs -q $lqueue -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/bowtie.splitted.PR.sh $R1 $R2 $output_run $sample $run_info >> $output_run/job_ids/aligner_jobs_splitted	
				fi
			done
			job_ids_align_splitted=$( cat $output_run/job_ids/aligner_jobs_splitted | cut -d ' ' -f3  | tr "\n" "," )
			if [ $value == 2 ]
			then
				echo `date`
				qsub -V -wd $output_align/logs -q $lqueue -hold_jid $job_ids_align_splitted -m a -M $email -l h_vmem=8G -l h_stack=10M $script_path/convert.bam.sh $output_dir_sample ${R1}${R2}.bam $sample $run_info >> $output_run/job_ids/ALIGNMENT
			else	
				echo `date`
				qsub -V -wd $output_align/logs -q $lqueue -hold_jid $job_ids_align_splitted -m a -M $email -l h_vmem=8G -l h_stack=10M $script_path/merge.all.aligned.bam.sh $output_dir_sample $sample $run_info >> $output_run/job_ids/ALIGNMENT
			fi	
			echo `date`
		else
			cat $sample_info | grep -w $sample >> $output_dir_sample/sample_file.txt
			num=`cat $output_dir_sample/sample_file.txt | wc -l`
			read=`perl -ane '@a=split(/=/,$F[0]);print "$a[1] "' $output_dir_sample/sample_file.txt`
			value=`expr $num "+" 1`
			for((i=1;i<$value;i++));
			do
				R=`echo $read | cut -d ' ' -f $i`
				if [ $Aligner == "BWA" ]
				then
					echo `date`
					qsub -V -wd $output_align/logs -q $lqueue -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/bwa.splitted.SR.sh $R $output_run $sample $run_info >> $output_run/job_ids/aligner_jobs_splitted	
				elif [ $Aligner == "BOWTIE" ]
				then
					echo `date`
					qsub -V -wd $output_align/logs -q $lqueue -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/bowtie.splitted.SR.sh $R $output_run $sample $run_info >> $output_run/job_ids/aligner_jobs_splitted
				fi
			done
			job_ids_align_splitted=$( cat $output_run/job_ids/aligner_jobs_splitted | cut -d ' ' -f3  | tr "\n" "," )
			if [ $value == 2 ]
			then
				echo `date`
				qsub -V -wd $output_align/logs -q $lqueue -hold_jid $job_ids_align_splitted -m a -M $email -l h_vmem=8G -l h_stack=10M $script_path/convert.bam.sh $output_dir_sample ${R}.bam $sample $run_info >> $output_run/job_ids/ALIGNMENT
			else	
				echo `date`
				qsub -V -wd $output_align/logs -q $lqueue -hold_jid $job_ids_align_splitted -m a -M $email -l h_vmem=8G -l h_stack=10M $script_path/merge.all.aligned.bam.sh $output_dir_sample $sample $run_info >> $output_run/job_ids/ALIGNMENT 
			fi	
			echo `date`
		fi
	done
fi

## 	END OF ALIGNMENT MODULE
