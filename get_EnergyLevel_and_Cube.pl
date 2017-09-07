#!/usr/bin/env perl

use strict;

($#ARGV !=0)? die "Typing your filename\nperl get_EnergyLevel_and_Cube_new.pl <your .log>\n": open INF, "$ARGV[0]"; 
system("mkdir cube_file");

my %MO;

while(my $line=<INF>){
	if($line =~ /^\s+(\w+)\s+(\S+)\s+eigenvalues\s+\-{2}\s(.+)$/){
		my $key = "$1"."$2";
		my @data;
		for(my $i=0; $i<length($3); $i+=10){
			push @data, substr($3, $i, 10);
		}
		if(!exists $MO{$key}){
			$MO{$key} = \@data;
		}
		else{
			push @{$MO{$key}}, @data;
		}
	}
}
close INF;


my $nHOMO=0;
my $command;
my $title;
my $enHOMO=0;
my $enLUMO=0;
open OUTF, ">EnergyLevel.dat";
foreach my $key (sort (keys %MO)){
	if($key =~ /^(\w+)occ/){
		$enHOMO=$MO{$key}->[-1];
		if($1 eq 'Alpha'){
			print OUTF "==== alpha electrons ====\n\n";
			$command='AMO';
			$title='Alpha';
		}
		else{
			print OUTF "\n==== beta electrons =====\n\n";
			$command='BMO';
			$title='Beta';
		}
		for(my $i=3; $i>=0; $i--){
			my $state=scalar(@{$MO{$key}})-$i;
			printf OUTF ("HOMO - %d = %.5f eV , state id = %d\n", $i,($MO{$key}->[-1*$i-1])*27.211, $state);
			system("/prj/gaussian/g09c01/000/g09/cubegen 0 ${command}=${state} Test.FChk cube_file/${title}_HOMO-${i}.cube 0 h");
		}
		$nHOMO=scalar(@{$MO{$key}});
	}
	else{
		$enLUMO=$MO{$key}->[0];
		for(my $i=0; $i<=3; $i++){
			my $state=$nHOMO+$i+1;
			printf OUTF ("LUMO + %d = %.5f eV , state id = %d\n", $i, ($MO{$key}->[$i])*27.211, $state);
			system("/prj/gaussian/g09c01/000/g09/cubegen 0 ${command}=${state} Test.FChk cube_file/${title}_LUMO+${i}.cube 0 h");
		}
		printf OUTF ("Delta = %.5f eV\n", ($enLUMO-$enHOMO) * 27.211);
		print OUTF "\n=========================\n\n";
	}
}

close OUTF;
