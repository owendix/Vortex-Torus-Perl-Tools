#!/usr/bin/perl
######################################
#Clear contents of ./images/filename/points/ regularly!!!
###
#Reads input line from movie.filename.vortnum.num
#and prints a movie with that vortex configuration along with
#a single point which is iterated over all points in the files
#listed in the input line
######################################
#Input: ./ptmovtor.pl
#		Must set:	infile=movie.filename,  found in images/filename/
#					pattern=grb.filename.0.num
#		where num is the iteration number corresponding to a timestep
#		in the trial producing filename.num
#Output: ./images/filename/ptmov.filename
#		AND 
#		./images/filename/points/pts.filename.ptnum.num
#		ptnum ranges from 0->totalpts
#		file contains:	ivort, ptnum, pt_int(index value_from restart file)
#						pt_location (from grb.filename.#.num)
######################################
use Math::Trig;
use File::Path;

$filename="jan1012c";	#don't include period
$num=33699;			#selects this restart file number (restart filename.num)
$numprint=1;		#how many times to print one timestep

#Control which points to highlight w display pt
$showvort=-1;	#vort values for display pt to highlight;=-1-> show all vorts
$ptst=-1;	#when to start and finish printing points along vortex
$ptend=-1;	#(0-totalpts-1), first point=0, if ==-1, print all points
$indxst=-1; #index of when to start printing: when indxst!=-1 
			 #this OVERRIDES any ptst, ptend
$maximize=0;	#=1 if you want window maximized (check size below)
				#=0 if not

#file handling stuff
$outdir1 = "images/";
$outdir2 = "points/";
$infile=$outdir1.$filename."/movie.".$filename;	#Files get their own directory
$pattern="grb.$filename.0.$num";

#Don't let point files pile up:	Deletes
#directory recursively: rm -rf (I think)
if (($tmp=rmtree $outdir1.$filename."/".$outdir2)>0){
	print "Deleted points/ directory with $tmp files to make new directory\n";
}	
#Make directory for output files: 
#Files have format: images/filepost/grb.filepost.vort#.file#
if (!(mkdir ($outdir1.$filename."/".$outdir2))){#Returns false and sets $! (errno) if fails
	print "Cannot mkdir points/ inside ".$filename." directory\n";
    print "$!\n";   #Print errno
    print "Would you like to continue?\n";
    print "Type 1 for yes, 0 for no.\n";
    my $input=<STDIN>;
    chomp $input;
    if ($input!=1){
        die "Exiting program\n";
    }
}
											
$pointsize=.4;
$displayptsize=4*$pointsize;
$rotx=60; $rotz=30; #default values 60,30: [0,360): rotx rotates about x-axis,
					#by num of degrees, rotz about z-axis

$outmovie=$outdir1.$filename."/ptmov.".$filename;	#movie file
$outptfilepre=$outdir2."pts.".$filename;#storing pt data
#pull base print command from movie
open(A,"<$infile");		
#Iterate through movie file and pick gnuplot command that plots a certain
#restart file --> a certain grb file (which matches $pattern)
my $ispattern=0;
while($tmp=<A>){
	if ($tmp=~/$pattern/){
		$base=$tmp;	#gnuplot movie command base, print this then outptfile
		chomp($base);
		$ispattern=1;
		last;		#choose the first pattern that matches
	}
}
close(A);
if ($ispattern==0){
	die "No pattern: \'$pattern\' detected in \'movie.$filename\'\n";
}
#extract, from original movie file, the grb files storing point values
#for each vortex
@tmp=split(/"/,$base);
$j=0;
for($i=0;$i<=$#tmp;$i++){
	if ($tmp[$i]=~/grb/){
		$grbfiles[$j]=$tmp[$i];
		$j++;
	}
}
#open new output ptmov movie file
open(B,">$outmovie"); 	#Produces a single output movie file
if ($maximize){
	print B "set terminal x11 size 1600,900\n";#Desktop resolution
}
print B "set pointsize ".$pointsize."\n";
print B "set xlabel 'x'\n";
print B "set ylabel 'y'\n";
print B "set zlabel 'z'\n";
print B "set ticslevel 0\n";
print B "set border 4095\n";
print B "set view ".$rotx.",".$rotz."\n";
#open input code file: for index values
$indexfile="../code/".$filename."/".$filename.".".$num;
open(C,"<$indexfile");
$totalpts=<C>;
$nvorts=<C>; chomp($nvorts);
$tmp=<C>;
$tmp=<C>;
for($i=0;$i<$nvorts;$i++){
	$tmp=<C>;
}
#Construct outptfile for each point on vortices
$k=0;
$openptfile=1;
$ist=$totalpts;
for ($i=0;$i<$totalpts;$i++){
	$line=<C>;
	@indexdat=split(/\s/,$line);
	if ($indxst==$indexdat[0]){	#prints based off of index, instead of just i
		$ist=$i;
	}
	#$indexdat[0] is index of pt in 3sphere
	if ($openptfile){
		if ($k){
			close(E);
		}
		$tmp=$outdir1.$filename."/".$grbfiles[$k];
		open(E,"<$tmp");#get hyper/stereo/fiber pt val to print
		@ptvals=<E>;
		$p=0;
		$openptfile=0;
	}
	if ($showvort==-1 || $k==$showvort){
		if (($indxst!=-1 && $i>=$ist) || ($indxst==-1 && 
			($ptend==-1 || ($i>=$ptst && $i<=$ptend)))){
			$outptfile=$outptfilepre.".".$i.".".$num;
			$tmp=$outdir1.$filename."/".$outptfile;
			open(D,">$tmp");#Create file to store single pt
			print D "$ptvals[$p]";#Write single pt from grbfiles
			close(D);	#Close file to store single pt
			#Add command(s) to outmovie file the movie
			$j=0;
			while ($j<$numprint){#Repeat to slow movie down
				$j++;
				print B "$base, ".'"'."$outptfile";	#Write to ptmovie file
				print B '" w points pt 3 pointsize ';
				print B "$displayptsize".' t "';
				print B "$i, v=$k, indx=$indexdat[0]".'"'."\n";
			}
		}
	}
	if ($p==$#ptvals){
		$openptfile=1;
		$k++;
	}
	$p++;
}
close(B);
close(C);
close(E);
