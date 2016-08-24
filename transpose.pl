#!/usr/bin/perl
#############################################
#Takes a file with data columns:
# and transposes the rows into columns, starting at a particular 
# entry (given by user) and concatenates them, 
# duplicating entries in the untransposed segment of row
#############################################
#Input: ./transpose.pl file start# 
#		where start# is the column number
#		designating the first entry in the 
#		row to be transposed (default=1)
#Output: (too screen, e.g. start#=1) 
#	a1 b1 c1 ...  	->	a1 b1
#	a2 b2 c2 ... 		a1 c1
# 	...					...
#	aN bN cN ...		a2 b2
# 	<EOF>				a2 c2 
#						...
#						<EOF>
#############################################
if ($#ARGV==0){
	$startcol=1;
}else{
	$startcol=pop(@ARGV);
}
$infile=pop(@ARGV);
open(A,"<$infile");
while($row=<A>){
	@dat=split(/\s+/,$row);
	if ($#dat-$startcol>0){
		for ($i=$startcol;$i<=$#dat;$i++){
			for ($j=0;$j<$startcol;$j++){
				print "$dat[$j] ";
			}
			print "$dat[$i]\n";
		}
	}else{
		print "$row";
	}
}
close A;
