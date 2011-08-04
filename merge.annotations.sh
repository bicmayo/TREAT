#!/bin/sh
#	INFO
#	script merge all the annotation per sample to be used in merged report

################################
#		$1		=		sift dir
#		$2		=		sseq dir
#		$3		=		configuration file
#		$4		=		chomosome index
#################################

if [ $# != 4 ];
then
	echo "Usage: <sift dir><sseq dir><chromosome><run info>";
else
	set -x
	echo `date`
	sift=$1 
	sseq=$2 
	which_chr=$3
	run_info=$4
	
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)	
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	
	perl $script_path/merge.sift.results.pl $sift/siftids $sift chr${which_chr} > $sift/sift.out.allsamples.chr${which_chr}.merge
	cd $sseq
	ls *.chr${which_chr}.snv.sseq > $sseq/list.chr${which_chr}.snv.sseq
	ls *.chr${which_chr}.indels.sseq > $sseq/list.chr${which_chr}.indels.sseq
	perl $script_path/merge.sseq.results.pl $sseq/list.chr${which_chr}.snv.sseq > $sseq/sseq.snvs.out.allsamples.chr${which_chr}.merge
	perl $script_path/merge.sseq.results.pl $sseq/list.chr${which_chr}.indels.sseq > $sseq/sseq.indels.out.allsamples.chr${which_chr}.merge
	rm $sseq/list.chr${which_chr}.snv.sseq
	rm $sseq/list.chr${which_chr}.indels.sseq
	echo `date`
fi	
	
	