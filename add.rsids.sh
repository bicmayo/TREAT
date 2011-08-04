#!/bin/sh

##	INFO
##	to add rsids to per sample report
	
###########################
#		$1		=		TempFolder
#		$2		=		snv input file
#		$3		=		indel input file
#		$3		=		chromomse index
#		$4		=		run info
###############################

if [ $# != 5 ];
then
	echo "Usage<TempReportDir> <snv file><indel file><chromosome> <run info>";
else	
	set -x
	echo `date`
	TempReports=$1
	snv=$2
	indel=$3
	chr=$4
	run_info=$5
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2) 
	dbsnp_rsids_snv=$( cat $tool_info | grep -w '^dbSNP_SNV_rsIDs' | cut -d '=' -f2)
	dbsnp_rsids_indel=$( cat $tool_info | grep -w '^dbSNP_INDEL_rsIDs' | cut -d '=' -f2)
	GenomeBuild=$( cat $run_info | grep -w '^GENOMEBUILD' | cut -d '=' -f2)
	dbsnp_rsids_disease=$( cat $tool_info | grep -w '^dbSNP_disease_rsIDs' | cut -d '=' -f2) 
	#SNV
	touch $TempReports/$snv.forrsIDs
	cat $TempReports/$snv > $TempReports/$snv.forrsIDs
	sed -i '1d' $TempReports/$snv.forrsIDs
	perl $script_path/add_dbsnp_snv.pl -i $TempReports/$snv.forrsIDs -b 1 -s $dbsnp_rsids_snv -c 1 -p 2 -o $TempReports/$snv.forrsIDs.added -r $chr
	## add column to add flag for disease variant
	if [ $GenomeBuild == "hg19" ]
	then
		perl $script_path/add.dbsnp.disease.snv.pl -i $TempReports/$snv.forrsIDs.added -b 1 -s $dbsnp_rsids_snv -c 1 -p 2 -o $TempReports/$snv.forrsIDs.added.disease -r $chr
		# perl 
	elif [ $GenomeBuild == "hg18" ]	
	then
		perl $script_path/add.0.pl $TempReports/$snv.forrsIDs.added > $TempReports/$snv.forrsIDs.added.disease
	fi	
	perl $script_path/extract.rsids.pl -i $TempReports/$snv -r $TempReports/$snv.forrsIDs.added.disease -o $TempReports/$snv.rsIDs -v SNV
	rm $TempReports/$snv.forrsIDs.added
	rm $TempReports/$snv.forrsIDs
	rm $TempReports/$snv.forrsIDs.added.disease
	#INDEL 
	touch $TempReports/$indel.forrsIDs
	cat $TempReports/$indel > $TempReports/$indel.forrsIDs
	sed -i '1d' $TempReports/$indel.forrsIDs
	perl $script_path/add_dbsnp_indel.pl -i $TempReports/$indel.forrsIDs -b 1 -s $dbsnp_rsids_indel -c 1 -p 2 -x 3 -o $TempReports/$indel.forrsIDs.added -r $chr
	perl $script_path/add.0.pl $TempReports/$indel.forrsIDs.added > $TempReports/$indel.forrsIDs.added.disease
	perl $script_path/extract.rsids.pl -i $TempReports/$indel -r $TempReports/$indel.forrsIDs.added.disease -o $TempReports/$indel.rsIDs -v INDEL
	rm $TempReports/$indel.forrsIDs.added
	rm $TempReports/$indel.forrsIDs
	rm $TempReports/$indel.forrsIDs.added.disease
	
	echo `date`
fi	
	
	