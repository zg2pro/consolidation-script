#! /bin/perl

use strict;
use warnings;
use List::Compare;
use File::DirSync;

############################################
## Copyright: Gregory @ IO-Network #########
############################################
############################################
## CONFIGURATION ###########################
############################################

my $production_disk = "C:";
my $production = "${production_disk}\\wamp/bin/mysql";
my $consolidation_disk = "E:";
my $consolidation = "${consolidation_disk}\\wamp/bin/mysql";

##########################################


sub list {
	  my ($dir) = $_[0];
	  my ($disk) = $_[1];
	  return unless -d $dir;
		my @files;
	  if (opendir my $dh, $dir){
		# Capture entries first, so we don't descend with an
		# open dir handle.
		my @list;
		my $file;
		while ($file = readdir $dh){
				push @list, $file if -d "$dir/$file";
		}
		closedir $dh;

		for $file (@list){
		  # Unix file system considerations.
			next if $file eq '.' || $file eq '..';
			my $fullname = "$dir/$file";
			$fullname =~ s/${disk}\\//g;
			push @files, "$fullname"        if -d "$dir/$file";
			push @files, list ("$dir/$file", $disk) if -d "$dir/$file";
		}
	  }
		return @files;
}

my @prod = list ($production, $production_disk);
my $firstOne = "$production";
$firstOne =~ s/${production_disk}\\//g;
push @prod, "$firstOne" ;
#my @cons = list ($consolidation, $consolidation_disk);


  my $dirsync = new File::DirSync {
    verbose => 1,
    nocache => 1,
    localmode => 1,
};

foreach my $name (@prod) {
  $dirsync->src("$production_disk/$name");
  $dirsync->dst("$consolidation_disk/$name");

  print "syncronizing $name...";
  $dirsync->dirsync();
}



