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


Joseph White
Jason Comander
2015-07-01
