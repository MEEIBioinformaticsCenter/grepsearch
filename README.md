grepsearch
----------

The grepsearch.sh script is a wrapper script that executes zgrepsrch.pl.  This script uses grep to search for short oligonucleotide sequences in fastq sequence data files.  zgrepsearch.pl searches a set of fastq (or fastq.gz) sequence files for exact matches to a set of input oligonucleotide sequences supplied in a formatted data file.  The results are counts for each oligonucleotide in each fastq file.  The reverse complement of the oligonucleotide is also automatically searched.  An extended reference sequence for each oligonucleotide, when supplied, will be used for a secondary search of the resultant hits to reduce the number of false positive hits. 

Please see the package README file for further details.

Joseph White
Jason Comander
2015-07-013

