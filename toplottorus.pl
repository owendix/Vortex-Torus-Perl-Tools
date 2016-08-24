#!/usr/bin/perl
######################
# Lops off start and end of restart files (vortex point data files) for gnuplot
# Prints vortex points into file for printing, with gnuplot,
# with each vortex in its own file, and if ($closevorts==1), by closing 
# the vortex loop onto itself.
# Also, prints ONE blank line when a vortex point intersects a wall, so 
# gnuplot and (if I replace the blank line with nan) pgfplots will skip this
# too. Though it won't alternate colors, if I want that, I must split file 
# I think: unless I can insert metadata in another column.
#########
# Can be modified to use either one data file or several: $normalinput=0,1
######################
#Input: ./toplottorus.pl
#Output: if ($normalinput==1){
#           ./images/$filepost/grb$type.$filepost.$ivort.$num (num=filenumber)
#           e.g.: ./images/feb0312a/grbf.feb0312a.16
#       }else{
#           STDOUT (raw projected data points)  x11 x12 x13
#                                               x21 x22 x23
#                                               ...
#       }
####################################################################
use Math::Trig;

$r0=0.005;	#Needed for periodic boundary check

$normalinput=1; #=1 normalinput, =0, if just for a single file:
#=0: infile specified, outfile set to STDOUT
$closevorts=1;	#=1, save 1st pt and reprint at end of vortex if not thru wall
				#from last point, to close lines

##Warn me of some input vals
print STDERR "r0=$r0 cm, configured for a ";
if ($normalinput){
	print STDERR "range of files"
}else{
	print STDERR "single file";
}
print STDERR ", normalinput=$normalinput\n";

if ($normalinput){#read from output of torus trial
	$num =1;
	$numend = -1;	#set = -1, go until last file
	$nskip = 1;
	$fileprepre = "../code/";
	$filepost = "jun1912f";		#don't include period at end
	$filepre = "$fileprepre$filepost/$filepost";	#Input file path
	if ($numend==-1){
		@tmp=glob("$filepre.*");	#checked, largest file number
		$numend=$#tmp+1;
	}
	$numst=$num;
	$outfileprepre="images";
	$outdir="$outfileprepre/$filepost";
}else{#read one file, then output to screen
	 #infile
    $file="../code/jun1912a/jun1912a.40";
    #outfile: just prints to screen
    $numst=0;
    $numend=0;
    $nskip=1;   #needed to exit loop
}

#Make directory for output files: 
#Files have format: images/filepost/grb.filepost.vort#.file#
if ($normalinput){
	if (!(mkdir $outdir)){#Returns false and sets $! (errno) if fails
		print STDERR "Cannot mkdir $outdir\n";
		print STDERR "$!\n";	#Print errno
		print STDERR "Would you like to continue?\n";
		print STDERR "Existing directory and files will not be deleted,";
		print STDERR " but files of same name will be overwritten.\n";
		print STDERR "Type 1 for yes, 0 for no.\n";
		my $input=<STDIN>;
		chomp $input;
		if ($input!=1){
			die "Exiting program\n";
		}else{
			print STDERR "Continuing.\n";
		}
	}
	$outfileprepre=$outdir."/grb";
	$outfilepre="$outfileprepre.$filepost";
}

for ($num=$numst; $num<=$numend; $num+=$nskip, @vortpts=()){
	if ($normalinput){
		$file = "$filepre.$num";
	}
	open(A,"<$file") or die "Cannot open input file: $file\n";
	$npts =<A>;			#How many points on the vortex
	$nvort=<A>;			#How many rings are there
	$time=<A>;			#What time is this file a snapshot of
	$dt=<A>;
	
	#How to split data between vortices
	for ($i=0; $i<$nvort; $i++){	
		$newline=<A>;		#Reads the entire line as a string
		($start,$end,$term)=split(' ',$newline);	#Splits string
		$vortpts[$i]= $end-$start+1; #How many lines to read per vortex
	}
	if (!$normalinput){
		open(B,">&STDOUT") or die "Cannot open STDOUT";
	}
	#For each vortex
	for ($ivort=0; $ivort<$nvort; $ivort++){
		if ($normalinput){
			$outfile = "$outfilepre.$ivort.$num";
			open(B,">$outfile") or die "Cannot open output file: $outfile\n";
		}
		#print each line to a file
        for ($i=0; $i<$vortpts[$ivort]; $i++){
			$newline=<A>;
		    #Accounts for new format of restart files:
		    #with index # and recon # printed first
		    @nl=split(/\s/,$newline);
		    $z=pop(@nl);
		    $y=pop(@nl);
		    $x=pop(@nl);
			#save for 
			if ($i==0){
				if ($closevorts){
					$firstpt="$x $y $z\n";
				}
			}else{#test if the vortex crossed the wall from old->current
				if (&hitwall($x,$xold,$y,$yold,$z,$zold,$r0)){
					print B "\n";	#print only one for same color
				}
			}
			#save to test for hitting the wall next time
			$xold=$x;
			$yold=$y;
			$zold=$z;
			print B "$x $y $z\n";
		}#end of all pts within one vort
    	if ($closevorts){#print first point again, to close loops
			($x,$y,$z)=split(/\s/,$firstpt);
			if (!&hitwall($x,$xold,$y,$yold,$z,$zold,$r0)){
        		print B $firstpt;
			}
       	}
		#Don't do this for torus: hard to distinguish between vortices
		#when plotting/making movie: want colors consistent
       	if ($ivort!=$nvort-1){
        	#print B "\n\n"; #this way gnuplot will split vortices 
           	#diff colors obtained w/ gnuplot 
           	#command "index": splot for [n=0:99] 'datafile' index n w l
		}
		if ($normalinput){
			close B;
		}
	}#end of all vorts
	if (!$normalinput){
		close B;
	}
	close A;
}
sub hitwall{
	my(($x1,$x2,$y1,$y2,$z1,$z2,$scale))=@_;
	my(($dx,$dy,$dz));
	$dx=abs(&round(($x1-$x2)/$scale));
	$dy=abs(&round(($y1-$y2)/$scale));
	$dz=abs(&round(($z1-$z2)/$scale));
	if ($dx==1 || $dy==1 || $dz==1){
		return 1;
	}
	return 0;
}
#I'm not sure where I got this, but
#<=> is a binary operator that returns -1,0,1 if
#left is less than equal or greater than right
sub round{#shifts symmetrically toward or away from 0
	#my($num) declares the local variable $num
    #shift normally has an expression, the command gives the first arg of an 
    #array, in this case, the default array: @_ which stores the arguments
    #to &round(arg)
    my($num)=shift;
    return int($num+0.5*($num<=>0));
}
