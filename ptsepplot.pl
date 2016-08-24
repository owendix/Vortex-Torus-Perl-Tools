#!/usr/bin/perl
use Math::Trig;
#plots the point separation distances along the vortices, with a counter
#used as the parameter along the vortex. used with ptsepmov
#################################
#Input: numskip,numend,filepre (below)
#Output: spacings/spc.file.num
#			-contains the point sep distance for all vortices at a 
#			 certain time
###############################

$numskip = 1;	#recommend 1, for continuity
$numend = 215;
$filepre = "../code/may1910b.";	#include period at end

$pi=3.1415926535898;
#$r0=.005;		#dimension of cube in cm: taken directly from data
$a0=1.3e-8;	#core radius (cm)
$kap=9.969e-4;		#quantum of circulation (cm**2/sec)
@tmp=split(/\//,$filepre);
$file=pop(@tmp);
$outfiledir="spacings/spc.";

$num = 1;
$numlow = $num; 
while($num<=$numend){
	$dist = 0;
	$infile = $filepre.$num;
	open(A,"<$infile");
	$npts =<A>;
	$nvort = <A>;
	$time = <A>;
	$dtime=<A>;
	chomp($time);
	$outfile=$outfiledir.$file.$num;
	open(B, ">$outfile");
	$ivort = 0;
	#Retrieve number of points per vortex
	while ($ivort < $nvort){	
		$newline = <A>;
        ($start,$end,$term)=split(' ',$newline);				
        push (@vortpts, $end-$start+1);
		$ivort += 1;
	}
    $ivort = 0;	#Which vortex we're looking at
	@alldata=<A>;
	$line=0;
	while ($ivort < $nvort){
		$newline = $alldata[$line];
		$line++;
		#($xold,$yold,$zold)=split(' ',$newline);
		@nl=split(/\s/,$newline);
		$zold=pop(@nl);
		$yold=pop(@nl);
		$xold=pop(@nl);
		#Store original point for later
		$xf=$xold;
		$yf=$yold;
		$zf=$zold;
		if ($num==$numlow && $line==1){
			$r0 = sqrt($xf*$xf+$yf*$yf+$zf*$zf);
			$volinv=$r0**(-3);
			$beta=$kap/4/$pi*log($r0/$a0);	#approximation, from rkf.c
		}
		$i=1;
		#print "$line    $xf    $yf    $zf\n";
		while ($i < $vortpts[$ivort]){
			$newline = $alldata[$line];
            #($x,$y,$z)=split(' ',$newline);
			@nl=split(/\s/,$newline);
			$z=pop(@nl);
			$y=pop(@nl);
			$x=pop(@nl);
			$dx=$x-$xold-$r0*&round(($x-$xold)/$r0);
			$dy=$y-$yold-$r0*&round(($y-$yold)/$r0);
			$dz=$z-$zold-$r0*&round(($z-$zold)/$r0);
			$dist = sqrt($dx*$dx+$dy*$dy+$dz*$dz);
			$xold = $x;
			$yold = $y;
			$zold = $z;
			$i++;
		    $line++;
           	print B "$line $dist\n";
        }
		#Complete the ring with original point	
		$dx=$x-$xf-$r0*&round(($x-$xf)/$r0);
		$dy=$y-$yf-$r0*&round(($y-$yf)/$r0);
		$dz=$z-$zf-$r0*&round(($z-$zf)/$r0);
		$dist = sqrt($dx*$dx+$dy*$dy+$dz*$dz);
	
		print B "$line $dist\n";
		
        $ivort++;
	}
	close A;
	close B;

	@vortpts = ();
	@alldata=();
	$num+=$numskip;
}
sub round{
	my($num)=shift;
	return int($num+0.5*($num<=>0));
}
