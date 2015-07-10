#!/usr/bin/perl
#############################################################################
#
#	zgrepsrch.pl	zgrep search a list of patterns against a fastq.gz file
#
#	J.White, J.Comander	2015-06-03	v.6
#
#############################################################################
# Copyright (C) 2015  Joseph A.White and Jason Comander                     #
# 3(Joseph_White@meei.harvard.edu, Jason_Comander@meei.harvard.edu)         #
#                                                                           #
# This program is free software: you can redistribute it and/or modify      #
# it under the terms of the GNU Affero General Public License as            #
# published by the Free Software Foundation, either version 3 of the        #
# License, or (at your option) any later version.                           #
#                                                                           #
# This program is distributed in the hope that it will be useful,           #
# but WITHOUT ANY WARRANTY; without even the implied warranty of            #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             #
# GNU Affero General Public License for more details.                       #
#                                                                           #
# You should have received a copy of the GNU Affero General Public License  #
# along with this program.  If not, see <http://www.gnu.org/licenses/>.     #
#############################################################################

use strict 'vars';
use Getopt::Std;
use IO::CaptureOutput qw/capture qxx qxy/;
use File::Basename;

my @args = @ARGV;
my $usage = "perl $0 -i input -o output -p patterns_file [-r resourcedir]"
	. "\n\t[-n(no rev_comp)] [-w working_directory] [-D(debug)]";
die "$usage\n" if(@ARGV < 1);

my %opts;
getopts("Dni:o:p:w:r:",\%opts);
my $infile = $opts{'i'};
my $output = $opts{'o'};
my $patterns = $opts{'p'};
my $debug = $opts{'D'};
my $nocomp = $opts{'n'};
my $workdir = $opts{'w'};
my $resourcedir = $opts{'r'};
my $log = "$output.log";

die "No search patterns supplied" if ! $patterns; 
if(! $resourcedir) {
	my $probedir = dirname($patterns);
	chomp($probedir);
	$resourcedir = $probedir;
	my $patterns1 = basename($patterns);
	$patterns = $patterns1;
}

if($debug) {
	print "infile: $infile\noutput file: $output\nprobes: $patterns\n";
	print "nocomp: $nocomp\nworkdir: $workdir\nprobe dir: $resourcedir\n";
}

if($output && $workdir) {
	open(OUT,">>$workdir/$output") || die "Could not open output file, $output; $!\n";
	open(LOG,">>$workdir/$output.log") || die "Could not open output file, $output.log; $!\n";
	print OUT "perl $0 @args\n";
	print LOG "perl $0 @args\n";
} elsif($output) {
	open(OUT,">>$output") || die "Could not open output file, $output; $!\n";
	open(LOG,">>$output.log") || die "Could not open output file, $output.log; $!\n";
	print OUT "perl $0 @args\n";
	print LOG "perl $0 @args\n";
}
#print OUT "chr\tpos\tref\talt\ttype\tdepth\tvariants\tlabel\talt hits\talt ref\twt hits\twt ref\tallelic desc\tinput file\n";
print OUT "label\tmut hit\tmut ref\twt hit\twt ref\tallelic desc\tinput file\n";

my $ctr;
open(REGEX, "$resourcedir/$patterns") || die "FILE $patterns NOT FOUND - $!\n";
while(<REGEX>) {
	chomp;
	$ctr++;
	my ($label,$regex_mut,$regex_wt,$ref_mut,$ref_wt) = split /\t/, $_;
	my $regex_mut_rev = '';
	my $regex_wt_rev = '';
	my $refsrch;
	my $wtsrch;
	my $mutseq;
	my $wtseq;
	# check for inserted mutant sequence file
	if($ref_mut) {
		$refsrch = 1;
		$ref_mut = "$resourcedir/$ref_mut";
		print LOG "$ref_mut\n" if $debug;
		open(MUT,$ref_mut) || die "Could not open mutant reference file.\n";
		# if this is a fasta file, skip the first line
		if(index($ref_mut,".fasta") || index($ref_mut,".fa")) {
			<MUT>;
		}
		while(<MUT>) {
			chomp;
			$mutseq .= $_;
		}
		close(MUT);
	} else {
		$refsrch = 0;
	}
	# check for reference sequence file
	if($ref_wt) {
		$wtsrch = 1;
		$ref_wt = "$resourcedir/$ref_wt";
		print LOG "$ref_wt\n" if $debug;
		open(WT,$ref_wt) || die "Could not open wildtype reference file.\n";
		# if this is a fasta file, skip the first line
		if(index($ref_wt,".fasta") || index($ref_wt,".fa")) {
			<WT>;
		}
		while(<WT>) {
			chomp;
			$wtseq .= $_;
		}
		close(WT);
	} else {
		$wtsrch = 0;
	}
	# handle 'no complementation' 
	unless($nocomp) {
		$regex_mut_rev = &revcomp($regex_mut);
		$regex_mut = ($regex_mut . "\\\|$regex_mut_rev");
		$regex_wt_rev = &revcomp($regex_wt);
		$regex_wt = ($regex_wt . "\\\|$regex_wt_rev");
	}
	# results array
	my @results;
	# search string hash
	my %regexp = (mut => $regex_mut, wt => $regex_wt, label => $label );
	foreach my $reg (sort keys %regexp) {
		# main loop
		next if $reg eq 'label';
		next if $reg eq '';
		my $mutctr = 0; my $wtctr = 0;
		my $regexp = $regexp{$reg};
		my $label = $regexp{'label'} . "_$reg";
		my $cmd = "zgrep --no-filename '$regexp' $infile";
		print LOG "$cmd\n" if $debug;
		# capture stdout
		my $stdout = qxx( $cmd );
		chomp($stdout);
		my @zhits = split /\W+/, $stdout;
		if($debug) {
			$" = "\n";
			print LOG "@zhits\n";
		}
		# mutant hits
		my $hitctr = scalar @zhits;
		print LOG "total hits hitctr $hitctr\n";
		push @results, $hitctr;

		if($reg eq 'mut') {
			if($refsrch > 0) {
		# secondary search against mutant reference
				foreach my $hit (@zhits) {
					my $rev_hit = &revcomp($hit);
					my $pattern = ($hit . "\\\|$rev_hit");
					my $cmd = "grep -c \"$pattern\" $ref_mut";
					print LOG "mut ref hits: $cmd\n" if $debug;
					my $stdout = qxx( $cmd );
					chomp($stdout);
					print "$stdout\n" if $debug;
					$mutctr++ if $stdout > 0;
				}
				print "$mutctr\n" if $debug;
				print LOG "matching mutant reference $mutctr\n" if $debug;
			} else {
				$mutctr = 'NA';
			}
			push @results, $mutctr;
		}
		if($reg eq 'wt') {
			if($wtsrch > 0) {
		# secondary search against wt reference
	                        foreach my $hit (@zhits) {
        	                        my $rev_hit = &revcomp($hit);
                	                my $pattern = ($hit . "\\\|$rev_hit");
                        	        my $cmd = "grep -c \"$pattern\" $ref_wt";
					print LOG "wt ref hits: $cmd\n" if $debug;
	                                my $stdout = qxx( $cmd );
        	                        chomp($stdout);
                	                $wtctr++ if $stdout > 0;
                        	}
				print "$wtctr\n" if $debug;
				print LOG "matching wt reference $wtctr\n";
			} else {
				$wtctr = 'NA';
			}
			push @results, $wtctr;
		}
	}
	my $varcnt = 0;
	my $refcnt = 0;
	if($ref_mut ne '') {
		$varcnt = $results[1];
	} else {
		$varcnt = $results[0];
	}
	if($ref_wt ne '') {
		$refcnt = $results[3];
	} else {
		$refcnt = $results[2];
	}
	$" = "\t";
	# determine heterozygous/homozygous status at mutant site
	my $hetratio;
	my $call;
	my $hettype;
	if($varcnt > 0) {
		$hetratio = $varcnt / ($varcnt + $refcnt);
		if($hetratio == 1) {
			$call = "homozygous_mutant";
			$hettype = 'hom';
		} elsif($hetratio >= 0.8) {
			$call = "probable_homozygous_mutant_error";
			$hettype = 'hom_error';
		} elsif($hetratio >= 0.2) {
			$call = "heterozygous_mutant";
			$hettype = 'het';
		} else {
			$call = "probable_heterozygous_mutant_error";
			$hettype = 'het_error';
		}
	} elsif($refcnt > 0) {
		$call = "probable_wildtype";
		$hettype = 'none';      # wildtype
	} else {
		$call = "wildtype or no coverage";
		$hettype = 'none';      # no hits; no coverage
	}
	my $depth = $varcnt + $refcnt;
#	my $alt = "+ALU $call (mut $results[0] $results[1] wt $results[2] $results[3])";
	print OUT "$label\t@results\t$call\t$infile\n";
	@results = ();
}

close(OUT);
close(LOG);
close(REGEX);

# reverse complement sequence
sub revcomp {
	my $seq = shift();
	$seq = uc($seq);
	my @comp = qw(T G C A A);
	my $rc = '';
	#split into array of bytes
	my @bases = split //, $seq;
	foreach my $byte (@bases) {
		my $index = index("ACGTU",$byte);
		$rc .= $comp[$index];
	}
	$rc = reverse($rc);
	if(length($seq) != length($rc)) { $rc = -1; }
	return $rc;
}

__DATA__
