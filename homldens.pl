#!/usr/bin/perl
use Math::Trig;
################################################
#finds line length density by summing distances between 
#points in restart files accounts for periodic boundary 
#conditions over distance r0
################################################
# Input: (e.g.) ./ldens.pl ../code/oct0110a 3 
#           where 3 is the number of files to skip (actually 3-1)
#
# Output:   time(oct0110a.1) line_length_density(oct0110a.1)
#           time(oct0110a.2) line_length_density(oct0110a.2)
#           ...
#           time(oct0110a.last) line_length_density(oct0110a.last)
################################################

$r0=.01;		#dimension of the cube in cm
if ($#ARGV==2){
	$numskip = pop(@ARGV);
	$numskip= ($numskip<1) ? 1 : $numskip;
	$r0=pop(@ARGV);
	if ($r0<0.0){
		print STDERR "r0=$r0, must be greater than 0\n";
	}
}elsif ($#ARGV==1){#$ARGV[0] = filepre, $ARGV[1] = numskip
    $numskip = pop(@ARGV);
	$numskip= ($numskip<1) ? 1 : $numskip;
}elsif ($#ARGV==0){
    $numskip=1;
}
$filepre = pop(@ARGV);

@tmpar=split(/\//,$filepre);
$filename=$tmpar[$#tmpar];#Retrieve filename
#print "$filename\n";
print STDERR "The r0 value is: $r0\n";#important, so I don't forget to change it

$pi = 3.1415926535898;
$volinv=8*$r0**(-3);		#(1/8*volcube)^-1
#above volinv expression: when homogeneous, density per orthant 
#is approximately equal to the overall density
$a0=1.3e-8;	#core radius (cm)
$kap=9.969e-4;		#quantum of circulation (cm**2/sec)
$beta=$kap/4/$pi*log($r0/$a0);  #approx, from rkf.c


$num = 1; 
$numlow=$num;
$done=0;
while(!$done){
	$file = "$filepre/$filename.$num";
	open(A,"<$file") or die "Last file: $filename.$num";
	if (!($npts=<A>)){
		$done=1;
		break;	#might not be right syntax sometimes?
	}
	$nvort = <A>;
	$time = <A>;
	$dtime=<A>;
	chomp($time);
	#Retrieve number of points per vortex
	for ($ivort=0,@vortpts=();$ivort < $nvort;$ivort++){	
		$newline = <A>;
   	    ($start,$end,$term)=split(' ',$newline);				
   	    push (@vortpts, $end-$start+1);
	}
	$d000 = .0;
	$d001 = .0;
	$d010 = .0;
	$d011 = .0;
	$d100 = .0;
	$d101 = .0;
	$d110 = .0;
	$d111 = .0;
	for ($ivort=0;$ivort < $nvort;$ivort++){
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
		for ($i=1; $i<$vortpts[$ivort]; $i++){
			$newline = <A>;
   	        #($x,$y,$z)=split(' ',$newline);
			@nl=split(/\s/,$newline);
			$z=pop(@nl);
			$y=pop(@nl);
			$x=pop(@nl);
			$dx=$x-$xold-$r0*&round(($x-$xold)/$r0);
			$dy=$y-$yold-$r0*&round(($y-$yold)/$r0);
			$dz=$z-$zold-$r0*&round(($z-$zold)/$r0);
			$dist = sqrt($dx*$dx+$dy*$dy+$dz*$dz);
			#digits in variable e.g. d0000 indicate whether the
			#distance goes into the bin for x,y,z,w, less than 0: 0 or
			#greater than/equal to zero: 1
			if($xold<0){
				if($yold<0){
					if($zold<0){
						$d000 += $dist;
					} else {
						$d001 += $dist;
					}
				} else {
					if($zold<0){
						$d010 += $dist;
					} else {
						$d011 += $dist;
					}
				}
			} else {
				if($yold<0){
					if($zold<0){
						$d100 += $dist;
					} else {
						$d101 += $dist;
					}
				} else {
					if($zold<0){
						$d110 += $dist;
					} else {
						$d111 += $dist;
					}
				}
			}
			$xold = $x;
			$yold = $y;
			$zold = $z;
   	       	#print "$line    $x    $y    $z\n";
   	    }
		#Complete the ring with original point	
		$dx=$x-$xf-$r0*&round(($x-$xf)/$r0);
		$dy=$y-$yf-$r0*&round(($y-$yf)/$r0);
		$dz=$z-$zf-$r0*&round(($z-$zf)/$r0);
		$dist = sqrt($dx*$dx+$dy*$dy+$dz*$dz);
		if($x<0){
			if($y<0){
				if($z<0){
					$d000 += $dist;
				} else {
					$d001 += $dist;
				}
			} else {
				if($z<0){
					$d010 += $dist;
				} else {
					$d011 += $dist;
				}
			}
		} else {
			if($y<0){
				if($z<0){
					$d100 += $dist;
				} else {
					$d101 += $dist;
				}
			} else {
				if($z<0){
					$d110 += $dist;
				} else {
					$d111 += $dist;
				}
			}
		}
	}
	#$dist *= 0.5066061441;	#Make it per volume? Not correct
	$d000*=$volinv;
	$d001*=$volinv;
	$d010*=$volinv;
	$d011*=$volinv;
	$d100*=$volinv;
	$d101*=$volinv;
	$d110*=$volinv;
	$d111*=$volinv;
	
	##We want to see the evolution of line length density
	###Reduced time (following Schwarz)
	#$time*=$beta;

	#print "$time	$dist \n";
	print "$time $d000 $d001 $d010 $d011 $d100 $d101 $d110 $d111\n";
	#next file
	$num+=$numskip;

	close A;
}

sub round{
	my($num)=shift;
	return int($num+0.5*($num<=>0));
}
