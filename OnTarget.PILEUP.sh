#!/bin/sh
##	INFO
#	To Intersect pileup with OnTarget Kit by splitting the bam file into 200 files

######################################
#		$1		=	input folder (realignment sample folder)
#		$2		=	chromsome index
#		$3		=	Ontarget output folder
#		$4		=	sample name
#		$5		=	run info file
#########################################

if [ $# != 5 ];
then
	echo "Usage:<input sample realignment><chromsome><output Ontarget><sample><run ifno>";
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
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	pileup=chr${which_chr}.pileup
	#make bed format pileup
	awk '{if ($1 ~ /chr/) {print $1"\t"$2-1"\t"$2"\t"$4"\t"$3}}' $input/$pileup > $output/$sample.$pileup.bed
	
	#split the file into 25 parts to use less memory
	total=`cat $output/$sample.$pileup.bed | wc -l`
	perl $script_path/split.a.file.into.n.parts.pl 25 $output/$sample.$pileup.bed $total
	rm $output/$sample.$pileup.bed
	a=`pwd`
	cd $output
	# intersect the pileup with the intersect kit
	for i in $sample.$pileup.bed.*.txt
	do
		$bed/intersectBed -a $CaptureKit -b $output/$i -wa -wb > $output/$i.i
		rm $output/$i	
	done
	#merge all the interscted pileup
	cat $output/$sample.$pileup.bed.*.txt.i > $output/$sample.$pileup.bed.i
	rm $output/$sample.$pileup.bed.*.txt.i
	cd $a
	echo `date`
fi	
	
	
	
	