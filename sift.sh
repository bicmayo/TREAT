#!/bin/sh

##	INFO
##	script is used to submit batch scripts to locally installed sift database

###############################
#	$1		=		sift output directory	
#	$2		=		sample name
#	$3		=		SNV input file
#	$4		=		directory for input file
#	$5		=		chromosome
#	$6		=		run_info file
#################################

if [ $# != 6 ];
then
	echo "Usage:<sift dir> <samplename> <snv file> <input dir><run info>";
else
	set -x
	echo `date` 
	sift=$1
	sample=$2
	snv_file=$3
	input=$4
	which_chr=$5
	run_info=$6
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	sift_ref=$( cat $tool_info | grep -w '^SIFT_REF' | cut -d '=' -f2) 
	sift_path=$( cat $tool_info | grep -w '^SIFT' | cut -d '=' -f2) 
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	
	num_snvs=`cat $input/$snv_file | wc -l`
	#sift acceptable format 
	if [ $num_snvs == 0 ]
	then
		touch $sift/$snv_file.sift
		mkdir $sift/${sample}_chr${which_chr}
		touch $sift/${sample}_chr${which_chr}/${sample}_chr${which_chr}_predictions.tsv
		echo -e "Coordinates\tCodons\tTranscript ID\tProtein ID\tSubstitution\tRegion\tdbSNP ID\tSNP Type\tPrediction\tScore\tMedian Info\t# Seqs at position\tGene ID\tGene Name\tOMIM Disease\tAverage Allele Freqs\tUser Comment" >> $sift/${sample}_chr${which_chr}/${sample}_chr${which_chr}_predictions.tsv
		echo "${sample}.chr${which_chr}=${sample}_chr${which_chr}" >> $sift/${sample}.ID
	else
		cat $input/$snv_file | sed -e '/chr/s///g' | awk '{print $1","$2",1,"$3"/"$4}' > $sift/$snv_file.sift
		a=`pwd`
		#running SIFT for each sample
		cd $sift_path
		perl $sift_path/SIFT_exome_nssnvs.pl -i $sift/$snv_file.sift -d $sift_ref -o $sift/ -A 1 -B 1 -J 1 -K 1 > $sift/$sample.chr${which_chr}.sift.run
		id=`perl -n -e ' /Your job id is (\d+)/ && print "$1\n" ' $sift/$sample.chr${which_chr}.sift.run`
		echo "${sample}.chr${which_chr}=$id" >> $sift/${sample}.ID
		# sift inconsistent results flips alt base by itself getting rid of wrong calls from sift output
		perl $script_path/sift.inconsistent.pl $id $sift/$snv_file.sift $sift
		mv $sift/$id/${id}_predictions.tsv_mod $sift/$id/${id}_predictions.tsv
		cd $a
	fi
	echo `date`
fi	
