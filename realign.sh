#!/bin/sh
##	INFO
#	script to realign the bam files by splitting the file per chromosome and running GATK to get the realigned cleaned bam
	
######################################
#	$1		=		Location of bam files
#	$2		=		Output folder (realignment folder)
#	$3		=		Chromosome Index
#	$4		=		Run info file
#########################################
	
if [ $# != 4 ];
then
	echo "usage: <bam files path> <realigned files folder> <which chromsome> <run info file> <sample name>";
else					
	set -x
	echo `date`
	output_bwa=$1
	output=$2
	which_chr=$3 
	run_info=$4
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	samtools=$( cat $tool_info | grep -w '^SAMTOOLS' | cut -d '=' -f2)	
	ref_path=$( cat $tool_info | grep -w '^REF_GENOME' | cut -d '=' -f2)
	dbSNP=$( cat $tool_info | grep -w '^dbSNP_REF' | cut -d '=' -f2)
	gatk=$( cat $tool_info | grep -w '^GATK' | cut -d '=' -f2)
	picard=$( cat $tool_info | grep -w '^PICARD' | cut -d '=' -f2 ) 
	java=$( cat $tool_info | grep -w '^JAVA' | cut -d '=' -f2)
	GenomeBuild=$( cat $run_info | grep -w '^GENOMEBUILD' | cut -d '=' -f2)
	
	if [ $GenomeBuild == 'hg18' ]
	then
		file="--DBSNP $dbSNP"
	else	
		file="-B:dbsnp,VCF $dbSNP"
	fi
	
	echo `date`
	$samtools/samtools view -b $output_bwa chr"$which_chr" > $output/chr"$which_chr".bam
	$samtools/samtools index $output/chr"$which_chr".bam
	
	echo `date`
	## recalibration
	$java/java -Xmx6g -Xms512m -jar $gatk/GenomeAnalysisTK.jar \
	-R $ref_path \
	$file \
	-I $output/chr"$which_chr".bam \
	-L chr"$which_chr" \
	-T CountCovariates \
	-cov ReadGroupCovariate \
	-cov QualityScoreCovariate \
	-cov CycleCovariate \
	-cov DinucCovariate \
	-recalFile $output/chr"$which_chr".recal_data.csv 
	
	echo `date`
	$java/java -Xmx6g -Xms512m -jar $gatk/GenomeAnalysisTK.jar \
	-R $ref_path \
	$file \
	-L chr"$which_chr" \
	-I $output/chr"$which_chr".bam \
	-T TableRecalibration \
	--out $output/chr"$which_chr".recalibrated.bam \
	-recalFile $output/chr"$which_chr".recal_data.csv 
	
	$samtools/samtools index $output/chr"$which_chr".recalibrated.bam
	rm $output/chr"$which_chr".bam
	rm $output/chr"$which_chr".bam.bai
	rm $output/chr"$which_chr".recal_data.csv
	
	echo `date`
	##realignment
	$java/java -Xmx6g -Xms512m -jar $gatk/GenomeAnalysisTK.jar \
	-R $ref_path \
	$file \
	-L chr"$which_chr" \
	-T RealignerTargetCreator \
	-I $output/chr"$which_chr".recalibrated.bam \
	-o $output/chr"$which_chr".forRealigner.intervals
	
	echo `date`
	$java/java -Xmx6g -Xms512m -Djava.io.tmpdir=$output/temp/ \
	-jar $gatk/GenomeAnalysisTK.jar \
	-R $ref_path \
	$file \
	-L chr"$which_chr" \
	-T IndelRealigner \
	-I $output/chr"$which_chr".recalibrated.bam \
	--out $output/chr"$which_chr".cleaned.bam  \
	-targetIntervals $output/chr"$which_chr".forRealigner.intervals
	
	rm $output/chr"$which_chr".recalibrated.bam
	rm $output/chr"$which_chr".recalibrated.bam.bai
	rm $output/chr"$which_chr".forRealigner.intervals
	rm $output/chr"$which_chr".recalibrated.bai
	
	$samtools/samtools view -b -q 20 $output/chr"$which_chr".cleaned.bam > $output/chr"$which_chr".cleaned.q20.bam
	
	## to change the SO header back to coordinate sorting we are doing mate fixing (GATK recommendation ) - Samtools bug
	## fixing mate
	echo `date`
	$java/java -Xmx6g -Xms512m \
	-jar $picard/FixMateInformation.jar \
	INPUT=$output/chr"$which_chr".cleaned.q20.bam \
	OUTPUT=$output/chr"$which_chr".cleaned-sorted.bam \
	SO=coordinate \
	TMP_DIR=$output/temp/ \
	VALIDATION_STRINGENCY=SILENT
	
	rm $output/chr"$which_chr".cleaned.bam
	rm $output/chr"$which_chr".cleaned.q20.bam
	rm $output/chr"$which_chr".cleaned.bai
	$samtools/samtools index $output/chr"$which_chr".cleaned-sorted.bam
	$samtools/samtools flagstat $output/chr"$which_chr".cleaned-sorted.bam > $output/chr"$which_chr".flagstat
	cat $output/chr"$which_chr".flagstat | grep -w mapped | cut -d ' ' -f1 > $output/chr"$which_chr".mapped
	echo `date`
fi	
	
	

	
	
	
	
	