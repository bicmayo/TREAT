#!/bin/sh

if [ $# != 3 ];
then
	echo "Usage: <output_dir><TempReports><run_info>";
else
	set -x
	echo `date`
	output_dir=$1
	TempReports=$2
	run_info=$3
	
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)	
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	java=$( cat $tool_info | grep -w '^JAVA' | cut -d '=' -f2 )
	chrs=$( cat $run_info | grep -w '^CHRINDEX' | cut -d '=' -f2)
	chrIndexes=$( echo $chrs | tr ":" "\n" )
	i=1
	for chr in $chrIndexes
	do
		chrArray[$i]=$chr
		let i=i+1
	done
	
	touch $output_dir/Reports/SNV.report
	touch $output_dir/Reports/INDEL.report
	cat $TempReports/list.chr${chrArray[1]}.snvs.SNV.report >> $output_dir/Reports/SNV.report
	cat $TempReports/list.chr${chrArray[1]}.indels.INDEL.report >> $output_dir/Reports/INDEL.report
	sed -i '1d;2d' $TempReports/list.chr1.snvs.SNV.report
	sed -i '1d;2d' $TempReports/list.chr1.indels.INDEL.report
	for j in $(seq 2 ${#chrArray[@]})
	do
		sed -i '1d;2d' $TempReports/list.chr${chrArray[$j]}.snvs.SNV.report	
		sed -i '1d;2d' $TempReports/list.chr${chrArray[$j]}.indels.INDEL.report
		cat $TempReports/list.chr${chrArray[$j]}.snvs.SNV.report >> $output_dir/Reports/SNV.report
		cat $TempReports/list.chr${chrArray[$j]}.indels.INDEL.report >> $output_dir/Reports/INDEL.report
	done
	
	$java/java -Xmx2g -Xms512m -jar $script_path/exome_annot.jar annotate $tool_info $output_dir/Reports/
	
	echo `date`
fi	
