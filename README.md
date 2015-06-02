# grepsearch
grepsearch.pl
Uses grep to search for short oligonucleotide sequences in fastq/fasta sequence data files.

grepsearch.pl searches a set of fastq sequence files for exact matches to a set of input oligonucleotide sequences supplied in a formated data file (described below).  The results are counts for each oligonucleotide in each fastq file.  The reverse complement of the oligonucleotide, when supplied, will also be used to search.  A reference sequence for each oligonucleotide can be supplied; this will be used for a secondary search of the resultant hits to reduce the number of false positive hits.  

The input oligonucleotide data file has the following format:

name(label) |   oligonucleotide sequence  |   reference oligo sequence  |  oligo sequence file  |  reference genome sequence file
etc.

Multiple oligonucleotides can be specified in the same file.  The oligonucleotide sequence is usually a "mutant", or variant sequence, whereas the reference oligo sequence is the corresponding reference genome sequence.  The "oligo sequence file" is a fasta sequence file that includes a larger genomic region containing the oligonucleotide sequence.  The "reference genome sequence file" is likewise a larger genomic region containing reference sequence, but not oligonucleotide sequence.  Only the oligonucleotide sequence is required.  

Command invocation:

grepsrch.pl -i <input list of fastq files> -p <oligo data> -o <output file> -n <no complement> -w <working directory>

The input fastq files can be gzip compressed or not.  The "no complement" option disables use of reverse complement oligo sequences.  The working directory option difines the location of the grepsrch.pl script.  


Ordinarily, this script should be used inside of a "for" loop which supplies the list of files to search.  

June 2, 2015; J.White
