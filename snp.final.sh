#!/bin/sh

#	INFO
#	to merge snp report
########################################
#		$1		=		snv folder
#		$2		=		sift folder
#		$3		=		sseq folder
#		$4		=		chromsome
#		$5		=		variant input file
#		$6		=		run info
###########################################

if [ $# != 6 ]
then
	echo "Usage: <Tempreports dir><sift dir><sseq dir><chromosome><variant file><run info>";
else	
	set -x 
	echo `date`
	TempReports=$1 
	sift=$2 
	sseq=$3 
	which_chr=$4
	var=$5
	run_info=$6
	
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)	
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	codon_ref=$( cat $tool_info | grep -w '^CODON_REF' | cut -d '=' -f2)
	UCSC=$( cat $tool_info | grep -w '^UCSC_TRACKS' | cut -d '=' -f2 )
	bed=$( cat $tool_info | grep -w '^BEDTOOLS' | cut -d '=' -f2 )
	GeneIdMap=$( cat $tool_info | grep -w '^GeneIdMap' | cut -d '=' -f2)
	typeset -i codon
	typeset -i SNP_Type
	
	file=$TempReports/$var.rsIDs.allele_frequencies
	chr=`awk -F '\t' '{ for(i=1;i<=NF;i++){ if ($i == "Chr") {print i} } }' $file`
	pos=`awk -F '\t' '{ for(i=1;i<=NF;i++){ if ($i == "Start") {print i} } }' $file`
	ref=`awk -F '\t' '{ for(i=1;i<=NF;i++){ if ($i == "Ref") {print i} } }' $file`
	alt=`awk -F '\t' '{ for(i=1;i<=NF;i++){ if ($i == "Alt") {print i} } }' $file`
	#merge sift and report from above step
	perl $script_path/parse_siftPredictions.pl -i $TempReports/$var.rsIDs.allele_frequencies -s $sift/sift.out.allsamples.chr${which_chr}.merge -c $chr -p $pos -r $ref -a $alt -o $file.sift
	rm $sift/sift.out.allsamples.chr${which_chr}.merge
	#add codons
	touch $file.sift.forCodons
	cat $file.sift >> $file.sift.forCodons
	codon=`awk -F '\t' '{ for(i=1;i<=NF;i++){ if ($i ~ "Codons") {print i} } }' $file.sift.forCodons`
	SNP_Type=`awk -F '\t' '{ for(i=1;i<=NF;i++){ if ($i ~ "SNP Type") {print i} } }' $file.sift.forCodons`
	cat $file.sift.forCodons | cut -f ${codon},${SNP_Type} > $file.sift.forCodons.2columns
	perl $script_path/codon_pref.pl $codon_ref $file.sift.forCodons.2columns $file.sift.forCodons.2columns.added
	dos2unix $file.sift.forCodons $file.sift.forCodons.2columns.added
	paste $file.sift.forCodons $file.sift.forCodons.2columns.added > $file.sift.codons
	rm $file.sift.forCodons
	rm $file.sift.forCodons.2columns.added
	rm $file.sift.forCodons.2columns
	## add UCSC tracks
	cat $file.sift.codons | cut -f 1,2 > $file.sift.codons.ChrPos
	sed -i '1d;2d' $file.sift.codons.ChrPos
	cat $file.sift.codons.ChrPos | awk '{print $1"\t"($2-1)"\t"$2}' > $file.sift.codons.ChrPos.bed
	rm $file.sift.codons.ChrPos
	for i in conservation regulation tfbs tss enhancer
	do
		$bed/intersectBed -b $file.sift.codons.ChrPos.bed -a $UCSC/${i}.bed -wb > $file.sift.codons.ChrPos.bed.${i}
		perl $script_path/matching_ucsc_tracks.pl $file.sift.codons.ChrPos.bed $file.sift.codons.ChrPos.bed.${i} $file.sift.codons.ChrPos.bed.${i}.txt ${i} ${which_chr}
		dos2unix $file.sift.codons.ChrPos.bed.${i}.txt 
	done
	cat $file.sift.codons | sed 's/[ \t]*$//' > $file.sift.codons.forUCSCtracks
	paste $file.sift.codons.forUCSCtracks $file.sift.codons.ChrPos.bed.conservation.txt $file.sift.codons.ChrPos.bed.regulation.txt $file.sift.codons.ChrPos.bed.tfbs.txt $file.sift.codons.ChrPos.bed.tss.txt $file.sift.codons.ChrPos.bed.enhancer.txt > $file.sift.codons.UCSCtracks  
	for i in conservation regulation tfbs tss enhancer
	do
		rm $file.sift.codons.ChrPos.bed.${i}.txt
		rm $file.sift.codons.ChrPos.bed.${i}
	done
	rm $file.sift.codons.ChrPos.bed
	rm $file.sift.codons.forUCSCtracks
	rm $file.sift.codons.ChrPos
	##merge all the files sift , sseq and list.report.rsIDs , allele_frequencies to give mergedOut report 		
	perl $script_path/MergeListReport_SeattleSeq.pl -i $file.sift.codons.UCSCtracks -s $sseq/sseq.snvs.out.allsamples.chr${which_chr}.merge -c $chr -p $pos -r $ref -a $alt -o $TempReports/$var.SNV.report
	rm $sseq/sseq.snvs.out.allsamples.chr${which_chr}.merge
	##add entrez id for gene name
	report=$TempReports/$var.SNV.report
	perl $script_path/add_entrezID.pl -i $report -m $GeneIdMap -o $report.entrezid
	mv $report.entrezid $report
	##remove the redundant columns
	perl $script_path/to.exclude.redundant.columns.from.report.pl $report $report.formatted
	mv $report.formatted $report
	echo `date`
fi	
	