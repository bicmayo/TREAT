#!/bin/sh
## INFO 
## script run the aliner part for PE

#################################################
#		$1			=	Read name for read1
#		$2			=	Read name for read2
#		$3			=	output folder path
#		$4			=	sample name
#		$5			=	run information file
###################################################

if [ $# != 5 ];
then
	echo "Usage: <Read1><Read2><output dir><sample name><run_info>";
else	
	set -x 
	echo `date`
	R1=$1 
	R2=$2   
	output_dir=$3
	sample=$4
	run_info=$5
	seq_file=$( cat $run_info | grep -w '^INPUT_DIR' | cut -d '=' -f2)
	email=$( cat $run_info | grep -w '^EMAIL' | cut -d '=' -f2)
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	fastqc=$( cat $tool_info | grep -w '^FASTQC' | cut -d '=' -f2)
	genome_bwa=$( cat $tool_info | grep -w '^BWA_REF' | cut -d '=' -f2)
	bwa=$( cat $tool_info | grep -w '^BWA' | cut -d '=' -f2)
	samtools=$( cat $tool_info | grep -w '^SAMTOOLS' | cut -d '=' -f2)
	ref=$( cat $tool_info | grep -w '^REF_GENOME' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	queue=$( cat $run_info | grep -w '^QUEUE' | cut -d '=' -f2)
	center=$( cat $run_info | grep -w '^CENTER' | cut -d '=' -f2 )
	platform=$( cat $run_info | grep -w '^PLATFORM' | cut -d '=' -f2 )
	GenomeBuild=$( cat $run_info | grep -w '^GENOMEBUILD' | cut -d '=' -f2 )
	FASTQC=$( cat $run_info | grep -w '^FASTQC' | cut -d '=' -f2 )
	FASTQC=`echo "$FASTQC" | tr "[a-z]" "[A-Z]"`
	FOLDER_FASTQC=$( cat $run_info | grep -w '^FOLDER_FASTQC' | cut -d '=' -f2 )
	output_dir_sample=$output_dir/alignment/$sample
	output_fastq=$output_dir/fastq
	
	ILL2SANGER1=`perl $script_path/checkFastqQualityScores.pl $seq_file/$R1`
	ILL2SANGER2=`perl $script_path/checkFastqQualityScores.pl $seq_file/$R2`
	if [ $ILL2SANGER1 == "0" ] && [ $ILL2SANGER2 == "0" ]
	then
		## convert the illumina quality values to sanger quality values
		perl $script_path/ill2sanger.pl -i $seq_file/$R1 -o $output_fastq/$R1
		perl $script_path/ill2sanger.pl -i $seq_file/$R2 -o $output_fastq/$R2
	else
		ln -s $seq_file/$R1 $output_fastq/$R1
		ln -s $seq_file/$R2 $output_fastq/$R2
	fi
	##FASTQC
	if [ $FASTQC == "YES" ]
	then
		$fastqc/fastqc -Dfastqc.output_dir=$output_dir/fastqc/ $output_fastq/$R1
		$fastqc/fastqc -Dfastqc.output_dir=$output_dir/fastqc/ $output_fastq/$R2
	else
		ln -s $FOLDER_FASTQC $output_dir/fastqc/
	fi
	## run bwa using sanger qualities
	$bwa/bwa aln -l 32 -t 4 $genome_bwa $output_fastq/$R1 > $output_dir_sample/${R1}${R2}.aln_1.sai
	$bwa/bwa aln -l 32 -t 4 $genome_bwa $output_fastq/$R2 > $output_dir_sample/${R1}${R2}.aln_2.sai
	$bwa/bwa sampe -r "@RG\tID:$sample\tSM:$sample\tLB:$GenomeBuild\tPL:$platform\tCN:$center" $genome_bwa $output_dir_sample/${R1}${R2}.aln_1.sai $output_dir_sample/${R1}${R2}.aln_2.sai $output_fastq/$R1 $output_fastq/$R2 > $output_dir_sample/${R1}${R2}.sam 	
	rm $output_dir_sample/${R1}${R2}.aln_1.sai
	rm $output_dir_sample/${R1}${R2}.aln_2.sai
	
	## convert sam to bam
	$samtools/samtools view -bt $ref.fai $output_dir_sample/${R1}${R2}.sam > $output_dir_sample/${R1}${R2}.bam
	rm $output_dir_sample/${R1}${R2}.sam
	echo `date`
fi	