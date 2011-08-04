#!/bin/sh

########################################################
###### 	SORT BAM & REMOVE DUPLICATES SCRIPT FOR WHOLE GENOME ANALYSIS PIPELINE

######		Program:			convert.bam.sh
######		Date:				07/27/2011
######		Summary:			Using PICARD to sort and remove duplicates in bam 
######		Input files:		$1	=	/path/to/input directory
######							$2	=	name of BAM to sort
######							$3	=	sample name
######							$4	=	/path/to/run_info.txt
######		Output files:		Sorted and clean BAM
######		TWIKI:				http://bioinformatics.mayo.edu/BMI/bin/view/Main/BioinformaticsCore/Analytics/WholeGenomeWo
########################################################

if [ $# != 4 ];
then
	echo "Usage: </path/to/input directory> <name of BAM to sort> <sample name> </path/to/run_info.txt>";
else
	set -x
	echo `date`
	input=$1
	input_bam=$2
	sample=$3
	run_info=$4
	
########################################################	
######		Reading run_info.txt and assigning to variables

	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	samtools=$( cat $tool_info | grep -w '^SAMTOOLS' | cut -d '=' -f2)
	dup=$( cat $run_info | grep -w '^MARKDUP' | cut -d '=' -f2)
	dup=`echo "$dup" | tr "[a-z]" "[A-Z]"`
	picard=$( cat $tool_info | grep -w '^PICARD' | cut -d '=' -f2 ) 
	java=$( cat $tool_info | grep -w '^JAVA' | cut -d '=' -f2)
	
########################################################	
######		PICARD to sort raw BAM file

	mv $input/$input_bam $input/$sample.bam
	$java/java -Xmx6g -Xms512m \
	-jar $picard/SortSam.jar \
	INPUT=$input/$sample.bam \
	OUTPUT=$input/$sample-sorted.bam \
	SO=coordinate \
	TMP_DIR=$input/ \
	VALIDATION_STRINGENCY=SILENT
	rm $input/$sample.bam
	$samtools/samtools flagstat $input/$sample-sorted.bam > $input/$sample.flagstat
	cat $input/$sample.flagstat | grep -w mapped | cut -d ' ' -f1 > $input/$sample.mapped
	
########################################################	
######		PICARD to remove duplicates
	if [ $dup == "YES" ]
	then
		$java/java -Xmx6g -Xms512m \
		-jar $picard/MarkDuplicates.jar \
		INPUT=$input/$sample-sorted.bam \
		OUTPUT=$input/$sample-sorted.rmdup.bam \
		METRICS_FILE=$input/$sample.dup.txt \
		REMOVE_DUPLICATES=true \
		VALIDATION_STRINGENCY=SILENT \
		TMP_DIR=$input/
		mv $input/$sample-sorted.rmdup.bam $input/$sample-sorted.bam
 	fi	
	$samtools/samtools index $input/$sample-sorted.bam
	## getting the numbers for mapped reads with min quality 20
	 $samtools/samtools view -b -q 20 $input/$sample-sorted.bam > $input/$sample-sorted.q20.bam
	 $samtools/samtools index $input/$sample-sorted.q20.bam
	 $samtools/samtools flagstat $input/$sample-sorted.q20.bam > $input/$sample.q20.flagstat
	 cat $input/$sample.q20.flagstat | grep -w mapped | cut -d ' ' -f1 > $input/$sample.q20.mapped
	 rm $input/$sample-sorted.q20.bam
	 rm $input/$sample-sorted.q20.bam.bai
	echo `date`
fi