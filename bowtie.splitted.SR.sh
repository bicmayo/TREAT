#!/bin/sh
## 	INFO
## 	script run the aliner part for SR

#################################################
#		$1			=	Read name
#		$2			=	output folder path
#		$3			=	sample name
#		$4			=	run_info file
###################################################

if [ $# != 5 ];
then
	echo "Usage: <Read><output dir><sample name>";
else	
	set -x
	echo `date`
	R=$1
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
#	ILL2SANGER=$( cat $run_info | grep -w '^ILL2SANGER' | cut -d '=' -f2 )
#	ILL2SANGER=`echo "$ILL2SANGER" | tr "[a-z]" "[A-Z]"`
	FASTQC=$( cat $run_info | grep -w '^FASTQC' | cut -d '=' -f2 )
	FASTQC=`echo "$FASTQC" | tr "[a-z]" "[A-Z]"`
	Aligner=$( cat $run_info | grep -w '^ALIGNER' | cut -d '=' -f2 )
	output_dir_sample=$output_dir/alignment/$sample
	output_fastq=$output_dir/fastq
	Aligner=`echo "$Aligner" | tr "[a-z]" "[A-Z]"`
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
		echo "nofastqc"
	fi
	# run BOWTIE
	$bowtie/bowtie -S -m 1 --quiet --best --strata --verbose $genome_bowtie $output_fastq/$R > $output_dir_sample/${R}.sam 	
	perl $script_path/add.read_group.platform.pl -i $output_dir_sample/${R}.sam -o $output_dir_sample/${R}.rg.sam -r $sample -s $sample -p $platform -c $center -l $GenomeBuild
	mv $output_dir_sample/${R}.rg.sam $output_dir_sample/${R}.sam
	$samtools/samtools view -bt $ref.fai $output_dir_sample/${R}.sam > $output_dir_sample/${R}.bam
	rm $output_dir_sample/${R}.sam
	
	echo `date`
fi	
