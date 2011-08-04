#!/bin/sh
##	INFO
##	For paired end run the aligment part of BWA parallely to speed up the process

################################
#		$1		=	input file
#		$2		=	output file
#		$3		=	run info file
################################


if [ $# != 3 ];
then
	echo "Usage: <input><output><run_info>";
else	
	set -x
	echo `date`
	input=$1
	output=$2
	run_info=$3
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	bwa=$( cat $tool_info | grep -w '^BWA' | cut -d '=' -f2)
	genome_bwa=$( cat $tool_info | grep -w '^BWA_REF' | cut -d '=' -f2)

	$bwa/bwa aln -l 32 -t 4 $genome_bwa $input > $output
	echo `date`
fi	

