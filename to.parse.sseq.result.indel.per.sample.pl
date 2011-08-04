## SeattleSEQ gives multiple rows for different transcripts per entry
## trim it to keep only one row for multiple chr pos results
## frameshift > coding > splice-5=splice3 > others
 
use strict;
use warnings;
 
my (%hash, %ann);
 
open (DAT, $ARGV[0]);
my $l = <DAT>; ## Header
#print $l;
my $prev = ''; ## previous position tracker
while ($l = <DAT>) {
    chomp $l;
	next if($l =~ /^# number|^# geneDataSource |^# HapMapFreqType |^# |^# Count /);
	my @a = split('\s+', $l);
	my $id=$a[1]."_".$a[2];
    if ($id ne $prev) {
        $hash{$a[1]}{$a[2]} = $l;
        $ann{$a[1]}{$a[2]} = $a[6];
        $prev = $id;
    } else {
        if ($ann{$a[1]}{$a[2]} ne 'frameshift') {
            if ($a[6] eq 'frameshift') {
                $ann{$a[1]}{$a[2]} = "frameshift";
                $hash{$a[1]}{$a[2]} = $l;
            } elsif ($ann{$a[1]}{$a[2]} ne 'coding' && $a[6] eq 'coding') {
                $ann{$a[1]}{$a[2]} = "coding";
                $hash{$a[1]}{$a[2]} = $l;
            } elsif ($ann{$a[1]}{$a[2]} ne 'splice-3' && $a[6] eq 'splice-3') {
                $ann{$a[1]}{$a[2]} = "splice-3";
			#	$a[6] = "splice";
                $hash{$a[1]}{$a[2]} = $l;
            } elsif ($ann{$a[1]}{$a[2]} ne 'splice-5' && $a[6] eq 'splice-5') {
                $ann{$a[1]}{$a[2]} = "splice-5";
			#	$a[6] = "splice";	
                $hash{$a[1]}{$a[2]} = $l;
            } 
        }
    }
}
close DAT;
 
foreach my $k1 (keys %hash) {
    foreach my $k2 (keys %{$hash{$k1}}) {
        print "$hash{$k1}{$k2}\n";
    }
}
 
exit;
