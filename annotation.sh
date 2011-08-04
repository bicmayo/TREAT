#!/bin/sh
	
##	INFO
## 	This module is used for annotating variants

########################### 
#       $1      =       OUtput directroy
#		$2		=		run information
###########################

if [ $# != 2 ];
then
	echo "Usage: <output dir> <run info>"
else	
	set -x
	echo `date`
	output_dir=$1
	run_info=$2
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)	
	sample_info=$( cat $run_info | grep -w '^SAMPLE_INFO' | cut -d '=' -f2)
	samples=$( cat $run_info | grep -w '^SAMPLENAMES' | cut -d '=' -f2)
	email=$( cat $run_info | grep -w '^EMAIL' | cut -d '=' -f2)
	analysis=$( cat $run_info | grep -w '^ANALYSIS' | cut -d '=' -f2)
	queue=$( cat $run_info | grep -w '^QUEUE' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2 )
	dbsnp_rsids=$( cat $tool_info | grep -w '^dbSNP_rsIDs' | cut -d '=' -f2 )
	java=$( cat $tool_info | grep -w '^JAVA' | cut -d '=' -f2 )
	variant_type=$( cat $run_info | grep -w '^VARIANT_TYPE' | cut -d '=' -f2)
	chrs=$( cat $run_info | grep -w '^CHRINDEX' | cut -d '=' -f2)
	analysis=`echo "$analysis" | tr "[A-Z]" "[a-z]"`
	variant_type=`echo "$variant_type" | tr "[a-z]" "[A-Z]"`
	## creating the folder structure
	mkdir $output_dir/annotation
	output_annot=$output_dir/annotation
	mkdir $output_annot/logs
	mkdir $output_annot/SIFT
	sift=$output_annot/SIFT
	mkdir $output_annot/SSEQ
	sseq=$output_annot/SSEQ
	output_OnTarget=$output_dir/OnTarget
	#extracting samples and chr
	sampleNames=$( echo $samples | tr ":" "\n" )
	chrIndexes=$( echo $chrs | tr ":" "\n" )
	i=1
	for sample in $sampleNames
	do
		sampleArray[$i]=$sample
		let i=i+1
	done
	i=1
	for chr in $chrIndexes
	do
		chrArray[$i]=$chr
		let i=i+1
	done

	if [ $analysis != "annotation" ]
	then
		job_ids=$( cat $output_dir/job_ids/VARIANTS | cut -d ' ' -f3  | tr "\n" "," )
		for i in $(seq 1 ${#sampleArray[@]})
		do
			for j in $(seq 1 ${#chrArray[@]})
			do
				snv_file=${sampleArray[$i]}.chr${chrArray[$j]}.raw.snvs.bed.i.ToMerge
				indel_file=${sampleArray[$i]}.chr${chrArray[$j]}.raw.indels.bed.i.ToMerge
				#Call sift and sseq per sample for SNVs
				qsub -V -wd $output_annot/logs -q $queue -hold_jid $job_ids -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/sift.sh $sift ${sampleArray[$i]} $snv_file $output_OnTarget ${chrArray[$j]} $run_info > $output_dir/job_ids/sift_jobs
				qsub -V -wd $output_annot/logs -q $queue -hold_jid $job_ids -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/sseq.sh $sseq ${sampleArray[$i]} $snv_file $indel_file $output_OnTarget ${chrArray[$j]} $email $run_info > $output_dir/job_ids/sseq_jobs	
				cat $output_dir/job_ids/sift_jobs $output_dir/job_ids/sseq_jobs > $output_dir/job_ids/all_annot_jobs
				job_ids=$( cat $output_dir/job_ids/all_annot_jobs | cut -d ' ' -f3  | tr "\n" "," )
			done
		done	
	#this module take care that the user wants to annotate the SNV or INDEL or BOTH
	elif [ $analysis == "annotation" ]
	then
		input=$( cat $run_info | grep -w INPUT_DIR | cut -d '=' -f2)
		mkdir $output_dir/OnTarget
		output_OnTarget=$output_dir/OnTarget
		mkdir $output_OnTarget/logs
		touch $output_dir/job_ids/all_annot_jobs
		for i in $(seq 1 ${#sampleArray[@]})
		do
			for j in $(seq 1 ${#chrArray[@]})
			do
				if [ $variant_type == "BOTH" ]
				then
					snv_file=$( cat $sample_info | grep -w SNV:${sampleArray[$i]} | cut -d '=' -f2)
					indel_file=$( cat $sample_info | grep -w INDEL:${sampleArray[$i]} | cut -d '=' -f2)
					qsub -V -wd $output_OnTarget/logs -q $queue -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/reformat.VARIANTs.sh ${sampleArray[$i]} $output_OnTarget $input $sample_info $run_info ${chrArray[$j]} $snv_file $indel_file > $output_dir/job_ids/reformat_variant_jobs
					cat $output_dir/job_ids/all_annot_jobs $output_dir/job_ids/reformat_variant_jobs > $output_dir/job_ids/reformat_all_annot_jobs
					job_ids=$( cat $output_dir/job_ids/reformat_all_annot_jobs | cut -d ' ' -f3  | tr "\n" "," )
					snv_file=${sampleArray[$i]}.chr${chrArray[$j]}.raw.snvs
					indel_file=${sampleArray[$i]}.chr${chrArray[$j]}.raw.indels
					qsub -V -wd $output_annot/logs -q $queue -hold_jid $job_ids -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/sift.sh $sift ${sampleArray[$i]} $snv_file $output_OnTarget ${chrArray[$j]} $run_info > $output_dir/job_ids/sift_jobs
					qsub -V -wd $output_annot/logs -q $queue -hold_jid $job_ids -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/sseq.sh $sseq ${sampleArray[$i]} $snv_file $indel_file $output_OnTarget ${chrArray[$j]} $email $run_info >> $output_dir/job_ids/sseq_jobs		
					cat $output_dir/job_ids/sift_jobs $output_dir/job_ids/sseq_jobs  > $output_dir/job_ids/all_annot_jobs
					job_ids=$( cat $output_dir/job_ids/all_annot_jobs | cut -d ' ' -f3  | tr "\n" "," )
				elif [ $variant_type == "SNV" ]
				then
					snv_file=$( cat $sample_info | grep -w SNV:${sampleArray[$i]} | cut -d '=' -f2)
					qsub -V -wd $output_OnTarget/logs -q $queue -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/reformat.VARIANTs.sh ${sampleArray[$i]} $output_OnTarget $input $sample_info $run_info ${chrArray[$j]} $snv_file > $output_dir/job_ids/reformat_variant_jobs
					cat $output_dir/job_ids/all_annot_jobs $output_dir/job_ids/reformat_variant_jobs > $output_dir/job_ids/reformat_all_annot_jobs
					job_ids=$( cat $output_dir/job_ids/reformat_all_annot_jobs | cut -d ' ' -f3  | tr "\n" "," )
					snv_file=${sampleArray[$i]}.chr${chrArray[$j]}.raw.snvs
					qsub -V -wd $output_annot/logs -q $queue -hold_jid $job_ids -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/sift.sh $sift ${sampleArray[$i]} $snv_file $output_OnTarget ${chrArray[$j]} $run_info > $output_dir/job_ids/sift_jobs
					qsub -V -wd $output_annot/logs -q $queue -hold_jid $job_ids -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/sseq_SNV.sh $sseq ${sampleArray[$i]} $snv_file $output_OnTarget ${chrArray[$j]} $email $run_info > $output_dir/job_ids/sseq_SNV_jobs	
					cat $output_dir/job_ids/sift_jobs $output_dir/job_ids/sseq_SNV_jobs > $output_dir/job_ids/all_annot_jobs
					job_ids=$( cat $output_dir/job_ids/all_annot_jobs | cut -d ' ' -f3  | tr "\n" "," )
				elif [ $variant_type == "INDEL" ]
				then
					indel_file=$( cat $sample_info | grep -w INDEL:${sampleArray[$i]} | cut -d '=' -f2)
					qsub -V -wd $output_OnTarget/logs -q $queue -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/reformat.VARIANTs.sh ${sampleArray[$i]} $output_OnTarget $input $sample_info $run_info ${chrArray[$j]} $indel_file > $output_dir/job_ids/reformat_variant_jobs
					cat $output_dir/job_ids/all_annot_jobs $output_dir/job_ids/reformat_variant_jobs > $output_dir/job_ids/reformat_all_annot_jobs
					job_ids=$( cat $output_dir/job_ids/reformat_all_annot_jobs | cut -d ' ' -f3  | tr "\n" "," )
					indel_file=${sampleArray[$i]}.chr${chrArray[$j]}.raw.indels
					qsub -V -wd $output_annot/logs -q $queue -hold_jid $job_ids -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/sseq_INDEL.sh $sseq ${sampleArray[$i]} $indel_file $output_OnTarget ${chrArray[$j]} $email $run_info > $output_dir/job_ids/sseq_INDEL_jobs	
					cat $output_dir/job_ids/sseq_INDEL_jobs > $output_dir/job_ids/all_annot_jobs
					job_ids=$( cat $output_dir/job_ids/all_annot_jobs | cut -d ' ' -f3  | tr "\n" "," )
				fi
			done
		done
	fi	
	## merge the sift ids
	SIFTID=`qsub -V -wd $output_annot/logs -q $queue -hold_jid $job_ids, -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/merge.siftid.sh $sift` 
	job_ids_SIFTID=`echo $SIFTID | cut -d ' ' -f3`
	## creating folder structure	
	mkdir $output_dir/TempReports
	TempReports=$output_dir/TempReports
	mkdir $TempReports/logs
	mkdir $output_dir/Reports_per_Sample
	mkdir $output_dir/VariantDatabase
	## making reports per sample
	for i in $(seq 1 ${#sampleArray[@]})
	do 
		for j in $(seq 1 ${#chrArray[@]})
		do	
			qsub -V -wd $TempReports/logs -q $queue -hold_jid $job_ids_SIFTID -m a -M $email -l h_vmem=8G -l h_stack=10M $script_path/per.sample.reports.per.chr.sh $run_info ${sampleArray[$i]} ${chrArray[$j]} $TempReports $output_OnTarget $sift $sseq $output_dir >> $output_dir/job_ids/ANNOTATION.forsamples
		done
	done	
	job_ids_per_sample=$( cat $output_dir/job_ids/ANNOTATION.forsamples | cut -d ' ' -f3  | tr "\n" "," )
	## to merge reports
	for i in $(seq 1 ${#sampleArray[@]})
	do
		qsub -V -wd $TempReports/logs -q $queue -hold_jid $job_ids_per_sample -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/merge.per.sample.report.sh $output_dir $TempReports ${sampleArray[$i]} $run_info >> $output_dir/job_ids/per.sample_merge_jobs
	done
	job_ids_per_sample_merge=$( cat $output_dir/job_ids/per.sample_merge_jobs | cut -d ' ' -f3  | tr "\n" "," )
	## annoatate all the per sample reports
	qsub -V -wd $TempReports/logs -q $queue -hold_jid $job_ids_per_sample_merge -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/annotate.per.sample.sh $output_dir $run_info >> $output_dir/job_ids/ANNOTATION 
	## file for variant database
	job_ids_ann=$( cat $output_dir/job_ids/ANNOTATION | cut -d ' ' -f3  | tr "\n" "," )
	for i in $(seq 1 ${#sampleArray[@]})
	do
		qsub -V -wd $TempReports/logs -q $queue -hold_jid $job_ids_per_sample_merge -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/variantDatabase.sh $TempReports ${sampleArray[$i]} $output_dir/VariantDatabase $run_info >> $output_dir/job_ids/ANNOTATION
	done
	## to gerneate merge reports
	if [ $analysis != "annotation" ]
	then
		mkdir $output_dir/Reports
		for i in $(seq 1 ${#chrArray[@]}) 
		do
			qsub -V -wd $TempReports/logs -q $queue -hold_jid $job_ids_SIFTID -m a -M $email -l h_vmem=8G -l h_stack=10M $script_path/reports.per.chr.sh $sift $sseq ${chrArray[$i]} $TempReports $run_info $output_dir/OnTarget >> $output_dir/job_ids/snp.final_jobs 
		done
		job_ids_final=$( cat $output_dir/job_ids/snp.final_jobs | cut -d ' ' -f3  | tr "\n" "," )
		qsub -V -wd $TempReports/logs -q $queue -hold_jid $job_ids_final -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/merge.merged.report.sh $output_dir $TempReports $run_info >> $output_dir/job_ids/ANNOTATION
		# ## add links IGV Tissue Pathways
		qsub -V -wd $TempReports/logs -q $queue -hold_jid $job_ids_final -m a -M $email -l h_vmem=4G -l h_stack=10M $script_path/variant.distance.sh $TempReports $output_dir $run_info >> $output_dir/job_ids/ANNOTATION
	fi		
	echo `date`
fi	
	
## end of annoatation module script	
	
	
		
		
			
		
	