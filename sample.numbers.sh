#!/bin/sh
#	INFO	
#	to get numbers for HTML report for all the modules

###############################################
#		$1		=		Output dir run folder
#		$3		=		number folder
#		$4		=		sample name
#		$5		=		sample info
#		$6		=		analysis type
#		$7		=		run info
###################################################

if [ $# != 6 ];
then
	echo "Usage: <outputdir><number fodler><sample><sample info><analysis><run info>";
else
	set -x 
	echo `date`
	output=$1  
	numbers=$2
	sample=$3
	sample_info=$4
	analysis=$5
	run_info=$6
	tool_info=$( cat $run_info | grep -w '^TOOL_INFO' | cut -d '=' -f2)
	script_path=$( cat $tool_info | grep -w '^TREAT_PATH' | cut -d '=' -f2)
	samtools=$( cat $tool_info | grep -w '^SAMTOOLS' | cut -d '=' -f2)
	SNV_caller=$( cat $run_info | grep -w '^SNV_CALLER' | cut -d '=' -f2)
	variant_type=$( cat $run_info | grep -w '^VARIANT_TYPE' | cut -d '=' -f2)
	chrs=$( cat $run_info | grep -w '^CHRINDEX' | cut -d '=' -f2)
	chrIndexes=$( echo $chrs | tr ":" "\n" )
	analysis=`echo "$analysis" | tr "[A-Z]" "[a-z]"`
	variant_type=`echo "$variant_type" | tr "[a-z]" "[A-Z]"`
	i=1
	for chr in $chrIndexes
	do
		chrArray[$i]=$chr
		let i=i+1
	done
	#mapping numbers
	if [ $analysis != "annotation" ]
	then
		output_dir_sample=$output/alignment/$sample
		reads=$(cat $output_dir_sample/$sample.flagstat | grep -w total | cut -d ' ' -f1)
		echo -e "Total Reads" >> $numbers/$sample.out
		echo $reads >> $numbers/$sample.out
		mapped=`perl -F'\s' -ane ' if ($. == 1) {print "$F[0]"}' $output_dir_sample/$sample.mapped`
		echo -e "Mapped Reads" >> $numbers/$sample.out
		echo $mapped >> $numbers/$sample.out	
		mapped_q20=`perl -F'\s' -ane ' if ($. == 1) {print "$F[0]"}' $output_dir_sample/$sample.q20.mapped`	
		echo -e "Mapped Reads (Q >= 20) " >> $numbers/$sample.out
		echo $mapped_q20 >> $numbers/$sample.out	
	fi	
	mapped=0		
	if [ $analysis != "annotation" -a $analysis != "alignment" ]
	then
		out_realign=$output/realignment/$sample
		for i in $(seq 1 ${#chrArray[@]})
		do		
			chr_mapped=`perl -F'\s' -ane ' if ($. == 1) {print "$F[0]"}' $out_realign/chr${chrArray[$i]}.mapped`
			mapped=`expr $chr_mapped "+" $mapped`
		done			
		echo -e "Used Reads" >> $numbers/$sample.out			
		echo $mapped >> $numbers/$sample.out	 
	fi
	#coverage numbers
	if [ $analysis != "annotation" -a $analysis != "alignment" ]
	then
		echo -e "Mapped Reads OnTarget" >> $numbers/$sample.out
		for i in $(seq 1 ${#chrArray[@]})
		do
			cat $output/OnTarget/$sample.chr${chrArray[$i]}.cleaned-sorted.bam.i | wc -l >> $numbers/$sample.ontarget.out
		done
		awk '{sum+=$1; print sum}' $numbers/$sample.ontarget.out | tail -1 >> $numbers/$sample.out
		rm $numbers/$sample.ontarget.out
		## raw variant numbers
		raw_var=$output/variants
		if [ $variant_type == "BOTH" -o $variant_type == "SNV" ]
		then
			echo -e "Called SNVs ( ${SNV_caller} )" >> $numbers/$sample.out
			touch $raw_var/$sample.snvs.filtered
			for i in $(seq 1 ${#chrArray[@]})
			do
				cat $raw_var/SNV/$sample.chr${chrArray[$i]}.raw.snvs >> $raw_var/$sample.snvs.filtered	
			done
			cat $raw_var/$sample.snvs.filtered | wc -l >> $numbers/$sample.out
			rm $raw_var/$sample.snvs.filtered
		fi
	fi		
	if [ $analysis != "alignment" ]
	then
		OnTarget_var=$output/OnTarget
		touch $OnTarget_var/$sample.snvs.OnTarget
		touch $OnTarget_var/$sample.snvs.OnTarget.rsids
		for i in $(seq 1 ${#chrArray[@]})
		do
			if [ $variant_type == "BOTH" -o $variant_type == "SNV" ]
			then	
				if [ $analysis == "annotation" ]
				then
					variant_file=$OnTarget_var/$sample.chr${chrArray[$i]}.raw.snvs
					cat $variant_file >> $OnTarget_var/$sample.snvs.OnTarget
					cat $variant_file.rsids >> $OnTarget_var/$sample.snvs.OnTarget.rsids
				elif [ $analysis == "mayo" -o $analysis == "all" -o $analysis == "variant" ]
				then
					variant_file=$OnTarget_var/$sample.chr${chrArray[$i]}.raw.snvs.bed.i.ToMerge
					cat $variant_file >> $OnTarget_var/$sample.snvs.OnTarget
					cat $variant_file | awk '$NF == 1' >> $OnTarget_var/$sample.snvs.CaptureKit
					cat $variant_file.rsids >> $OnTarget_var/$sample.snvs.OnTarget.rsids
				fi	
			fi
		done
		if [ $variant_type == "BOTH" -o $variant_type == "SNV" ]
		then	
			echo -e "SNVs in the target region" >> $numbers/$sample.out
			total=`cat $OnTarget_var/$sample.snvs.OnTarget | wc -l` 
			echo "$total" >> $numbers/$sample.out
			if [ $analysis != "annotation" ]
			then
				echo -e "SNVs in the CaptureKit region" >> $numbers/$sample.out
				capture=`cat $OnTarget_var/$sample.snvs.CaptureKit | wc -l`
				echo "$capture" >> $numbers/$sample.out	
			fi
			echo -e "Transition To Transversion Ratio" >> $numbers/$sample.out
			perl $script_path/transition.transversion.pl $OnTarget_var/$sample.snvs.OnTarget >> $numbers/$sample.out
			echo -e "In dbSNP" >> $numbers/$sample.out
			dbSNP=`cat $OnTarget_var/$sample.snvs.OnTarget.rsids | grep rs -c `
			echo "$dbSNP" >> $numbers/$sample.out
			echo -e "NotIn dbSNP" >> $numbers/$sample.out	
			NotdbSNP=`expr $total "-" $dbSNP`
			echo "$NotdbSNP" >> $numbers/$sample.out		
		fi		
	fi
	sseq=$output/annotation/SSEQ/
	## indels
	if [ $analysis != "annotation" -a $analysis != "alignment" ]
	then
		if [ $variant_type == "BOTH" -o $variant_type == "INDEL" ]
		then
			echo -e "Called Indels ( GATK )" >> $numbers/$sample.out
			touch $raw_var/$sample.indels.raw
			for i in $(seq 1 ${#chrArray[@]})
			do
				cat $raw_var/INDEL/$sample.chr${chrArray[$i]}.raw.indels  >> $raw_var/$sample.indels.raw
			done
			cat $raw_var/$sample.indels.raw | wc -l >> $numbers/$sample.out
			rm $raw_var/$sample.indels.raw
			echo -e "Indels in the target region" >> $numbers/$sample.out
			touch $OnTarget_var/$sample.indels.OnTarget
			for i in $(seq 1 ${#chrArray[@]})
			do
				cat $OnTarget_var/$sample.chr${chrArray[$i]}.raw.indels.bed.i.ToMerge >> $OnTarget_var/$sample.indels.OnTarget
				cat $OnTarget_var/$sample.chr${chrArray[$i]}.raw.indels.bed.i.ToMerge | awk '$NF == 1' >> $OnTarget_var/$sample.indels.CaptureKit
			done
			cat $OnTarget_var/$sample.indels.OnTarget | wc -l >> $numbers/$sample.out
			echo -e "Indels in the captureKit region" >> $numbers/$sample.out
			cat $OnTarget_var/$sample.indels.CaptureKit | wc -l >> $numbers/$sample.out
		fi
	elif [ $analysis == "annotation" ]
	then
		if [ $variant_type == "BOTH" -o $variant_type == "INDEL" ]
		then
			echo -e "Indels in the target region" >> $numbers/$sample.out
			touch $OnTarget_var/$sample.indels.OnTarget
			for i in $(seq 1 ${#chrArray[@]})
			do
				cat $OnTarget_var/$sample.chr${chrArray[$i]}.raw.indels >> $OnTarget_var/$sample.indels.OnTarget
			done
			cat $OnTarget_var/$sample.indels.OnTarget | wc -l >> $numbers/$sample.out
		fi	
	fi
	if [ $analysis != "alignment" ]
	then
		if [ $variant_type == "BOTH" -o $variant_type == "INDEL" ]
		then
			touch $sseq/$sample.indels.sseq
			for i in $(seq 1 ${#chrArray[@]})
			do
				cat $sseq/$sample.chr${chrArray[$i]}.indels.sseq >> $sseq/$sample.indels.sseq
			done	
			perl $script_path/to.parse.sseq.result.indel.per.sample.pl $sseq/$sample.indels.sseq > $sseq/$sample.indels.sseq.formatted
			echo -e "Indels leading to frameshift mutations" >> $numbers/$sample.out
			cat $sseq/$sample.indels.sseq.formatted | awk '$7 ~ "frameshift"' | wc -l >> $numbers/$sample.out
			echo -e "Indels in coding regions not in frameshift" >> $numbers/$sample.out
			cat $sseq/$sample.indels.sseq.formatted | awk '$7 ~ "coding"' | wc -l >> $numbers/$sample.out
			echo -e "Indels in splice sites" >> $numbers/$sample.out
			cat $sseq/$sample.indels.sseq.formatted | awk '$7 ~ /splice/ ' | wc -l >> $numbers/$sample.out
		fi
		if [ $variant_type == "BOTH" -o $variant_type == "SNV" ]
		then
			touch $sseq/$sample.snv.sseq
			for i in $(seq 1 ${#chrArray[@]})
			do
					cat $sseq/$sample.chr${chrArray[$i]}.snv.sseq >> $sseq/$sample.snv.sseq	
			done
			perl $script_path/to.parse.sseq.result.per.sample.pl $sseq/$sample.snv.sseq > $sseq/$sample.snv.sseq.formatted
		fi	
		## annotation numbers
		if [ $variant_type == "BOTH" -o $variant_type == "SNV" ]
		then
			rsids=$OnTarget_var/$sample.snvs.OnTarget.rsids
			if [ $analysis == "mayo" -o $analysis == "all" -o $analysis == "variant" ]
			then
				cat $rsids | awk '$11 ~ "-"' > $rsids.novel  	
				cat $rsids | awk '$11 !~ "-"' > $rsids.known
			elif [ $analysis == "annotation" ]
			then
				cat $rsids | awk '$5 ~ "-"' > $rsids.novel
				cat $rsids | awk '$5 !~ "-"' > $rsids.known
			fi	
			cat $sseq/$sample.snv.sseq.formatted | awk '$1 ~ "none"' > $sseq/$sample.snv.sseq.formatted.novel
			cat $sseq/$sample.snv.sseq.formatted | awk '$1 !~ "none"' > $sseq/$sample.snv.sseq.formatted.known
			# KNOWN variants
			echo -e "Total Known SNVs" >> $numbers/$sample.out
			cat $rsids.known | wc -l >> $numbers/$sample.out
			echo -e "Transition To Transversion Ratio" >> $numbers/$sample.out
			perl $script_path/transition.transversion.persample.pl $sseq/$sample.snv.sseq.formatted.known >> $numbers/$sample.out
			echo -e "Nonsense" >> $numbers/$sample.out
			cat $sseq/$sample.snv.sseq.formatted.known | awk '$7 ~ "nonsense"' | wc -l >> $numbers/$sample.out
			echo -e "Missense" >> $numbers/$sample.out
			cat $sseq/$sample.snv.sseq.formatted.known | awk '$7 ~ "missense"' | wc -l >> $numbers/$sample.out
			echo -e "coding-synonymous" >> $numbers/$sample.out
			cat $sseq/$sample.snv.sseq.formatted.known | awk '$7 ~ "coding-synonymous"' | wc -l >> $numbers/$sample.out
			echo -e "coding-notMod3" >> $numbers/$sample.out
			cat $sseq/$sample.snv.sseq.formatted.known | awk '$7 ~ "coding-notMod3"' | wc -l >> $numbers/$sample.out
			if [ $analysis != "annotation" -a $analysis != "alignment" ]
			then
				echo -e "Homozygous" >> $numbers/$sample.out
				awk '{ if($3$4 ~ $5) sum=sum+1; print sum}' $rsids.known |tail -1 >> $numbers/$sample.out
				echo -e "Heterozygous" >> $numbers/$sample.out
				awk '{ if($4$4 ~ $5) sum=sum+1; print sum}' $rsids.known |tail -1 >> $numbers/$sample.out
			fi
			# Novel variants
			echo -e "Total Novel SNVs" >> $numbers/$sample.out
			cat $rsids.novel | wc -l >> $numbers/$sample.out
			echo -e "Transition To Transversion Ratio" >> $numbers/$sample.out
			perl $script_path/transition.transversion.persample.pl $sseq/$sample.snv.sseq.formatted.novel >> $numbers/$sample.out
			echo -e "Nonsense" >> $numbers/$sample.out
			cat $sseq/$sample.snv.sseq.formatted.novel | awk '$7 ~ "nonsense"' | wc -l >> $numbers/$sample.out
			echo -e "Missense" >> $numbers/$sample.out
			cat $sseq/$sample.snv.sseq.formatted.novel | awk '$7 ~ "missense"' | wc -l >> $numbers/$sample.out
			echo -e "coding-synonymous" >> $numbers/$sample.out
			cat $sseq/$sample.snv.sseq.formatted.novel | awk '$7 ~ "coding-synonymous"' | wc -l >> $numbers/$sample.out
			echo -e "coding-notMod3" >> $numbers/$sample.out
			cat $sseq/$sample.snv.sseq.formatted.novel | awk '$7 ~ "coding-notMod3"' | wc -l >> $numbers/$sample.out
			if [ $analysis != "annotation" -a $analysis != "alignment" ]
			then
				echo -e "Homozygous" >> $numbers/$sample.out
				homo=`awk '{ if($3$4 ~ $5) sum=sum+1; print sum}' $rsids.novel |tail -1`
				value=`cat $homo| awk '{print length($0)}'`
				if [ $value == 0 ]
				then
					echo -e "0" >> $numbers/$sample.out
				else
					echo "$homo" >> $numbers/$sample.out
				fi	
				echo -e "Heterozygous" >> $numbers/$sample.out
				hetero=`awk '{ if($4$4 ~ $5) sum=sum+1; print sum}' $rsids.novel |tail -1`
				value=`cat $hetero | awk '{print length($0)}'`
				if [ $value == 0 ]
				then
					echo -e "0" >> $numbers/$sample.out
				else 
					echo "$hetero" >> $numbers/$sample.out
				fi
			fi
		fi
		## deleting files
		rm $rsids.novel
		rm $rsids.known
		rm $sseq/$sample.snv.sseq.formatted
		rm $sseq/$sample.snv.sseq.formatted.known
		rm $sseq/$sample.snv.sseq.formatted.novel
		rm $sseq/$sample.indels.sseq
		rm $sseq/$sample.indels.sseq.formatted
		rm $sseq/$sample.snv.sseq
		rm $OnTarget_var/$sample.snvs.OnTarget
		rm $OnTarget_var/$sample.snvs.CaptureKit
		rm $OnTarget_var/$sample.indels.OnTarget
		rm $OnTarget_var/$sample.indels.CaptureKit
		rm $OnTarget_var/$sample.snvs.OnTarget.rsids
	fi
	## coverage number
	if [ $analysis != "annotation" -a $analysis != "alignment" ]
	then
		for ((j=0; j <= 39; j++));
		do
			for c in $(seq 1 ${#chrArray[@]})
			do
				awk '$(NF-1)>'$j'' $OnTarget_var/$sample.chr${chrArray[$c]}.pileup.bed.i | wc -l >> $numbers/$sample.coverage${j}.pileup.out
			done
			awk '{sum+=$1; print sum}' $numbers/$sample.coverage${j}.pileup.out | tail -1 >>  $numbers/$sample.coverage.out
			rm $numbers/$sample.coverage${j}.pileup.out
		done
	#	rm $OnTarget_var/$sample.chr*.pileup.bed.i
	fi	
	echo `date`
fi
	
	
	
	
	
	
	