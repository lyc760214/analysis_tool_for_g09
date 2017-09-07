#!/usr/bin/perl
#code by Liu Yu-Cheng

use strict;





if($#ARGV != 0){
	print "Typing your filename\n";
	print "perl test.pl <your *.log>\n";
	exit;
}

print "\n";
print "===================================================\n";
print "=       Welcome to the AO search engine!!         =\n";
print "===================================================\n";
print "\n";

my $inp_file = $ARGV[0];
my $line;
my @word;
my $spin_case=0;
my $case=0;
my $spin_state;
my $numL=0;
my @state;
my @site;
my $atom_case;
my $i;
my $j;

while(){
	print "Choose spin state \" alpha or beta \"\n";
	$spin_state = <STDIN>;
	chomp $spin_state;
	$spin_state = lc $spin_state;
	$spin_state = ucfirst $spin_state;
	if($spin_state ne 'Alpha' && $spin_state ne 'Beta'){
		print "Check your selection again.\n";
		print "You need to choose \"alpha\" or \"beta\".\n";
	}
	else{
		open INF, "Test.FChk";
		while($line=<INF>){
			@word=split(/\s+/, $line);
			if($word[0] eq "$spin_state" && $word[1] eq 'MO' && $word[2] eq 'coefficients'){
				$numL = sqrt($word[5]);
				last;
			}
		}
		close INF;
		if($numL > 0){
			last;
		}
		else{
			print "Check your selection again.\n";
			print "Maybe the job only has alpha type.\n";
		}
	}
}


print "Prepare data, please wait.\n";



open INF, $inp_file;

while($line=<INF>){
	@word=split(/\s+/, $line);
	if($word[$#word - 2] eq 'Molecular' && $word[$#word - 1] eq 'Orbital' && $word[$#word] eq 'Coefficients:'){
		$case = 1;
		if($word[$#word - 3] eq 'Beta'){
			$spin_case = 2;
			if($spin_state eq 'Beta'){
				@site=();
			}
		}
		else{
			$spin_case = 1;
			if($spin_state eq 'Alpha'){
				@site=();
			}
		}
	}
	elsif($word[$#word - 1] eq 'Density' && $word[$#word] eq 'Matrix:'){
		$case=0;
	}
	elsif($case == 1){
		if($spin_state eq 'Beta' && $spin_case == 2){
			if($word[1] =~ /^\d*$/ && $word[$#word] =~ /^\d*$/ && $#word <=5){
				@state = {};
				for($i=1; $i<=$#word; $i++){
					push @state, $word[$i];
				}
			}
			elsif($word[1] =~ /^\d*$/ && $word[3] =~ /^[a-zA-Z]*$/ && $word[5] =~ /^(-?\d+)(\.\d+)?$/){
				$atom_case = $word[2];
				for($i = 1; $i<=$#state; $i++){
					my $key = "${atom_case}_${word[4]}_$state[$i]";
					$j = ($state[$i] - 1) * $numL + $word[1];
					$site[$j] = "$key";
				}
			}
			elsif($word[1] =~ /^\d*$/ && $word[2] =~ /^(\d+)[A-Z]/ && $word[$#word] =~ /^(-?\d+)(\.\d+)?$/){
				for($i = 1; $i<=$#state; $i++){
					my $key = "${atom_case}_${word[2]}_$state[$i]";
					$j = ($state[$i] - 1) * $numL + $word[1];
					$site[$j] = "$key";
				}
			}
		}
		elsif($spin_state eq 'Alpha' && $spin_case == 1){
			if($word[1] =~ /^\d*$/ && $word[$#word] =~ /^\d*$/ && $#word <=5){
				@state = {};
				for($i=1; $i<=$#word; $i++){
					push @state, $word[$i];
				}
			}
			elsif($word[1] =~ /^\d*$/ && $word[3] =~ /^[a-zA-Z]*$/ && $word[5] =~ /^(-?\d+)(\.\d+)?$/){
				$atom_case = $word[2];
				for($i = 1; $i<=$#state; $i++){
					my $key = "${atom_case}_${word[4]}_$state[$i]";
					$j = ($state[$i] - 1) * $numL + $word[1];
					$site[$j] = "$key";
				}
			}
			elsif($word[1] =~ /^\d*$/ && $word[2] =~ /^(\d+)[A-Z]/ && $word[$#word] =~ /^(-?\d+)(\.\d+)?$/){
				for($i = 1; $i<=$#state; $i++){
					my $key = "${atom_case}_${word[2]}_$state[$i]";
					$j = ($state[$i] - 1) * $numL + $word[1];
					$site[$j] = "$key";
				}
			}
		}
	}
}

close INF;

##########search##########
my $engSt;
my $AtoID;
my @orbNAME;
my $chk_continue;
my $orbCase;
my $YesOrNo;

while(){
	$orbCase = 0;
	#########MO ID#########
	while(){
		print "Choose MO ID.\n";
		$engSt = <STDIN>;
		chomp $engSt;
		if($engSt =~ /^\d+$/ && $engSt <= $numL){
			last;
		}
		else{
			print "Check your MO ID.\n";
		}
	}
	print "You choose MO ID is \"${engSt}\"\n";
	print "==============================\n";
	############end############
	
	#######Atom ID#######
	while(){
		print "Choose Atom ID.\n";
		$AtoID = <STDIN>;
		chomp $AtoID;
		if($AtoID =~ /^\d+$/){
			last;
		}
		else{
			print "Check your Atom ID.\n";
		}
	}
	print "You choose Atom ID is \"${AtoID}\"\n";
	print "==============================\n";
	###########end###########
	
	####Prompt AO information####
	print "Please wait.\n";
	print "These are the AO's names which you can choose.\n";
	for($i=1; $i<=$#site; $i++){
		if($site[$i] =~ /^(${AtoID}_)/ && $site[$i] =~ /(_${engSt})$/){
			my $AO = "$site[$i]";
			$AO =~ s/(${AtoID}_)//;
			$AO =~ s/(_${engSt})//;
			print "${AO}   ";
		}
	}
	print "\n";
	print "PS. The D orbitals will be named \"D, D+1, D+2, D-1, D-2\".\n";
	print "==============================\n";
	###########end###########
	
	#######AO name#######
	while(){
		print "Choose AO names.\n";
		print "You can choose more than one name, or choose all. (\"1s\" or \"1s 2s 2p\" or \"all\")\n";
		@orbNAME=();
		$line = <STDIN>;
		@word=split(/\s+/, $line);
		for($i=0; $i<=$#word; $i++){
			$word[$i] = uc $word[$i];
			if($word[$i] eq 'ALL'){
				@orbNAME=();
				push @orbNAME, $word[$i];
				$orbCase = 2;
				last;
			}
			elsif($word[$i] =~ /(^\d+)([A-Z]+)/){
				push @orbNAME, $word[$i];
				$orbCase = 1;
			}
		}
		if($#orbNAME >= 0 && $orbCase >=1){
			last;
		}
		else{
			print "Check your AO names.\n";
		}
	}
	print "==============================\n";
	###########end###########
	
	#######Print all selection#######
	print "Your selections are:\n";
	print "Spin State  =  ${spin_state}\n";
	print "MO ID       =  ${engSt}\n";
	print "Atom ID     =  ${AtoID}\n";
	print "AO Name(s)  =  ";
	for($i=0; $i<=$#orbNAME; $i++){
		print "$orbNAME[$i]   ";
	}
	print "\n";
	###########end###########
	
	#########search##########
	if($orbCase == 1){
		my @search_result=();
		my @result_orb=();
		my $key;
		for($i=1; $i<=$#site; $i++){
			for($j=0; $j<=$#orbNAME; $j++){
				$key = "${AtoID}_${orbNAME[$j]}_${engSt}";
				if($site[$i] eq "$key"){
					push @search_result, $i;
					push @result_orb, $orbNAME[$j];
				}
			}
		}
		if($#search_result >= 0 && $search_result[$#search_result] > 0){
			print "==============================\n";
			print "Result:\n";
			for($i=0; $i<=$#search_result; $i++){
				print "${result_orb[$i]}\t=\t${search_result[$i]}\n";
			}
			print "==============================\n";
			@search_result = sort{$a <=> $b} @search_result;
			print "Do you want to make the cube file? (\"yes\" or \"no\")\n";
			$YesOrNo="no";
			$YesOrNo=<STDIN>;
			chomp $YesOrNo;
			$YesOrNo = lc $YesOrNo;
			if($YesOrNo eq 'yes'){
				print "Waiting for making cube file...\n";
				&cube_maker("$spin_state","$engSt","@{search_result}","${spin_state}_MO${engSt}_AtomID${AtoID}_${result_orb[0]}_to_${result_orb[$#result_orb]}");
				print "Finish!!\n";
			}
		}
		else{
			print "==============================\n";
			print "No found!!\n";
			print "Please check all process.\n";
			print "==============================\n";
		}
	}
	elsif($orbCase == 2){
		my @search_result=();;
		my @result_orb=();;
		for($i=1; $i<=$#site; $i++){
			if($site[$i] =~ /^(${AtoID}_)/ && $site[$i] =~ /(_${engSt})$/){
				push @search_result, $i;
				my $temp_orbNAME;
				$temp_orbNAME = "$site[$i]";
				$temp_orbNAME =~ s/(${AtoID}_)//;
				$temp_orbNAME =~ s/(_${engSt})//;
				push @result_orb, $temp_orbNAME;
			}
		}
		if($#search_result >= 0 && $search_result[$#search_result] > 0){
			print "==============================\n";
			print "Result:\n";
			for($i=0; $i<=$#search_result; $i++){
				print "${result_orb[$i]}\t=\t${search_result[$i]}\n";
			}
			print "==============================\n";
			@search_result = sort{$a <=> $b} @search_result;
			print "Do you want to make the cube file? (\"yes\" or \"no\")\n";
			$YesOrNo="no";
			$YesOrNo=<STDIN>;
			chomp $YesOrNo;
			$YesOrNo = lc $YesOrNo;
			if($YesOrNo eq 'yes'){
				print "Waiting for making cube file...\n";
				&cube_maker("$spin_state","$engSt","@{search_result}","${spin_state}_MO${engSt}_AtomID${AtoID}_all");
				print "Finish!!\n";
			}
		}
		else{
			print "==============================\n";
			print "No found!!\n";
			print "Please check all process.\n";
			print "==============================\n";
		}
	}
	##########end############

	
	#######continue or not#######
	print "==============================\n";
	print "Do you want to continue?( \"yes\" or \"no\" )?\n";
	$chk_continue = <STDIN>;
	chomp $chk_continue;
	if(${chk_continue} eq "no"){
		last;
	}
	print "==============================\n";
	#############################
}

############subroutine############
sub cube_maker {
	my $spin_state = $_[0];
	my $engSt = $_[1];
	my @search_result = split(/\s+/,$_[2]);
	my $output= $_[3];
	my $line;
	my @word;
	my $i;
	my $case=0;
	my $row=1;
	my $total_row=0;
	my $position=1;
	open OUTF, ">${output}.FChk";
	open INF, "Test.FChk";
	while($line=<INF>){
		@word=split(/\s+/, $line);
		if($word[0] eq "$spin_state" && $word[1] eq 'MO' && $word[2] eq 'coefficients'){
			$case = 1;
			$total_row = int(${word[5]}/5);
			if(($word[5] / 5) > $total_row){
				$total_row++;
			}
			print OUTF "$line";
		}
		elsif($case = 1 && $row <= $total_row){
			for($i=1; $i<=$#word; $i++){
				if($position < $search_result[0]){
					if($word[$i] < 0){
						$line =~ s/${word[$i]}/ 0.00000000E+00/;
					}
					else{
						$line =~ s/${word[$i]}/0.00000000E+00/;
					}
				}
				elsif($position > $search_result[$#search_result]){
					if($word[$i] < 0){
						$line =~ s/${word[$i]}/ 0.00000000E+00/;
					}
					else{
						$line =~ s/${word[$i]}/0.00000000E+00/;
					}
				}
				else{
					my $comp=0;
					for($j=0; $j<=$#search_result; $j++){
						if($position == $search_result[$j]){
							$comp=1;
							last;
						}
					}
					if($comp != 1){
						if($word[$i] < 0){
							$line =~ s/${word[$i]}/ 0.00000000E+00/;
						}
						else{
							$line =~ s/${word[$i]}/0.00000000E+00/;
						}
					}
#########################################################################################################
					else{
						print "$word[$i] ";
					}
#########################################################################################################
				}
				$position++;
			}
			print OUTF "$line";
			$row++;
		}
		else{
			print OUTF "$line";
		}
	}
	close OUTF;
	close INF;
 if($spin_state eq "Alpha"){
     system("/prj/gaussian/g09c01/000/g09/cubegen 0 AMO=${engSt} ${output}.FChk ${output}.cube 0 h");
 }
 elsif($spin_state eq "Beta"){
     system("/prj/gaussian/g09c01/000/g09/cubegen 0 BMO=${engSt} ${output}.FChk ${output}.cube 0 h");
 }
 system("mkdir AO_cube");
 system("mv ${output}.FChk AO_cube");
 system("mv ${output}.cube AO_cube");
}
##################################



exit;
