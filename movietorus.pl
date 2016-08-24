#!/usr/bin/perl
# Makes a gnuplot script for a "movie"=series of plots printed sequentially
# Different vortices are separated into files
# But when a boundary is crossed, data rows separated by ONE blank row 
# (it only prints diff colors w/ 2)
#For use with toplottorus.pl
######################################################################
#Change: $num, $numend, $nskip, $type, $fileprepost, and some parameters
#       below for how they're printed: $pvort,$vnum,$numprint
#Output: ./images/filepre/movie.filepre:
#			Contains: gnuplot commands
#Run output: (in images/filepre dir) gnuplot movie.filepre
######################################################################
#gnuplot blocks:
#Lines don't connect between blocks of data: w lines or w linespoints
#w/o specifying which block: prints all blocks (vortices) same color
#Specify blocks with "index" or "every" command in gnuplot
#
#gnuplot One-Liners: (gnuplot abbrevs: w=with, l=lines, lp=linespoints)
#       Assumes vortices separated by blank line
#
##Print all vortices (0:5) same color:
#   splot '3Dblockdatafile' w l
##Print first first 5 one color,last 1 different color:
#   splot '3Dblockdatafile' index 0:4 w l,\
#       index 5 w l
##Print every other vortex (all one color):
#   splot '3Dblockdatafile' every :2 w l
##Print every other data point (line):
#   splot '3Dblockdatafile' every 2 w l
######################################################################
use Math::Trig;

#$flett=pop(@ARGV);#uncomment for multiple trials;comment this and 1 below for 1

$num = 1;
$numend = -1;	#set =-1 for largest file number
$nskip = 1;
$fileprepre = "../code/";
$fileprepost = "jun1912f";		#don't include period at end
#$fileprepost = "jun1912$flett";		#don't include period at end

$title=4;	#0=notitle,1=num,2=time,3=num,time,4=num,time,nvort
$vnum=($title>1)?0:7; #If vnum=0, takes nvort from files, title>=2
#Max number of vortices you want printed
$pvort=-1;	#print this single vortex (0-inf), for print all vorts: -1
$pvort2=-1; #2nd vortex to print (>$pvort); set =-1 to disregard this quantity
#vortex colors: 0=red,1=green,2=blue,3=purple,4=aqua,5=brn,6=orange,7=light-brn
$r0 = .005;		#from params.dat: determines limit
print STDERR "r0=$r0 cm\n";
$pointsize = .4;
$datasymbols="lines";
$maximize=0;	#for desktop
if ($maximize){
	$pointsize*=1.5;
}
$numprint = 10;
$rotx=60; $rotz=30;	#default values 60,30: [0,360]: rotx rotates about x-axis
					#by number of degrees, rotz -> z-axis

$filepre="$fileprepre$fileprepost/$fileprepost";
$outfilepre = "images";
$outfilepost = $fileprepost;
$outdir="$outfilepre/$fileprepost";

#get largest file
if ($numend==-1){
	@tmp=glob("$filepre.*");
	$numend=$#tmp+1;
}

$outfile = "$outdir/movie.$outfilepost";
open(B,">$outfile");			#Produces a single output movie file

$lim = $r0/2;		#r0/2 plus extra from params.dat
$numstart=$num;
#plot all points on a vortex at one time then move to next time
while($num<=$numend){
	if ($title>=2){
		$file = $filepre.".".$num;
		open(A,"<$file");
		$npts =<A>;			#How many points on each vortex
		$nvort = <A>;			#Number of vortex rings
		chomp($nvort);
		$time = <A>;			#Time that each file is a snapshot for
		chomp($time);
		$time = sprintf("%.8f",$time);
	}
	$vstop=($vnum==0 && $title>=2)?$nvort:$vnum;
	if ($pvort==-1){
        $pcomma=$vstop-1;
    }else{
        $pcomma=($pvort<$vstop)?$pvort:-1;
        $pcomma=($pvort2<$vstop)?$pvort2:$pcomma;
    }
	$i = 0;
	$imax = $numprint;
	#Plot repeatedly to slow down the movie (based on processor speed)
	if ($num==$numstart){
		if ($maximize){
			print B "set terminal x11 size 1600,900\n";#Maximized on desktop
		}
		print B "set pointsize ".$pointsize."\n";
		print B 'set xlabel "x"'."\n";
		print B 'set ylabel "y"'."\n";
		print B 'set zlabel "z"'."\n";
		print B "set ticslevel 0\n";
		print B "set border 4095\n";
		print B "set view ".$rotx.",".$rotz."\n";
	}
	while ($i < $imax){
		$i++ ;
		#If making camera view pan
		#$rotz=$rotz + (1/50);
        #Float type version of modulus
        #$rotz=(($rotz/360)-(int ($rotz/360)))*360;
        #print B "set view ".$rotx.",".$rotz."\n"
		if ($pvort<$vstop || $pvort2<$vstop){	
			#selected pvort must be in range of possible vortices
			#print B "splot [.0017:.0021][-.0008:-.0003][-.0012:-.0005] ";
			print B "splot [-$lim:$lim][-$lim:$lim][-$lim:$lim] ";
			$ptitle=0;
		}
		for ($vcnt=0;$vcnt<$vstop;$vcnt++){
			if ($pvort==-1 || $vcnt==$pvort || $vcnt==$pvort2){
				print B "\"grb.$outfilepost.$vcnt.$num\"";
				#with torus, some may be split across walls
				print B " w $datasymbols";
				if ($datasymbols=~/points/){
					print B " pt 7";
				}
				#pt:0=dot,1= +,2= x,3= *,4=hollow square w/ dot, 
                #5=solid square,6=hollow circle w/ dot,7=solid circle,
                #8=hollow triangle w/ dot, 9=solid triangle,
                #10=hollow inverted triangle w/dot, 11=solid triangle
                #12=hollow rhombus w/dot, 13=solid rhombus
				if (!$title){
					print B " notitle";
				}elsif ($title==1){
					if ($ptitle==0){
						print B ' t "n='.$num.'"';
					}else{
						print B " notitle";
					} 
				}elsif ($title==2){
					if ($ptitle==0){
						print B ' t "t='.$time.'"';
					}else{
						print B " notitle";
					}
				}elsif ($title==3){
					if ($ptitle==0){
						print B ' t "n='.$num.',t='.$time.'"';
					}else{
						print B " notitle";
					}
				}elsif ($title==4){
					if ($ptitle==0){
						print B ' t "'.$num.', t='.$time.', nvrt='.$nvort.'"';
					}else{
						print B " notitle";
					}
				}
				if ($vcnt!=$pcomma){
					print B ', ';
				}
				$ptitle++;
			}
			if ($vcnt==($vstop-1)){
				print B "\n";
			}
		}
	}
	if ($title>=2){
		close (A);
	}
	$num+=$nskip;			#How many files to skip
}
close (B);
