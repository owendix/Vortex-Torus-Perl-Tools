#!/usr/bin/perl
#######################################
#Input file from copied/pasted vortex segment point
#locations in gdb, creates columns of pts
#x y z w to convert with toplot3sph.pl
#######################################
#Input: ./gdbcoretorus.pl infile.dat
#
#Output: 	x1 y1 z1 
#		 	x2 y2 z2 
#			...
##################################
$infile=pop(@ARGV);

open(A,"<$infile") or die "Couldn't open input file: $infile\n";
$cnt=0;
$k=0;
while ($data=<A>){
	if (!($data=~/gdb/)){
		@line=split(/\s+/,$data);
		$j=$cnt+1;	#=1 or 2, the index of $pnt
		$jstop=$j-1+$cnt;
		while($j>=$jstop){
			$tmp=pop(@line);
			if ($tmp=~/[0-9]/){	#contains pt value
				chomp($tmp);
				chop($tmp);
				$pnt[$j]=$tmp;
				$j--;
			}
		}
		$cnt++;
		if ($cnt==2){
			print "$pnt[0] $pnt[1] $pnt[2]\n"; ##core pts
			$k++;
			$cnt=0;
		}
	}
}
close A;
