#!/bin/sh
## 	INFO
## 	script run the aliner part for SR

############################################
#			$1			=		name for read
#			$2			=		path to output folder
#			$3			=		sample name 
#			$4			=		run information file
###############################################

if [ $# != 4 ];
then
	echo "Usage: <Read><output dir><sample name><run info>";
else	
	set -x 
	echo `date`
	R=$1
	output_dir=$2
	sample=$3
	run_info=$4
	seq_file=$( cat $run_info | grep -w '^INPUT_DIR'| cut -d '=' -f2)
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	fastqc=$( cat $tool_info | grep -w '^FASTQC' | cut -d '=' -f2)
	genome_bwa=$( cat $tool_info | grep -w '^BWA_REF' | cut -d '=' -f2)
	bwa=$( cat $tool_info | grep -w '^BWA' | cut -d '=' -f2)
	samtools=$( cat $tool_info | grep -w '^SAMTOOLS' | cut -d '=' -f2)
	ref=$( cat $tool_info | grep -w '^REF_GENOME' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	center=$( cat $run_info | grep -w '^CENTER' | cut -d '=' -f2 )
	platform=$( cat $run_info | grep -w '^PLATFORM' | cut -d '=' -f2 )
	GenomeBuild=$( cat $run_info | grep -w '^GENOMEBUILD' | cut -d '=' -f2 )
	FASTQC=$( cat $run_info | grep -w '^FASTQC' | cut -d '=' -f2 )
	FASTQC=`echo "$FASTQC" | tr "[a-z]" "[A-Z]"`
	FOLDER_FASTQC=$( cat $run_info | grep -w '^FOLDER_FASTQC' | cut -d '=' -f2 )
	output_dir_sample=$output_dir/alignment/$sample
	output_fastq=$output_dir/fastq
	
	ILL2SANGER=`perl $script_path/checkFastqQualityScores.pl $seq_file/$R`
	
	if [ $ILL2SANGER == "0" ]
	then
		# convert illumina to sanger quality
		perl $script_path/ill2sanger.pl -i $seq_file/$R -o $output_fastq/$R
	else
		ln -s $seq_file/$R $output_fastq/$R
	fi
	##FASTQC
	if [ $FASTQC == "YES" ]
	then
		$fastqc/fastqc -Dfastqc.output_dir=$output_dir/fastqc/ $output_fastq/$R
	else
		ln -s $FOLDER_FASTQC $output_dir/fastqc/
	fi
	
	## run bwa using sanger qualities
	$bwa/bwa aln -l 32 -t 4  $genome_bwa $output_fastq/$R > $output_dir_sample/${R}.aln.sai
	$bwa/bwa samse -r "@RG\tID:$sample\tSM:$sample\tLB:$GenomeBuild\tPL:$platform\tCN:$center" $genome_bwa $output_dir_sample/${R}.aln.sai $output_fastq/$R > $output_dir_sample/${R}.sam 	
	rm $output_dir_sample/${R}.aln.sai
	
	$samtools/samtools view -bt $ref.fai $output_dir_sample/${R}.sam > $output_dir_sample/${R}.bam
	rm $output_dir_sample/${R}.sam
	echo `date`
fi	
