# Saurabh Baheti 10/15/2010
# script to merge Indels report and SSeq results
# Usage: Merge.SeattleSeq.indels.pl indel report SSeq annotations > merge report
############################

use strict;
#use warnings;

#check for presence of all i/p
if (scalar(@ARGV) != 6)	{
	print "Usage :\nMerge.SeattleSeq.indels.pl <Merged Indel Report(provide full path)> <seattle seq output><chr column><start column><ref column><alt column>\n" ;
	exit;
}
else	{
	my %hash_report=();					## hash for indel report
	my %hash_sseq=();					## hash for SSeq annotations	
	my $size_report=0;					
	my $size_annot=0;
	my $chr=$ARGV[2];$chr=$chr-1;
	my $start=$ARGV[3];$start=$start-1;
	my $ref=$ARGV[4];$ref=$ref-1;
	my $alt=$ARGV[5];$alt=$alt-1; 
	my $stop=$start+1;
	my $bases=$alt+1;
	open(REPORT,"$ARGV[0]");			## opening the indel report	
	while (my $l = <REPORT>)	{
		chomp $l;
		my $id;							## unique id different for INS and DEL
		if($. == 1)	{
			print "$l\t\t\tSeattleSeq Annotations Results\n";
		}
		elsif($. == 2)	{
			my @a = split(/\t/,$l);
			$size_report=scalar(@a);	
			print "$l\t";
		}
		else	{
			my @data=split(/\t/,$l);
			if ($data[3] eq '-')	{
				$id=$data[$chr]."_".$data[$start]."_+";
				if($data[$start] == 200981867)	{
					print "$id\n";
					<STDIN>;
				}	
			}
			else	{
				$id=$data[$chr]."_".$data[$start]."_".$data[$bases]."_".$data[$ref]."_".$data[$stop]."_-";
			}
			push(@{$hash_report{$id}},$l);			## hashing the indel report
		}	
	}
	close REPORT;
	open(ANNOT,"$ARGV[1]");						##opening annotations from SSeq
	while (my $m = <ANNOT>)	{
		my $id;						## unique id similar format from above
		chomp $m;
		if($. == 1)	{
			print "$m\n";
			my @a = split(/\t/,$m);
			$size_annot=scalar(@a);
		}
		else	{
			next if($m =~ m/^#/);
			my @a=split(/\t/,$m);
			if(grep(/-/,$a[3]))	{
				$id = "chr".$a[1]."_".$a[2]."_+";
					if($a[2] == 200981867)	{
					print "$id\n";
					<STDIN>;
				}
			}
			else	{
				my $len = length($a[3]);
				my $pos = $a[2] + $len;
				$id = "chr".$a[1]."_".$a[2]."_".$len."_".$a[3]."_".$pos."_-";
			}
			push(@{$hash_sseq{$id}},$m);			# hashing SeattleSeq report
		}
	}	
	close ANNOT;
# defining the common calls
	foreach my $record (sort keys %hash_report)	{
		if( defined($hash_sseq{$record}))	{
			my $count_report = scalar(@{$hash_report{$record}});
			my $count_sseq = scalar(@{$hash_sseq{$record}});
			if($count_report == 1)	{
				print "${$hash_report{$record}}[0]\t";
				print "${$hash_sseq{$record}}[0]\n";
				for(my $i = 1; $i < $count_sseq; $i++)	{
					print "\t"x$size_report;
					print "${$hash_sseq{$record}}[$i]\n";
				}
			}
			else	{
				for (my $i = 0; $i < $count_report; $i++)	{
					print "${$hash_report{$record}}[$i]\t";
					print "${$hash_sseq{$record}}[0]\n";
					for(my $j = 1; $j < $count_sseq; $j++)	{
						print "\t"x$size_report;
						print "${$hash_sseq{$record}}[$j]\n";
					}
				}
			}
		}
		else	{
			my $count_report = scalar(@{$hash_report{$record}});
			my $ss=$size_annot;
			if($count_report == 1)	{
				print "${$hash_report{$record}}[0]\t";
				print "-\t"x$ss;
				print"\n";
			}
			else	{
				for (my $i = 0; $i < $count_report; $i++)	{
					print "${$hash_report{$record}}[$i]\t";
					print "-\t"x$ss;
					print "\n";
				}	
			}	
		}
	}
undef %hash_report;					
undef %hash_sseq;			
}
## End of Program
