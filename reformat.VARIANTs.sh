#!/bin/sh

#	INFO
#	reformat the inputs to chop into chromsome to make it faster fro vraiant module

if [ $# -le 5 ]
then
	echo "usage: <sample><output><input><sample info><run_info><which chr><variant file>";
else	
	set -x
	echo `date`
	sample=$1
	output=$2
	input=$3
	sample_info=$4
	run_info=$5
	chr=$6
	variant=$7
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	variant_type=$( cat $run_info | grep -w '^VARIANT_TYPE' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	dbsnp_rsids_snv=$( cat $tool_info | grep -w '^dbSNP_SNV_rsIDs' | cut -d '=' -f2)
	SNV_caller=$( cat $run_info | grep -w '^SNV_CALLER' | cut -d '=' -f2)
	variant_type=`echo "$variant_type" | tr "[a-z]" "[A-Z]"`
	dbsnp_rsids_indel=$( cat $tool_info | grep -w '^dbSNP_INDEL_rsIDs' | cut -d '=' -f2)

	if [ "$8" ]
	then
		variant1=$8
		touch $output/${sample}.chr${chr}.raw.snvs
		touch $output/${sample}.chr${chr}.raw.indels
		## extract the file for the chromosome
		cat $input/$variant | grep -w chr${chr} > $output/$sample.chr${chr}.raw.snvs
		cat $input/$variant1 | grep -w chr${chr} > $output/$sample.chr${chr}.raw.indels
		touch $output/${sample}.chr${chr}.raw.snvs.temp
		if [ $SNV_caller == "SNVmix" ]
		then
			echo -e "Chr\tPosition\tRef\tAlt\tGenotypeClass\tAlt-SupportedReads\tRef-SupportedReads\tReadDepth\tProbability" >> $output/${sample}.chr${chr}.raw.snvs.temp
		else
			echo -e "Chr\tPos\tRef\tAlt" >> $output/${sample}.chr${chr}.raw.snvs.temp
		fi
		cat $output/${sample}.chr${chr}.raw.snvs >> $output/${sample}.chr${chr}.raw.snvs.temp
		perl $script_path/add_dbsnp_snv.pl -i $output/${sample}.chr${chr}.raw.snvs.temp -b 1 -s $dbsnp_rsids_snv -c 1 -p 2 -o $output/${sample}.chr${chr}.raw.snvs.rsids -r ${chr}
		sed -i '1d' $output/${sample}.chr${chr}.raw.snvs.rsids
		rm $output/${sample}.chr${chr}.raw.snvs.temp
		touch $output/$sample.chr${chr}.raw.indels.temp
		echo -e "Chr\tStart\tStop\tInfo" >> $output/$sample.chr${chr}.raw.indels.temp
		cat $output/$sample.chr${chr}.raw.indels >> $output/$sample.chr${chr}.raw.indels.temp
		perl $script_path/add_dbsnp_indel.pl -i $output/$sample.chr${chr}.raw.indels.temp -b 1 -s $dbsnp_rsids_indel -c 1 -p 2 -x 3 -o $output/$sample.chr${chr}.raw.indels.rsids -r ${chr}
		sed -i '1d' $output/$sample.chr${chr}.raw.indels.rsids 
		rm $output/$sample.chr${chr}.raw.indels.temp
	else
		if [ $variant_type == "SNV" ]
		then
			touch $output/${sample}.chr${chr}.raw.snvs
			cat $input/$variant | grep -w chr${chr} > $output/$sample.chr${chr}.raw.snvs
			touch $output/${sample}.chr${chr}.raw.snvs.temp
			if [ $SNV_caller == "SNVmix" ]
			then
				echo -e "Chr\tPosition\tRef\tAlt\tGenotypeClass\tAlt-SupportedReads\tRef-SupportedReads\tReadDepth\tProbability" >> $output/${sample}.chr${chr}.raw.snvs.temp
			else
				echo -e "Chr\tPos\tRef\tAlt" >> $output/${sample}.chr${chr}.raw.snvs.temp
			fi
			cat $output/${sample}.chr${chr}.raw.snvs >> $output/${sample}.chr${chr}.raw.snvs.temp
			perl $script_path/add_dbsnp_snv.pl -i $output/${sample}.chr${chr}.raw.snvs.temp -b 1 -s $dbsnp_rsids_snv -c 1 -p 2 -o $output/${sample}.chr${chr}.raw.snvs.rsids -r ${chr}
			sed -i '1d' $output/${sample}.chr${chr}.raw.snvs.rsids
			rm $output/${sample}.chr${chr}.raw.snvs.temp	
		elif [ $variant_type == "INDEL" ]
		then
			touch $output/${sample}.chr${chr}.raw.indels
			cat $input/$variant1 | grep -w chr${chr} > $output/$sample.chr${chr}.raw.indels
			touch $output/$sample.chr${chr}.raw.indels.temp
			echo -e "Chr\tStart\tStop\tInfo" >> $output/$sample.chr${chr}.raw.indels.temp
			cat $output/$sample.chr${chr}.raw.indels >> $output/$sample.chr${chr}.raw.indels.temp
			perl $script_path/add_dbsnp_indel.pl -i $output/$sample.chr${chr}.raw.indels.temp -b 1 -s $dbsnp_rsids_indel -c 1 -p 2 -x 3 -o $output/$sample.chr${chr}.raw.indels.rsids -r ${chr}
			sed -i '1d' $output/$sample.chr${chr}.raw.indels.rsids 
			rm $output/$sample.chr${chr}.raw.indels.temp
		fi		
	fi
	echo `date`
fi	
	
	
	
	
	
	
	
		