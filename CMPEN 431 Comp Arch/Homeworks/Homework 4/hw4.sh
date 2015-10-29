####################################################################
# DIRECTION:
#
# - download the bash file to a directory
# - The value of the variables SIMPLESCALAR, SSDIR, SIMOUTORDER, CFGNAME to match your system
# - cd to the directory where the bash file is residing
# - type "bash hw4.sh"
# - The results should now be in their respective files. 
####################################################################

# Declaring variables
SIMPLESCALAR=/home/software/simplesim
SSDIR=/home/grads/qxn5005/Documents/simplescalar/ss-benchmark
SIMOUTORDER=/home/software/simplesim/simplesim-3.0/sim-outorder
BZIP2=$SSDIR/bzip2
HMMR=$SSDIR/hmmer
MILC=$SSDIR/milc
EQUAKE=$SSDIR/equake
MCF=$SSDIR/mcf
SJENG=$SSDIR/sjeng
CFGNAME="hw4.cfg"
CFGDIR=$SSDIR/$CFGNAME
OUTPUTFILE="hw4_output.txt"
OUTPULFILEDIR=$SSDIR/$OUTPUTFILE
SimOutputFileName="hw4.out"


###################################
#
# Parameters:
#	1: directory of the file
#	2: directory of the output file
###################################	
GetValuesFromFile()
{
	awk '/^sim_total_insn/{printf $2}' $1 >> $2
	printf "," >> $OUTPULFILEDIR
	awk '/^sim_IPC/{printf $2}' $1 >> $2
	printf "," >> $OUTPULFILEDIR
	awk '/^ifq_occupancy/{printf $2}' $1 >> $2
	printf "," >> $OUTPULFILEDIR
	awk '/^ruu_occupancy/{printf $2}' $1 >> $2
	printf "," >> $OUTPULFILEDIR
	awk '/^lsq_occupancy/{printf $2}' $1 >> $2
	printf "\r\n" >> $OUTPULFILEDIR
	rm $1
}

TitleRow()
{
	echo " ,sim_total_insn,sim_IPC,ifq_occupancy,ruu_occupancy,lsq_occupancy" >> $OUTPULFILEDIR
}



ExtractFromResults()
{	
	printf "BZIP2," >> $OUTPULFILEDIR
	GetValuesFromFile $BZIP2/$SimOutputFileName $OUTPULFILEDIR
	printf "MCF," >> $OUTPULFILEDIR
	GetValuesFromFile $MCF/$SimOutputFileName $OUTPULFILEDIR
	printf "HMMR," >> $OUTPULFILEDIR
	GetValuesFromFile $HMMR/$SimOutputFileName $OUTPULFILEDIR
	printf "SJENG," >> $OUTPULFILEDIR
	GetValuesFromFile $SJENG/$SimOutputFileName $OUTPULFILEDIR
	printf "MILC," >> $OUTPULFILEDIR
	GetValuesFromFile $MILC/$SimOutputFileName $OUTPULFILEDIR
	printf "EQAKE," >> $OUTPULFILEDIR
	GetValuesFromFile $EQUAKE/$SimOutputFileName $OUTPULFILEDIR
}

RunSimulators()
{
	# Running bzip2
	cd $SSDIR/bzip2
	$SIMOUTORDER -config ../$CFGNAME bzip2_base.i386-m32-gcc42-nn dryer.jpg

	# Running mcf
	cd ../mcf
	$SIMOUTORDER -config ../$CFGNAME mcf_base.i386-m32-gcc42-nn inp.in

	# Running hmmr
	cd ../hmmer
	$SIMOUTORDER -config ../$CFGNAME hmmer_base.i386-m32-gcc42-nn bombesin.hmm

	# Running sjeng
	cd ../sjeng
	$SIMOUTORDER -config ../$CFGNAME sjeng_base.i386-m32-gcc42-nn test.txt

	# Running milc
	cd ../milc
	$SIMOUTORDER -config ../$CFGNAME milc_base.i386-m32-gcc42-nn < su3imp.in

	# Running equake
	cd ../equake
	$SIMOUTORDER -config ../$CFGNAME equake_base.pisa_little < inp.in > inp.out

	cd $SSDIR
}


##################### Base line run ####################
touch $OUTPULFILEDIR

echo "Baseline" > $OUTPULFILEDIR
TitleRow

RunSimulators

ExtractFromResults



##################### Base line run ####################
echo "Second Run" >> $OUTPULFILEDIR
TitleRow
touch tempfile.txt
# 2-way, dynamic (in-order) superscalar datapath
awk ' /fetch:ifqsize/ { sub($2,"2",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /fetch:speed/ { sub($2,"2",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /fetch:mplat/ { sub($2,"3",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /decode:width/ { sub($2,"2",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /issue:width/ { sub($2,"2",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /issue:inorder/ { sub($2,"true",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /issue:wrongpath/ { sub($2,"false",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /ruu:size/ { sub($2,"8",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /lsq:size/ { sub($2,"4",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /res:ialu/ { sub($2,"2",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /res:imult/ { sub($2,"1",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /res:memport/ { sub($2,"2",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /res:fpalu/ { sub($2,"2",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /res:fpmult/ { sub($2,"1",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /mem:width/ { sub($2,"16",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR

RunSimulators

ExtractFromResults

#############
echo "Third Run" >> $OUTPULFILEDIR
TitleRow
touch tempfile.txt
# 2-way, dynamic (out-of-order) superscalar datapath
awk ' /issue:inorder/ { sub($2,"false",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /issue:wrongpath/ { sub($2,"true",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt

RunSimulators

ExtractFromResults

#############
echo "Fourth Run" >> $OUTPULFILEDIR
TitleRow
touch tempfile.txt
# 4-way, dynamic (out-of-order) superscalar datapath
awk ' /fetch:ifqsize/ { sub($2,"4",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /decode:width/ { sub($2,"4",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /issue:width/ { sub($2,"4",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /ruu:size/ { sub($2,"16",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /res:ialu/ { sub($2,"4",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt
awk ' /res:fpalu/ { sub($2,"4",$2)}1' $CFGDIR > tempfile.txt && mv tempfile.txt $CFGDIR
touch tempfile.txt

RunSimulators

ExtractFromResults




