#!/bin/sh
#	INFO	
#	script generates HTML report and coverage plot graph

if [ $# != 2 ]
then
	echo "Usage: <output dir> <run info file>";
else
	set -x
	echo `date`
	output_dir=$1
	run_info=$2
	
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	PI=$( cat $run_info | grep -w '^PI' | cut -d '=' -f2)
	run_num=$( cat $run_info | grep -w '^OUTPUT_FOLDER' | cut -d '=' -f2)
	analysis=$( cat $run_info | grep -w '^ANALYSIS' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2)
	java=$( cat $tool_info | grep -w '^JAVA' | cut -d '=' -f2 )
	run_num=$( cat $run_info | grep -w '^OUTPUT_FOLDER' | cut -d '=' -f2)
	samples=$( cat $run_info | grep -w '^SAMPLENAMES' | cut -d '=' -f2)
	lanes=$( cat $run_info | grep -w '^LANEINDEX' | cut -d '=' -f2)
	tool=$( cat $run_info | grep -w '^TYPE' | cut -d '=' -f2)
	OnTarget=$( cat $tool_info | grep -w '^CAPTUREKIT' | cut -d '=' -f2)
	email=$( cat $run_info | grep -w '^EMAIL' | cut -d '=' -f2)
	GenomeBuild=$( cat $run_info | grep -w '^GENOMEBUILD' | cut -d '=' -f2)
	variant_type=$( cat $run_info | grep -w '^VARIANT_TYPE' | cut -d '=' -f2)
	UCSC=$( cat $tool_info | grep -w '^UCSC_TRACKS' | cut -d '=' -f2)
	analysis=`echo "$analysis" | tr "[A-Z]" "[a-z]"`
	upload_tb=$( cat $run_info | grep -w '^UPLOAD_TABLEBROWSER' | cut -d '=' -f2)
	upload_tb=`echo "$upload_tb" | tr "[a-z]" "[A-Z]"`
	variant_type=`echo "$variant_type" | tr "[a-z]" "[A-Z]"`
	port=$( cat $run_info | grep -w '^TABLEBROWSER_PORT' | cut -d '=' -f2)
	host=$( cat $run_info | grep -w '^TABLEBROWSER_HOST' | cut -d '=' -f2)
	# generate Coverage plot
	if [ $analysis != "annotation" -a $analysis != "alignment" ]
	then
		cd $output_dir/numbers
		region=`awk '{sum+=$3-$2+1; print sum}' $OnTarget | tail -1`
		samples_forPlot=$( echo $samples | tr ":" "\n" )
		Rscript $script_path/coverage_plot.r $region $samples_forPlot
		mv $output_dir/numbers/coverage.jpeg $output_dir/Coverage.JPG
		echo `date`
	fi	
	if [ $analysis != "annotation" -a $analysis != "alignment" ]
	then
		perl $script_path/create.igv.pl -o $output_dir -s $samples -u $UCSC/ucsc_tracks.bed -a $tool -g $GenomeBuild
	fi
	perl $script_path/MainDocument.pl -r $run_info -p $output_dir
	END=`date`
	## create tsv file for sample statistcs
	perl $script_path/SampleStatistics.pl -r $run_info -p $output_dir
	## TableBrowser upload
	if [ $upload_tb == "YES" ]
	then
		$java/java -jar $script_path/TREATUploader.jar -n $PI -u $run_num  -i $output_dir/Reports/INDEL.cleaned_annot.xls -s $output_dir/Reports/SNV.cleaned_annot.xls --port $port -h $host -r $run_num
		echo -e "Variants uploaded to TableBrowser" >> $output_dir/log.txt
	else
		echo -e "Variants Not uploaded to TableBrowser" >> $output_dir/log.txt
	fi	
	echo -e "Analysis Ends " >> $output_dir/log.txt
	echo -e "${END}" >>  $output_dir/log.txt
	TO="$email"
	SUB="TREAT workflow completion for RunID ${run_num} "
	MESG="TREAT workflow completed for ${run_num} on ${END} and ready for tertiary analysis in ${output_dir} "
	## send the completion email
	echo -e "$MESG" | mailx -v -s "$SUB" "$TO" 
	echo `date`
fi

	
	
