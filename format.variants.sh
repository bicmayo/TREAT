#!/bin/sh

##	INFO
## 	script is to generate the OnTarget variants (SNPs and INDELs)

############################
#	$1		=		Sample name
#	$2		=		Output Variant folder
#	$3		=		which chromosome
#	$4		=		run information
##############################


if [ $# != 4 ];
then
	echo "Usage: <sample name> <output variant folder> <which chromosome><sample_info";
else			
	set -x		
	echo `date`
	sample=$1
	output_variant=$2
	which_chr=$3
	run_info=$4
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	dbsnp_rsids_snv=$( cat $tool_info | grep -w '^dbSNP_SNV_rsIDs' | cut -d '=' -f2 )
	SNV_caller=$( cat $run_info | grep -w '^SNV_CALLER' | cut -d '=' -f2)
	SNV=$output_variant/SNV
	INDEL=$output_variant/INDEL
	## parse the SNV output from SNV caller	
	if [ $SNV_caller == "GATK" ]
	then
		perl $script_path/parse.vcf.SNV.pl -i $SNV/$sample.chr${which_chr}.snps.raw.gatk.vcf -o $SNV/$sample.chr${which_chr}.raw.snvs -s $sample
	#	touch $SNV/$sample.chr${which_chr}.raw.snvs.temp
		## add dbsnp column to raw files
	#	echo -e "Chr\tPosition\tRef\tAlt\tGenotypeClass\tAlt-SupportedReads\tRef-SupportedReads\tReadDepth\tQuality" >> $SNV/$sample.chr${which_chr}.raw.snvs.temp
	#	cat $SNV/$sample.chr${which_chr}.raw.snvs >> $SNV/$sample.chr${which_chr}.raw.snvs.temp
	#	perl $script_path/add_dbsnp_snv.pl -i $SNV/$sample.chr${which_chr}.raw.snvs.temp -b 1 -s $dbsnp_rsids_snv -c 1 -p 2 -o $SNV/$sample.chr${which_chr}.raw.snvs.rsids -r $which_chr
	#	sed -i '1d' $SNV/$sample.chr${which_chr}.raw.snvs.rsids
	#	rm $SNV/$sample.chr${which_chr}.raw.snvs.temp
	elif [ $SNV_caller == "SNVmix" ]
	then
		perl $script_path/parse.snvmix.to.snvs.pl -i $SNV/$sample.chr${which_chr}.snvs.raw.snvmix -o $SNV/$sample.chr${which_chr}.raw.snvs
	#	touch $SNV/$sample.chr${which_chr}.raw.snvs.temp
		## add dbsnp column to raw files
	#	echo -e "Chr\tPosition\tRef\tAlt\tGenotypeClass\tAlt-SupportedReads\tRef-SupportedReads\tReadDepth\tProbability" >> $SNV/$sample.chr${which_chr}.raw.snvs.temp
	#	cat $SNV/$sample.chr${which_chr}.raw.snvs >> $SNV/$sample.chr${which_chr}.raw.snvs.temp
	#	perl $script_path/add_dbsnp_snv.pl -i $SNV/$sample.chr${which_chr}.raw.snvs.temp -b 1 -s $dbsnp_rsids_snv -c 1 -p 2 -o $SNV/$sample.chr${which_chr}.raw.snvs.rsids -r $which_chr
	#	sed -i '1d' $SNV/$sample.chr${which_chr}.raw.snvs.rsids
	#	rm $SNV/$sample.chr${which_chr}.raw.snvs.temp
	fi	
	## parse the INDEL output from INDEL caller
	perl $script_path/parse.vcf.INDEL.pl -i $INDEL/$sample.chr${which_chr}.indel.gatk.vcf -o $INDEL/$sample.chr${which_chr}.raw.indels -s $sample
	echo `date`
fi	
	

