#!/bin/sh

##	INFO
##	to add rsids to per sample report
	
###########################
#		$1		=		TempFolder
#		$2		=		sample	
#		$3		=		chromossome
#		$4		=		run info
###############################

if [ $# != 4 ];
then
	echo "Usage<TempReportDir><variant file with rsids ><chromosome><run info> ";
else	
	set -x
	echo `date`
	TempReports=$1
	var=$2
	chr=$3
	run_info=$4
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2) 
	bgi=$( cat $tool_info | grep -w '^BGI_REF' | cut -d '=' -f2) 
	GenomeBuild=$( cat $run_info | grep -w '^GENOMEBUILD' | cut -d '=' -f2)
	cosmic=$( cat $tool_info | grep -w '^COSMIC_SNV_REF' | cut -d '=' -f2) 
	touch $TempReports/$var.forFrequencies
	cat $TempReports/$var.rsIDs > $TempReports/$var.forFrequencies
	sed -i '1d' $TempReports/$var.forFrequencies
	cat $TempReports/$var.forFrequencies |  cut -f 1,2,3,4,5 > $TempReports/$var.forFrequencies.temp
	##1KGenome and Hapmap
	$script_path/add_allele_freq_3populations.sh $TempReports/$var.forFrequencies.temp $TempReports/$var.forFrequencies.allele.frequency $run_info $chr
	## BGI
	perl $script_path/add_bgi_freq.pl -i $TempReports/$var.forFrequencies.allele.frequency.CEU.YRI.CHBJPT.txt -r $bgi -c $chr -o $TempReports/$var.forFrequencies.allele.frequency.CEU.YRI.CHBJPT.BGI.txt
	## Cosmic
	perl $script_path/add.cosmic.pl $TempReports/$var.forFrequencies.allele.frequency.CEU.YRI.CHBJPT.BGI.txt 1 $cosmic $GenomeBuild 1 $TempReports/$var.forFrequencies.allele.frequency.CEU.YRI.CHBJPT.BGI.Cosmic.txt
	## arrange the columns
	perl $script_path/extract.allele_freq.pl -i $TempReports/$var.rsIDs -f $TempReports/$var.forFrequencies.allele.frequency.CEU.YRI.CHBJPT.BGI.Cosmic.txt -o $TempReports/$var.rsIDs.allele_frequencies -v SNV
	rm $TempReports/$var.forFrequencies.allele.frequency.CEU.YRI.CHBJPT.BGI.Cosmic.txt
	rm $TempReports/$var.forFrequencies.allele.frequency.CEU.YRI.CHBJPT.BGI.txt
	rm $TempReports/$var.forFrequencies.allele.frequency.CEU.YRI.CHBJPT.txt
	rm $TempReports/$var.forFrequencies.allele.frequency.CEU.YRI
	rm $TempReports/$var.forFrequencies.allele.frequency.CEU
	rm $TempReports/$var.forFrequencies
	rm $TempReports/$var.forFrequencies.temp
	echo `date`
fi	