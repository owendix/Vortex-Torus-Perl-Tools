#!/usr/bin/perl
#If dist between $a and $b larger than half of $r0,
#find sum of distance from the boundaries
#
#check round with :
# ./roundcheck.pl r0 a b
# e.g. ./roundcheck.pl 1 0.95 0.05
# should print:
# -0.1
# e.g. ./roundcheck.pl 1 0.05 0.95 
# should print:
# 0.1

($r0,$a,$b)=@ARGV;

$diff=$a - $b - $r0*&round(($a - $b)/$r0);
print "$diff\n";

sub round{
	my($num)=shift;
	return int($num + 0.5*($num<=>0));
}
