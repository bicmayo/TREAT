#!/bin/sh
##	INFO
#	To Intersect bam with OnTarget Kit by splitting the bam file into 200 files

######################################
#		$1		=	input folder (realignment sample folder)
#		$2		=	chromsome index
#		$3		=	Ontarget output folder
#		$4		=	sample name
#		$5		=	run info file
#########################################

if [ $# != 5 ];
then
	echo "Usage : <input sample realignment><chromsome><output Ontarget><sample><run info>";
else	
	set -x
	echo `date`
	input=$1
	which_chr=$2
	output=$3
	sample=$4
	run_info=$5
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	bed=$( cat $tool_info | grep -w '^BEDTOOLS' | cut -d '=' -f2 )
	CaptureKit=$( cat $tool_info | grep -w '^CAPTUREKIT' | cut -d '=' -f2 )
	samtools=$( cat $tool_info | grep -w '^SAMTOOLS' | cut -d '=' -f2)

	bam=chr${which_chr}.cleaned-sorted.bam
	#intersect with the target kit
	$bed/intersectBed -abam $input/$bam -b $CaptureKit | $samtools/samtools view - > $output/$sample.$bam.i
	echo `date`
fi	
	
### END OF SCRIPT	