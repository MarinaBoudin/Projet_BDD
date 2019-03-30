#!/usr/bin/perl
use strict;
use warnings;



sub Longueur_Proteine_Perl{
    open(IN,"../uniprot-arabidopsisthalianaSequence.tab") || die "No file";
    my $l1=0;
    my %Longueur_Proteine;
    while(<IN>){
	$l1++;
	$_=~s/'//g;
	if($l1!=1){
	    my @val=split(/\t/,$_);
	    my $organism="'$val[5]'";
	    if($organism=~/Arabidopsis thaliana/){
		my $entry="$val[0]";
		my $protein_name="$val[3]";
		my $length=int($val[6]);
		$Longueur_Proteine{$entry}=[$length,$protein_name];
	    }
	}
    }
    close(IN);
    my $compteur=0;
    print "\nRentrez la valeur minimum de la longueur des séquence :\n";
    my $longueur=<STDIN>;
    chomp($longueur);
    $longueur=int($longueur);
    foreach my $key(keys %Longueur_Proteine){
	if($Longueur_Proteine{$key}[0]>=$longueur){
	    $compteur++;
	    print "$Longueur_Proteine{$key}[1] \n";
	}
    }
    print "Nombre de Protéines : $compteur \n";
}
   
Longueur_Proteine_Perl();
