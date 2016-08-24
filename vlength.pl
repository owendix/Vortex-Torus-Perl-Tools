#!/usr/bin/perl
use Math::Trig;
################################################
#finds line length OF EACH VORTEX by summing distances between 
#points in restart files accounts for periodic boundary 
#conditions over distance r0
################################################
# Input: (e.g.) ./vlength.pl ../code/jan1212a/jan1212a.101
#
# Output: 	vort= 0 length= (length of vortex 0)
#			vort= 1 length= (length of vortex 1)
#			...
################################################
#Files stored in their own prefix directory
$file = pop(@ARGV);

$r0=.005;		#dimension of cube in cm

open(A,"<$file") or die "Couldn't open $filename: $!\n";
if ($npts=<A>){
	$nvort = <A>;
	$time = <A>;
	$dtime=<A>;
	chomp($time);
	#Retrieve number of points per vortex
	for ($ivort=0; $ivort < $nvort; $ivort++){	
		$newline = <A>;
        ($start,$end,$term)=split(' ',$newline);				
        push (@vortpts, $end-$start+1);
	}
	for ($ivort=0; $ivort < $nvort; $ivort++){
		$dist = 0;	#Reset distance for each vortex
		$newline = <A>;
		#($xold,$yold,$zold)=split(' ',$newline);
		@nl=split(/\s/,$newline);
		$zold=pop(@nl);
		$yold=pop(@nl);
		$xold=pop(@nl);
		#Store original point for later
		$xf=$xold;
		$yf=$yold;
		$zf=$zold;
		#print "$line    $xf    $yf    $zf\n";
		for ($i=0; $i < $vortpts[$ivort]; $i++){
			$newline = <A>;
            #($x,$y,$z)=split(' ',$newline);
			@nl=split(/\s/,$newline);
			$z=pop(@nl);
			$y=pop(@nl);
			$x=pop(@nl);
			$dx=$x-$xold-$r0*&round(($x-$xold)/$r0);
			$dy=$y-$yold-$r0*&round(($y-$yold)/$r0);
			$dz=$z-$zold-$r0*&round(($z-$zold)/$r0);
			$dist += sqrt($dx*$dx+$dy*$dy+$dz*$dz);
			$xold = $x;
			$yold = $y;
			$zold = $z;
           	#print "$line    $x    $y    $z\n";
        }
		#Complete the ring with original point	
		$dx=$x-$xf-$r0*&round(($x-$xf)/$r0);
		$dy=$y-$yf-$r0*&round(($y-$yf)/$r0);
		$dz=$z-$zf-$r0*&round(($z-$zf)/$r0);
		$dist += sqrt($dx*$dx+$dy*$dy+$dz*$dz);

		print "vort= $ivort length= $dist\n";
	}	

	close A;
}#else: First data read failed
sub round{
	my($num)=shift;
	return int($num+0.5*($num<=>0));
}
