#!/bin/sh
##	INFO
#	To Intersect INDELS with OnTarget Kit by splitting the bam file into 200 files

######################################
#		$1		=	input folder (realignment sample folder)
#		$2		=	chromsome index
#		$3		=	Ontarget output folder
#		$4		=	sample name
#		$5		=	run info file
#########################################

if [ $# != 5 ];
then
	echo "Usage:<input sample realignment><chromsome><output Ontarget><sample><run info>";
else	
	set -x
	echo `date`
	input=$1
	which_chr=$2
	output=$3
	sample=$4
	run_info=$5
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	bed=$( cat $tool_info | grep -w '^BEDTOOLS'| cut -d '=' -f2 )
	OnTarget=$( cat $tool_info | grep -w '^ONTARGET' | cut -d '=' -f2 )
	CaptureKit=$( cat $tool_info | grep -w '^CAPTUREKIT' | cut -d '=' -f2 )
	indel=$sample.chr${which_chr}.raw.indels
	#format the indel as start=stop for INS make stop=start+1
	perl -an -e 'if($F[3] =~ /^\+/){$F[2]=$F[2]+1;print join ("\t",@F),"\n"}else { print join ("\t",@F),"\n";}' $input/$indel > $output/$indel.to.bed
	#create the bed format indel
	awk '{print $1"\t"$2"\t"$3"\t"$4}' $output/$indel.to.bed > $output/$indel.bed
	rm $output/$indel.to.bed
	# intersect with the target kit
	$bed/intersectBed -b $output/$indel.bed -a $OnTarget -wb > $output/$indel.bed.i
	rm $output/$indel.bed
	# reformat the indel file
	perl -an -e 'if($F[$#F] =~ /^\+/){$F[-2]=$F[-3];print "$F[-4]\t$F[-3]\t$F[-2]\t$F[$#F]\n";}else { print "$F[-4]\t$F[-3]\t$F[-2]\t$F[$#F]\n";}' $output/$indel.bed.i > $output/$indel.bed.i.tmp
	rm $output/$indel.bed.i
	## intersect with the capture kit so as to get a column of yes or no (0/1)
	perl -an -e 'if($F[3] =~ /^\+/){$F[2]=$F[2]+1;print join ("\t",@F),"\n"}else { print join ("\t",@F),"\n";}' $output/$indel.bed.i.tmp > $output/$indel.bed.i.tmp.to.bed
	rm $output/$indel.bed.i.tmp
	awk '{print $1"\t"$2"\t"$3"\t"$4}' $output/$indel.bed.i.tmp.to.bed > $output/$indel.bed.i.tmp.bed
	rm $output/$indel.bed.i.tmp.to.bed
	$bed/intersectBed -a $output/$indel.bed.i.tmp.bed -b $CaptureKit -c > $output/$indel.bed.i.tmp.bed.i	
	rm $output/$indel.bed.i.tmp.bed
	perl -an -e 'if($F[-2] =~ /^\+/){$F[-3]=$F[-4];print "$F[-5]\t$F[-4]\t$F[-3]\t$F[-2]\t$F[$#F]\n";}else { print "$F[-5]\t$F[-4]\t$F[-3]\t$F[-2]\t$F[$#F]\n";}' $output/$indel.bed.i.tmp.bed.i > $output/$indel.bed.i.ToMerge
	rm $output/$indel.bed.i.tmp.bed.i
	echo `date`
fi
	## we are keeping on target files as per chromomome files as it helps us save memory
	
	
			
	
	
	
	
