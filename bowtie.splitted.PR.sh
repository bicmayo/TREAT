#!/bin/sh
## INFO 
## script run the aliner part for PE

###########################################
#			$1			=		name for read2
#			$2			=		name for read1
#			$3			=		path to output folder
#			$4			=		sample name
#			$5			=		run_info_file
###############################################

if [ $# != 5 ];
then
	echo "Usage: <Read1>>read2><output dir><sample name><run_info>";
else	
	set -x 
	echo `date`
	R1=$1 
	R2=$2 
	output_dir=$3
	sample=$4
	run_info=$5
	seq_file=$( cat $run_info | grep -w '^INPUT_DIR' | cut -d '=' -f2)
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	genome_bowtie=$( cat $tool_info | grep -w '^BOWTIE_REF' | cut -d '=' -f2)
	fastqc=$( cat $tool_info | grep -w '^FASTQC' | cut -d '=' -f2)
	bowtie=$( cat $tool_info | grep -w '^BOWTIE' | cut -d '=' -f2)
	samtools=$( cat $tool_info | grep -w '^SAMTOOLS' | cut -d '=' -f2)
	ref=$( cat $tool_info | grep -w '^REF_GENOME' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	center=$( cat $run_info | grep -w '^CENTER' | cut -d '=' -f2 )
	platform=$( cat $run_info | grep -w '^PLATFORM' | cut -d '=' -f2 )
	GenomeBuild=$( cat $run_info | grep -w '^GENOMEBUILD' | cut -d '=' -f2 )
	Aligner=$( cat $run_info | grep -w '^ALIGNER' | cut -d '=' -f2 )
#	ILL2SANGER=$( cat $run_info | grep -w '^ILL2SANGER' | cut -d '=' -f2 )
#	ILL2SANGER=`echo "$ILL2SANGER" | tr "[a-z]" "[A-Z]"`
	FASTQC=$( cat $run_info | grep -w '^FASTQC' | cut -d '=' -f2 )
	FASTQC=`echo "$FASTQC" | tr "[a-z]" "[A-Z]"`
	output_dir_sample=$output_dir/alignment/$sample
	output_fastq=$output_dir/fastq
	Aligner=`echo "$Aligner" | tr "[a-z]" "[A-Z]"`
	
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
		echo "nofastqc"
	fi
	
	## running BOWTIE
	$bowtie/bowtie -S -m 1 --quiet --best --strata --verbose $genome_bowtie -1 $output_fastq/$R1 -2 $output_fastq/$R2 > $output_dir_sample/${R1}${R2}.sam
	perl $script_path/add.read_group.platform.pl -i $output_dir_sample/${R1}${R2}.sam -o $output_dir_sample/${R1}${R2}.rg.sam -r $sample -s $sample -p $platform -c $center -l $GenomeBuild
	mv $output_dir_sample/${R1}${R2}.rg.sam $output_dir_sample/${R1}${R2}.sam
	$samtools/samtools view -bt $ref.fai $output_dir_sample/${R1}${R2}.sam > $output_dir_sample/${R1}${R2}.bam
	rm $output_dir_sample/${R1}${R2}.sam
	
	echo `date`
fi	