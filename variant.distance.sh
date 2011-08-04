#!/bin/sh

if [ $# != 3 ];
then
	echo "usage:<TempReports><output_dir><run_info>";
else
	set -x
	echo `date`
	TempReports=$1
	output_dir=$2
	run_info=$3
	
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)	
	ref_flat=$( cat $tool_info | grep -w '^UCSC_REF_FLAT' | cut -d '=' -f2)
	java=$( cat $tool_info | grep -w '^JAVA' | cut -d '=' -f2 )
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	chrs=$( cat $run_info | grep -w '^CHRINDEX' | cut -d '=' -f2)
	chrIndexes=$( echo $chrs | tr ":" "\n" )
	i=1
	for chr in $chrIndexes
	do
		chrArray[$i]=$chr
		let i=i+1
	done
	
	# ## to get variant distance for snvs and indels
	for i in $(seq 1 ${#chrArray[@]})
	do 
		cat $TempReports/list.chr${chrArray[$i]}.snvs | cut -f 1,2 > $TempReports/snv.chr${chrArray[$i]}.variantLocations.txt
		$java/java -Xmx2g -Xms512m -jar $script_path/exonvariantlocation.jar $ref_flat $TempReports/snv.chr${chrArray[$i]}.variantLocations.txt snp
		cat $TempReports/list.chr${chrArray[$i]}.indels | cut -f 1,2,3 > $TempReports/indel.chr${chrArray[$i]}.variantLocations.txt
		$java/java -Xmx2g -Xms512m -jar $script_path/exonvariantlocation.jar $ref_flat $TempReports/indel.chr${chrArray[$i]}.variantLocations.txt indel
	done
	touch $output_dir/Reports/variantLocation_INDELs
	touch $output_dir/Reports/variantLocation_SNVs
	cat $TempReports/snv.chr${chrArray[1]}.variantLocations_out.txt >> $output_dir/Reports/variantLocation_SNVs
	cat $TempReports/indel.chr${chrArray[1]}.variantLocations_out.txt >> $output_dir/Reports/variantLocation_INDELs
	sed -i '1d;2d;3d;4d;5d;6d;7d;8d' $TempReports/snv.chr${chrArray[1]}.variantLocations_out.txt
	sed -i '1d;2d;3d;4d;5d;6d;7d;8d' $TempReports/indel.chr${chrArray[1]}.variantLocations_out.txt	
	for i in $(seq 2 ${#chrArray[@]})
	do
		sed -i '1d;2d;3d;4d;5d;6d;7d;8d' $TempReports/snv.chr${chrArray[$i]}.variantLocations_out.txt
		sed -i '1d;2d;3d;4d;5d;6d;7d;8d' $TempReports/indel.chr${chrArray[$i]}.variantLocations_out.txt
		cat $TempReports/snv.chr${chrArray[$i]}.variantLocations_out.txt >> $output_dir/Reports/variantLocation_SNVs
		cat $TempReports/indel.chr${chrArray[$i]}.variantLocations_out.txt >> $output_dir/Reports/variantLocation_INDELs
	done	
	echo `date`
fi	