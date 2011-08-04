#!/bin/sh

#	INFO
#	the script generate a merged report per sample includes sift and sseq annotation (getting rid of redundant columns )

########################################
#		$1		=	Temp Reports folder
#		$2		=	sample name
#		$3		=	chromosome
#		$4		=	sseq directory
#		$5		=	sift directory
#		$6		=	variant file
#		$7		=	run info
############################################
		
if [ $# != 7 ];
then
	echo "Usage:<Tempreports><sample name><chromosome><sseq dir><sift dir><variant file><run info>";
else	
	set -x
	echo `date`
	TempReports=$1
	sample=$2 
	which_chr=$3
	sift=$4 
	sseq=$5
	var=$6	
	run_info=$7
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2)
	codon_ref=$( cat $tool_info | grep -w '^CODON_REF' | cut -d '=' -f2)
	GeneIdMap=$( cat $tool_info | grep -w '^GeneIdMap' | cut -d '=' -f2)
	UCSC=$( cat $tool_info | grep -w '^UCSC_TRACKS' | cut -d '=' -f2 )
	bed=$( cat $tool_info | grep -w '^BEDTOOLS' | cut -d '=' -f2 )
	sift_id=`grep -w $sample.chr${which_chr} $sift/siftids | awk -F "=" '{print $NF}'`
	typeset -i codon
	typeset -i SNP_Type
	
	file=$TempReports/$var.rsIDs.allele_frequencies
	chr=`awk -F '\t' '{ for(i=1;i<=NF;i++){ if ($i == "Chr") {print i} } }' $file`
	pos=`awk -F '\t' '{ for(i=1;i<=NF;i++){ if ($i == "Position") {print i} } }' $file`
	ref=`awk -F '\t' '{ for(i=1;i<=NF;i++){ if ($i == "Ref") {print i} } }' $file`
	alt=`awk -F '\t' '{ for(i=1;i<=NF;i++){ if ($i == "Alt") {print i} } }' $file`
	perl $script_path/parse_siftPredictions.pl -i $file -s $sift/$sift_id/${sift_id}_predictions.tsv -c $chr -p $pos -r $ref -a $alt -o $file.sift
	##  add codon preference
	touch $file.sift.forCodons
	cat $file.sift >> $file.sift.forCodons
	codon=`awk -F '\t' '{ for(i=1;i<=NF;i++){ if ($i ~ "Codons") {print i} } }' $file.sift.forCodons`
	SNP_Type=`awk -F '\t' '{ for(i=1;i<=NF;i++){ if ($i ~ "SNP Type") {print i} } }' $file.sift.forCodons`
	cat $file.sift.forCodons | cut -f ${codon},${SNP_Type} > $file.sift.forCodons.2columns
	perl $script_path/codon_pref.pl $codon_ref $file.sift.forCodons.2columns $file.sift.forCodons.2columns.added
	dos2unix $file.sift.forCodons $file.sift.forCodons.2columns.added
#	cat $file.sift.forCodons | sed 's/[ \t]*$//' > $file.sift.forCodons.tmp
#	rm $file.sift.forCodons
	paste $file.sift.forCodons $file.sift.forCodons.2columns.added > $file.sift.codons
	rm $file.sift.forCodons
	rm $file.sift.forCodons.2columns.added
	rm $file.sift.forCodons.2columns
	### add ucsc tracks
	cat $file.sift.codons | cut -f 1,2 > $file.sift.codons.ChrPos
	sed -i '1d;2d' $file.sift.codons.ChrPos
	cat $file.sift.codons.ChrPos | awk '{print $1"\t"($2-1)"\t"$2}' > $file.sift.codons.ChrPos.bed
	rm $file.sift.codons.ChrPos
	for i in conservation regulation tfbs tss enhancer
	do
		$bed/intersectBed -b $file.sift.codons.ChrPos.bed -a $UCSC/${i}.bed -wb > $file.sift.codons.ChrPos.bed.${i}
		perl $script_path/matching_ucsc_tracks.pl $file.sift.codons.ChrPos.bed $file.sift.codons.ChrPos.bed.${i} $file.sift.codons.ChrPos.bed.${i}.txt ${i} $chr
		dos2unix $file.sift.codons.ChrPos.bed.${i}.txt 
	done
	cat $file.sift.codons | sed 's/[ \t]*$//' > $file.sift.codons.forUCSCtracks
	paste $file.sift.codons.forUCSCtracks $file.sift.codons.ChrPos.bed.conservation.txt $file.sift.codons.ChrPos.bed.regulation.txt $file.sift.codons.ChrPos.bed.tfbs.txt $file.sift.codons.ChrPos.bed.tss.txt $file.sift.codons.ChrPos.bed.enhancer.txt > $file.sift.codons.UCSCtracks  
	rm $file.sift.codons.forUCSCtracks 
	for i in conservation regulation tfbs tss enhancer
	do
		rm $file.sift.codons.ChrPos.bed.${i}.txt
		rm $file.sift.codons.ChrPos.bed.${i}
	done
	rm $file.sift.codons.ChrPos.bed
	### add sseq annnoattion to the report
	perl $script_path/MergeListReport_SeattleSeq.pl -i $file.sift.codons.UCSCtracks -s $sseq/$sample.chr${which_chr}.snv.sseq -c $chr -p $pos -r $ref -a $alt -o $TempReports/$sample.chr${which_chr}.SNV.report
	### add the entrez id to the report
	report=$TempReports/$sample.chr${which_chr}.SNV.report
	perl $script_path/add_entrezID.pl -i $report -m $GeneIdMap -o $report.entrezid
	mv $report.entrezid $report
	## exclude the redundant columns from the report
	perl $script_path/to.exclude.redundant.columns.from.report.pl $report $report.formatted
	mv $report.formatted $report
	echo `date`	
fi