#!/bin/sh
##	INFO
##	script to get raw SNP calls using SNVmix AND GATK ( choose ONE in sample info file)	

######################################
#	$1		=		Sample Name
#	$2		=		Output folder of Variants  
#	$3		=		Input folder
#	$4		=		Chromosome Index
#	$5		=		run information
#########################################

if [ $# != 5 ];
then
	echo "Usage: <sample> <output variance> <realignemnt input> <which chr> <run_info>";
else	
	set -x
	echo `date`
	sample=$1
	output_variant=$2
	input=$3
	which_chr=$4
	run_info=$5
	
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	samtools=$( cat $tool_info | grep -w '^SAMTOOLS' | cut -d '=' -f2)
	snvmix=$( cat $tool_info | grep -w '^SNVmix' | cut -d '=' -f2)
	ref_path=$( cat $tool_info | grep -w '^REF_GENOME' | cut -d '=' -f2)
	gatk=$( cat $tool_info | grep -w '^GATK' | cut -d '=' -f2)
	dbSNP=$( cat $tool_info | grep -w '^dbSNP_REF' | cut -d '=' -f2)
	SNV_caller=$( cat $run_info | grep -w '^SNV_CALLER' | cut -d '=' -f2)
	java=$( cat $tool_info | grep -w '^JAVA' | cut -d '=' -f2)
	GenomeBuild=$( cat $run_info | grep -w '^GENOMEBUILD' | cut -d '=' -f2)
	
	if [ $GenomeBuild == 'hg18' ]
	then
		file="--DBSNP $dbSNP"
	else	
		file="-B:dbsnp,VCF $dbSNP"
	fi
	
	SNV=$output_variant/SNV;
	#make pileup per chromosome
	$samtools/samtools pileup -s -f $ref_path $input/chr${which_chr}.cleaned-sorted.bam > $input/chr${which_chr}.pileup
	
	if [ $SNV_caller == "SNVmix" ]
	then
		#SNVmix as a variant caller (SNVs)
		$snvmix/SNVMix2 -i $input/chr${which_chr}.pileup -f -m $snvmix/Mu_pi.txt -o $SNV/$sample.chr${which_chr}.snvs.raw.snvmix
	elif [ $SNV_caller == "GATK" ]
	then	
		#GATK as a variant caller (SNVs)
		$java/java -Xmx6g -Xms512m  \
		-jar $gatk/GenomeAnalysisTK.jar  \
		-R $ref_path  \
		-I $input/chr${which_chr}.cleaned-sorted.bam  \
		-T UnifiedGenotyper \
		$file \
		-glm SNP \
		-L chr${which_chr} \
		-o $SNV/$sample.chr${which_chr}.snps.raw.gatk.vcf \
		-debug_file $SNV/$sample.chr${which_chr}.detailed.snv.gatk.txt \
		--min_mapping_quality_score 20 \
		--min_base_quality_score 20 
	fi	
	echo `date`
fi
