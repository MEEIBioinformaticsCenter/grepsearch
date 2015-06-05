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
	scriptdir="/data/workdir/archive_process"
fi
if [ -z "$list" ]; then
	echo "sh $0 <list of files> <search string list> <output filename>"
	echo "      <workdir> <script dir> <debug(1)>"
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

for file in `cat $list`
do
	if [ -e $file ]; then
		echo $file
		echo $file >> $output
		echo $file >> $log
		if [ ! "$debug" ]; then
			qsub -V -cwd -b y -e $log -o $log perl $scriptdir/zgrepsrch.pl -i $file -p $probes -o $output  \;
		else
			perl $scriptdir/script.pl $file
		fi
	fi
done
