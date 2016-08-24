#!/usr/bin/perl
use Math::Trig;
#creates a movie to be plotted with gnuplot. used with ptsepplot.pl. 
#movie displays pt separtion distances along all vortices at a certain
#time and updates the plot in time
#################################
#Input: numskip, numend, filepre and (poss) numprint, below
#Output: spacings/mov.file
#	

$numskip=1;
$numend=201;
$filepre="../code/may1910a.";	#inclue period

$numprint = 20;
$ymax=.00085;

$ptmax=0;
for ($i=1;$i<$numend;$i+=$numskip){
	$infile=$filepre.$i;
	open(A,"<$infile");
	$totalpts=<A>;
	chomp($totalpts);

	if ($totalpts>$ptmax){
		$ptmax=$totalpts;
	}	
	close A;
}

@tmp=split(/\//,$filepre);
$filepre=pop(@tmp);
$outfilepre="spacings/";
$outfile = $outfilepre."mov.".$filepre;
chop($outfile);
open(B,">$outfile");			#Produces a single output movie file

$num=1;
$numstart=$num;
#plot all points on a vortex at one time then move to next time
while($num<=$numend){
	$file = $filepre.$num;
	$imax = $numprint;
	#Plot repeatedly to slow down the movie (based on processor speed)
	if ($num==$numstart){
		$ptmax++;
		print B 'set xlabel "pos along vortex"'."\n";
		print B 'set ylabel "pt separation"'."\n";
		print B "set xrange [0:$ptmax]\n";
		print B "set yrange [0:$ymax]\n";
	}
	$i=0;
	while ($i < $imax) {
		$i++;
		print B 'plot "spc.'.$file.'" w lines t "n='.$num.'"'."\n";	
	}
	$num+=$numskip;			#How many files to skip
}
close (B);
