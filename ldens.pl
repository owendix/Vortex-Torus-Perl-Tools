#!/usr/bin/perl
use Math::Trig;
################################################
#finds line length density by summing distances between 
#points in restart files accounts for periodic boundary 
#conditions over distance r0
################################################
# Input: (e.g.) ./ldens.pl ../code/oct0110a 3 
#			where 3 is the number of files to skip (actually 3-1)
#
# Output: 	time(oct0110a.1) line_length_density(oct0110a.1)
#			time(oct0110a.2) line_length_density(oct0110a.2)
#			...
#			time(oct0110a.last) line_length_density(oct0110a.last)
################################################
$r0=.01;		#dimension of cube in cm: taken directly from data

if ($#ARGV==2){
	$numskip=pop(@ARGV);
	$r0=pop(@ARGV);
	if ($r0<=0.0){
		die "r0=$r0: must be greater than 0.0cm\n";
	}
}elsif ($#ARGV==1){#$ARGV[0] = filepre, $ARGV[1] = numskip
    $numskip = pop(@ARGV);
}elsif ($#ARGV==0){
    $numskip=1;
}
$filepre = pop(@ARGV);

$numskip=($numskip<1)?1:$numskip;
@tmpar = split(/\//,$filepre);
$filename=$tmpar[$#tmpar];	#Retrieve filename
#print "$filename\n";

print STDERR "The r0 value is: $r0\n";
$a0=1.3e-8;		#core radius (cm)
$kap=9.969e-4;	#quantum of circulation (cm**2/sec)
$pi=3.1415926535898;
$volinv=$r0**(-3);
$beta=$kap/(4*$pi*log($r0/$a0));	#approximation, from rkf.c

$num = 1;
$numlow = $num;
$done=0;
while(!$done){
	$dist = 0;
	#Files stored in their own prefix directory
	$file = "$filepre/$filename.$num";
	open(A,"<$file") or die "Last file: $filename.$num";
	if (!($npts=<A>)){
		$done=1;
		break; #might not be right syntax sometimes?
	}
	$nvort = <A>;
	$time = <A>;
	$dtime=<A>;
	chomp($time);
	#Retrieve number of points per vortex
	for($ivort=0, @vortpts=();$ivort < $nvort;$ivort++){	
		$newline = <A>;
		($start,$end,$term)=split(' ',$newline);				
		push (@vortpts, $end-$start+1);
	}
	#for all vortices
	for ($ivort=0; $ivort<$nvort; $ivort++){
		$dataline=<A>;
		#($xold,$yold,$zold)=split(' ',$newline);
		@nl=split(/\s/,$dataline);
		$zold=pop(@nl);
		$yold=pop(@nl);
		$xold=pop(@nl);
		#Store original point for later
		$xf=$xold;
		$yf=$yold;
		$zf=$zold;
		for ($i=1; $i < $vortpts[$ivort]; $i++){
			$dataline=<A>;
            #($x,$y,$z)=split(' ',$newline);
			@nl=split(/\s/,$dataline);
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
	}	
	$dist*=$volinv;

	##We want to see the evolution of line length density
	###Reduced time (following Schwarz)
	#$time*=$beta;
		
	#print "$time $dist\n";
	print "$time $dist\n";
	#next file
	$num+=$numskip;
	close A;
}
#I'm not sure where I got this, but
#<=> is a binary operator that returns -1,0,1 if
#left is less than equal or greater than right
sub round{#rounds symmetrically toward or away from 0
	#my($num) declares the local variable $num
	#shift normally has an expression, the command gives the first arg of an 
	#array, in this case, the default array: @_ which stores the arguments
	#to &round(arg)
	my($num)=shift;
	return int($num+0.5*($num<=>0));
}
