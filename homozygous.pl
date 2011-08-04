# script to find homozygous

my $source = shift @ARGV;

open(DAT,"<$source");
my $count=0;
while(my $l = <DAT>)	{
	chomp $l;
	my @a = split (/\t/,$l);
	my $id=$a[2].$a[3];
	if($id eq $a[4])	{
		$count++;
	}
}
print "$count\n";	