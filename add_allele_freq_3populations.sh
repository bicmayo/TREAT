#!/bin/sh

if [ $# != 4 ];
then
	echo "usage ./add_3population.sh [input file with chr as 1st column and position as 2nd column, 1-based] [outout name, e.g., run70 ]"
else
	set -x
	echo `date`
	run_info=$3
	chr=$4
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2)
	hapmap=$( cat $tool_info | grep -w '^HAPMAP' | cut -d '=' -f2)
	kgenome=$( cat $tool_info | grep -w '^KGENOME' | cut -d '=' -f2)
	GenomeBuild=$( cat $run_info | grep -w '^GENOMEBUILD' | cut -d '=' -f2)
	perl $script_path/add_hapmap_1kgenome_allele_freq.pl -i $1 -c 1 -p 2 -b 1 -r $chr -e CEU -s $hapmap/all_allele_freqs_CEU.txt -g $kgenome/CEU.$GenomeBuild -o $2.CEU&&$perl $script_path/add_hapmap_1kgenome_allele_freq.pl -i $2.CEU -c 1 -r $chr -p 2 -b 1 -e YRI -s $hapmap/all_allele_freqs_YRI.txt -g $kgenome/YRI.$GenomeBuild -o $2.CEU.YRI&&perl $script_path/add_hapmap_1kgenome_allele_freq.pl -i $2.CEU.YRI -c 1 -p 2 -r $chr -b 1 -e JPT+CHB -s $hapmap/all_allele_freqs_JPT+CHB.txt -g $kgenome/JPT+CHB.$GenomeBuild -o $2.CEU.YRI.CHBJPT.txt
	echo `date`
fi