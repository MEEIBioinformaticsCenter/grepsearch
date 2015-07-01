grepsearch
----------

The grepsearch.sh script is a wrapper script that executes zgrepsrch.pl.  This script
uses grep to search for short oligonucleotide sequences in fastq sequence data files.

zgrepsearch.pl searches a set of fastq (or, fastq.gz,fasta,fasta.gz) sequence files 
for exact matches to a set of input oligonucleotide sequences supplied in a formatted 
data file (described below).  The results are counts for each oligonucleotide in each 
fastq file.  The reverse complement of the oligonucleotide is also automatically 
searched.  An extended reference sequence for each oligonucleotide, when supplied, 
will be used for a secondary search of the resultant hits to reduce the number of 
false positive hits. 

The input oligonucleotide data file has the following format (tab delimited):

name/label |   mutant oligo sequence  |   reference oligo sequence  
	|  (mutant extended sequence file)  |  (reference extended sequence file)

Multiple oligonucleotide sets can be specified in the same file, one per line.  The 
mutant oligonucleotide sequence is usually a "mutant", or variant sequence, whereas 
the reference oligo sequence is the corresponding reference genome sequence.  
Optionally, the "mutant extended sequence file" is a fasta sequence file that 
includes a larger genomic region containing the known mutant genomic sequence.   
The extended sequence should be long enough to cover the entire NGS read, i.e. 
greater than twice the NGS read length of the oligo sequence in the center.  The 
"reference extended sequence file" is likewise a larger genomic region containing 
reference sequence, which is usually a sequence taken from the wild-type reference 
genome.  Only the oligonucleotide sequence is required.  

Command invocation
------------------

Run grepsearch with the following shell script:

sh grepsearch.sh <list of files> <search string list> <output filename>
      <output dir> <script dir> <debug(1)>

The list of files should include full paths unless the files exist in the current
directory.  The search string list should be formated as described above.  The 
output file will be created in the output directory if supplied, otherwise, in 
the current directory.  The script directory can be different from the output
directory.  Debug ("1") will list the command arguments.  If no arguments are 
supplied the command syntax above will be displayed.  

The grepsearch.sh script executes a perl script, zgrepsrch.pl, that searches 
individual input files against the probes listed in the search string list. The 
syntax (displayed when no arguments are supplied) is:   

zgrepsrch.pl -i [input list of fastq files] -p [oligo data] -o [output file] 
	-n [no complement] -w [working directory]

The input fastq files can be gzip compressed or not.  The "no complement" option 
disables automatic searching of reverse complement oligo sequences.  The working 
directory option defines the location of the grepsrch.pl script.  Ordinarily, this 
script should be used inside of a "for" loop which supplies the list of files to 
search.  

Test file results
-----------------

To run grepsearch with the test files, cd to the script directory 
and then run the following commands:

mkdir test
cp test* test	#ignore the warning
cd test
../grepsearch.sh testlist ../mak_probe.txt out.test

Results will be printed on screen and can be found in the file 'out.test'.  


Joseph White
Jason Comander
2015-07-01
