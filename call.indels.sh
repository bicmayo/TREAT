#/bin/sh
##	INFO
## 	script to get raw INDEL calls using GATK	

######################################
#	$1		=		Sample Name
#	$2		=		Output folder of Variants 
#	$3		=		Input folder
#	$4		=		Chromosome Index
#	$5		=		run info file
#########################################


if [ $# != 5 ];
then
	echo "Usage: <sample> <output variant><input realignment><which chr><run_info>";		
else			
	set -x 
	echo `date`
	sample=$1
	output_variant=$2
	input=$3
	which_chr=$4
	run_info=$5
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	ref_path=$( cat $tool_info | grep -w '^REF_GENOME' | cut -d '=' -f2)
	dbSNP=$( cat $tool_info | grep -w '^dbSNP_REF' | cut -d '=' -f2)
	gatk=$( cat $tool_info | grep -w '^GATK' | cut -d '=' -f2)
	java=$( cat $tool_info | grep -w '^JAVA' | cut -d '=' -f2)
	GenomeBuild=$( cat $run_info | grep -w '^GENOMEBUILD' | cut -d '=' -f2)
	
	if [ $GenomeBuild == 'hg18' ]
	then
		file="--DBSNP $dbSNP"
	else	
		file="-B:dbsnp,VCF $dbSNP"
	fi
	INDEL=$output_variant/INDEL
	
	$java/java -Xmx6g -Xms512m \
	-jar $gatk/GenomeAnalysisTK.jar \
	-R $ref_path \
	-T UnifiedGenotyper \
	-glm INDEL \
	$file \
	-L chr${which_chr} \
	-I $input/chr${which_chr}.cleaned-sorted.bam \
	-o $INDEL/$sample.chr${which_chr}.indel.gatk.vcf \
	--min_mapping_quality_score 20 \
	--min_base_quality_score 20 \
	-debug_file $INDEL/$sample.chr${which_chr}.detailed.indel.gatk.txt
	
	echo `date`
fi
	
	
	
