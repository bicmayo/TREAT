## SeattleSEQ gives multiple rows for different transcripts per entry
## trim it to keep only one row for multiple chr pos results
## nonsense > missense > coding-synonymous > coding-notMod3 > others
 
use strict;
use warnings;
 
my (%hash, %ann);
 
open (DAT, $ARGV[0]);
my $l = <DAT>; ## Header
#print $l;
my $prev = ''; ## previous position tracker
while ($l = <DAT>) {
    chomp $l;
	next if($l =~ /^# number|^# geneDataSource |^# HapMapFreqType |^# Count |^# /);
	my @a = split('\s+', $l);
	my $id=$a[1]."_".$a[2];
    if ($id ne $prev) {
        $hash{$a[1]}{$a[2]} = $l;
        $ann{$a[1]}{$a[2]} = $a[6];
        $prev = $id;
    } 
	else {
        if ($ann{$a[1]}{$a[2]} ne 'nonsense') {
            if ($a[6] eq 'nonsense') {
                $ann{$a[1]}{$a[2]} = "nonsense";
                $hash{$a[1]}{$a[2]} = $l;
            } elsif ($ann{$a[1]}{$a[2]} ne 'missense' && $a[6] eq 'missense') {
                $ann{$a[1]}{$a[2]} = "missense";
                $hash{$a[1]}{$a[2]} = $l;
            } elsif ($ann{$a[1]}{$a[2]} ne 'coding-synonymous' && $a[6] eq 'coding-synonymous') {
                $ann{$a[1]}{$a[2]} = "coding-synonymous";
                $hash{$a[1]}{$a[2]} = $l;
            } elsif ($ann{$a[1]}{$a[2]} ne 'coding-notMod3' && $a[6] eq 'coding-notMod3') {
                $ann{$a[1]}{$a[2]} = "coding-notMod3";
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
