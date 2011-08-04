#!/bin/sh
##	INFO
#	To Intersect SNV with OnTarget Kit by splitting the bam file into 200 files

######################################
#		$1		=	input folder (realignment sample folder)
#		$2		=	chromsome index
#		$3		=	Ontarget output folder
#		$4		=	sample name
#		$5		=	run_info file
#########################################

if [ $# != 5 ];
then
	echo "Usage:<input sample realignment><chromsome><output Ontarget><sample><run_info>";
else	
	set -x
	echo `date`
	input=$1
	which_chr=$2
	output=$3
	sample=$4
	run_info=$5
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	bed=$( cat $tool_info | grep -w '^BEDTOOLS' | cut -d '=' -f2 )
	OnTarget=$( cat $tool_info | grep -w '^ONTARGET' | cut -d '=' -f2 )
	dbsnp_rsids_snv=$( cat $tool_info | grep -e '^dbSNP_SNV_rsIDs' | cut -d '=' -f2 )
	CaptureKit=$( cat $tool_info | grep -w '^CAPTUREKIT' | cut -d '=' -f2 )
	snv=$sample.chr${which_chr}.raw.snvs
	#covert to bed format
	awk '{print $1"\t"$2-1"\t"$2"\t"$1"_"$2"_"$3"_"$4"_"$5"_"$6"_"$7"_"$8"_"$9}' $input/$snv > $output/$snv.bed
	#intersect with target kit
	$bed/intersectBed -b $output/$snv.bed -a $OnTarget -wb > $output/$snv.bed.i
	rm $output/$snv.bed
	#format the intersect file
	perl -an -e '@a=split(/_/,$F[$#F]);print join("\t",@a); print "\n";' $output/$snv.bed.i > $output/$snv.bed.i.tmp
	rm $output/$snv.bed.i
	# intersect to get an extra column if the call is in the target kit using for sequencing
	awk '{print $1"\t"$2-1"\t"$2"\t"$1"_"$2"_"$3"_"$4"_"$5"_"$6"_"$7"_"$8"_"$9}' $output/$snv.bed.i.tmp > $output/$snv.bed.i.tmp.bed
	rm $output/$snv.bed.i.tmp
	$bed/intersectBed -a $output/$snv.bed.i.tmp.bed -b $CaptureKit -c > $output/$snv.bed.i.tmp.bed.i
	rm $output/$snv.bed.i.tmp.bed
	perl -an -e '@a=split(/_/,$F[-2]); print join("\t",@a); print "\t$F[$#F]\n";' $output/$snv.bed.i.tmp.bed.i > $output/$snv.bed.i.ToMerge
	rm $output/$snv.bed.i.tmp.bed.i
	#add rsids to file
	touch $output/$snv.bed.i.ToMerge.forrsIDs
	echo -e "Chr\tPosition\tRef\tAlt\tGenotypeClass\tAlt-SupportedReads\tRef-SupportedReads\tReadDepth\tProbability\tInCaptureKit" >> $output/$snv.bed.i.ToMerge.forrsIDs
	cat $output/$snv.bed.i.ToMerge >> $output/$snv.bed.i.ToMerge.forrsIDs
	perl $script_path/add_dbsnp_snv.pl -i $output/$snv.bed.i.ToMerge.forrsIDs -b 1 -s $dbsnp_rsids_snv -c 1 -p 2 -o $output/$snv.bed.i.ToMerge.rsids -r $which_chr
	sed -i '1d' $output/$snv.bed.i.ToMerge.rsids
	rm $output/$snv.bed.i.ToMerge.forrsIDs
	echo `date`
fi	
	## we are keeping OnTarget files as chromosome chopped files as it will faster to merge over the samples and less memory.
	
	
