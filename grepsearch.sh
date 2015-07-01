###############################################################
# grepsearch.sh		wrapper shell script for zgrepsrch.pl
#
# J.White	2015-04-03	v.1.0
###############################################################

# list of tar files to search
list=$1
# search strings formated: str1 \| str2	name
probes=$2
# output file
output=$3
# set workdir
workdir=$4
scriptdir=$5
debug=$6

# set this directory to point to zgrepsrch scripts
if [ -z "$scriptdir" ]; then
	scriptdir=`dirname $0`
fi
if [ -z "$list" ]; then
	echo "sh $0 <list of files> <search string list> <output filename>"
	echo "      <output dir> <script dir> <debug(1)>"
	exit
fi
if [ -z "$workdir" ]; then
	echo "setting workdir to output directory"
	outpath=`dirname $output`
	cd $outpath
	workdir=$outpath
else
	cd $workdir
fi
echo "workdir: $workdir"
echo `pwd`
log="$output.log"

if [ -n "$debug" ]; then
	echo "list of files: $list"
	echo "probes: $probes"
	echo "output file: $output"
	echo "output dir: $workdir"
	echo "script dir: $scriptdir"
	exit
fi

for file in `cat $list`
do
	if [ -e $file ]; then
		echo $file
		echo $file >> $output
		echo $file >> $log
		if [ ! "$debug" ]; then
			perl $scriptdir/zgrepsrch.pl -i $file -p $probes -o $output  \;
			echo "perl $scriptdir/zgrepsrch.pl -i $file -p $probes -o $output  \;" >> $log
			# On a ROCKS cluster, use the following command:
			# qsub -V -cwd -b y -e $log -o $log perl $scriptdir/zgrepsrch.pl -i $file -p $probes -o $output  \;
		else
			echo $file
			perl $scriptdir/zgrepsrch.pl -i $file -p $probes -o $output -d \;
			perl $scriptdir/zgrepsrch.pl
		fi
	fi
done
