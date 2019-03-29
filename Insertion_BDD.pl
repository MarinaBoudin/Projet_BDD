#!usr/bin/perl
use strict;
use warnings;
use DBI;


#Connexion de la base de donnee
my $dbh=DBI->connect("DBI:Pg:dbname=dcetchegaray;host=dbserver","dcetchegaray","b2wehd7t",{'RaiseError' => 1});

open(IN,"../uniprot-arabidopsisthalianaSequence.tab") || die "No file";
my $l1=0;
while(<IN>){
    $l1++;
    $_=~s/'//g;
    if($l1!=1){
	my @val=split(/\t/,$_);
	my $organism="'$val[5]'";
	if($organism=~/Arabidopsis thaliana/){
	    print "$organism \n";
	    my $ec="'NaN'";
	    my $entry="'$val[0]'";
	    my $entry_name="'$val[1]'";
	    my $statut="'$val[2]'";
	    my $protein_name="'$val[3]'";
	    if($protein_name=~/(EC\s(\d+|\-)\.(\d+|\-)\.(\d+|\-)\.(\d+|\-))/){
		$ec="'$1'";
	    }
	    my $gene_name="'$val[4]'";
	    my $length=int($val[6]);
	    my $gene_namesyn="'$val[7]'";
	    my $gene_ontology="'$val[8]'";
	    my $ensembl="'$val[9]'";
	    my $sequence="'$val[10]'";
	    $dbh->do("insert into NameUniprot values($entry_name, $gene_name, $gene_namesyn, $gene_ontology, $protein_name, $sequence, $statut, $length, $ec)");
	    $dbh->do("insert into EntreeUniprot values($entry, $entry_name, $organism, $ensembl)");
	}
    }
}
close(IN);


open(IN_2,"../mart_export.csv") || die "No file";
my $l1_2=0;
my @doublon;
push(@doublon,"");
while(<IN_2>){
    $l1_2++;
    $_=~s/'//g;
    if($l1_2!=1){
	my @val=split(/,/,$_);
	my $Uniprot="'$val[2]'";
	my $test_doublon=($Uniprot ~~ @doublon);
	if($test_doublon eq ""  && $Uniprot ne ''){
	    my $GeneStable="'$val[0]'";
	    my $Transcript="'$val[1]'";
	    my $PlantReac="'$val[3]'";
	    $dbh->do("insert into FichierEnsembl values($Uniprot, $Transcript, $GeneStable, $PlantReac)");
	}
	push(@doublon,$Uniprot);
    }	
}




print "Termine \n";
close(IN);
$dbh->disconnect();
