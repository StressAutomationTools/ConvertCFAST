###############################################################################
#
# CFAST Conversion script
#
# created by Jens M Hebisch
#
# Version 0.2
# V0.2 remove second PFAST line
#
# This script is intended to convert CFAST and PFAST Cards into CBUSH and PBUSH
# cards. Note that rotations are fixed to K4 = 100, K5=K6=100000
#
# Inputs are the input file followed by three vector components for the CBUSH
# note that the vector components need to be 8 characters or less
#
# output file containing converted cards will start with "Converted_"
# the program will overwrite files that match this pattern without asking.
#
###############################################################################
use warnings;
use strict;

my $inputFile = $ARGV[0];
my $xVector = $ARGV[1];
my $yVector = $ARGV[2];
my $zVector = $ARGV[3];

sub safelyOpen{
	#prevents files from getting overwritten by checking first if a file with the 
	#same name already exists. If it does, a warning will be printed and the 
	#program will exit.
	my $file = $_[0];
	if(-e $file){
		print $file." already exists.\n";
		print "To protect the file from being overwritten, the program will now exit.\n";
		exit;
	}
	elsif(not $file){
		print "No filename was provided.\n";
		print "As no file could be created, the program will now exit\n";
		exit;
	}
	else{
		open(my $filehandle, ">", $file) or print "File could not be opened.\n" and die;
		return $filehandle;
	}
}

sub shortFormatUnpack{
	my $line = $_[0];
	my @fields = unpack('(A8)*',$line);
	foreach my $field (@fields){
		if($field =~ m/\S+\s+\S+/){
			print "Error Found in $fields[0] $fields[1].\n";
		}
	}
	return @fields;
}

sub shortFormatPack{
	my  @fields = @_;
	my $line;
	foreach my $field (@fields){
		if($field =~ m/[A-Z]*/){
			$line = $line.pack('(A8)',$field);
		}
		else{
			$line = $line.pack('(A8)',$field);
		}
	}
	return $line."\n";
}

open(IPT, "<", $inputFile);
my $output = safelyOpen("Converted_".$inputFile);
my $continue = 0;
while(<IPT>){
	if(m/^CFAST/){
		my @fields = shortFormatUnpack($_);
		my $EID = $fields[1];
		my $PID = $fields[2];
		my $GA = $fields[7];
		my $GB = $fields[8];
		my $line = shortFormatPack("CBUSH",$EID,$PID,$GA,$GB,$xVector,$yVector,$zVector);
		print $output $line;
	}
	elsif(m/^PFAST/){
		my @fields = shortFormatUnpack($_);
		my $PID = $fields[1];
		my $K1 = $fields[5];
		my $K2 = $fields[6];
		my $K3 = $fields[7];
		my $K4 = "100.";
		my $K5 = "100000.";
		my $K6 = "100000.";
		my $line = shortFormatPack("PBUSH",$PID,"K",$K1,$K2,$K3,$K4,$K5,$K6);
		print $output $line;
		$continue = 1;
	}
	elsif($continue){
		$continue = 0;
	}
	else{
		print $output $_;
	}
}
