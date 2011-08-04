#!/bin/sh
##	 to clean intermediate files from TREAT workflow

if [ $# != 1 ]
then
	echo "Usage: <input dir full path>";
else
	set -x
	echo `date`
	input=$1
	rm -R $input/fastq
	rm -R $input/alignment
	rm -R $input/job_ids
	rm -R $input/annotation
	rm -R $input/numbers
	rm -R $input/variants/logs
	rm -R $input/TempReports
	rm -R $input/logs
	rm -R $input/OnTarget
	rm -R $input/realignment
	rm -R $input/realigned_data/logs
	rm $input/Reports/*.report
	rm $input/Reports_per_Sample/*.report
	echo `date`
fi
	
