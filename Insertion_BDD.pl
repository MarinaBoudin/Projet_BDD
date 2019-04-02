#!usr/bin/perl
#Marina BOUDIN
#Domitille COQ--ETCHEGARAY
use strict;
use warnings;
use DBI;

#Connexion a la base de donnees 
my $dbh=DBI->connect("DBI:Pg:dbname=dcetchegaray;host=dbserver","dcetchegaray","b2wehd7t",{'RaiseError' => 1});

#Creation des tables et de leurs attributs
sub Create_Table(){
    $dbh->do("CREATE TABLE MetaDonneesUniprot(Entry varchar(100) constraint cle_Entree primary key, EntryName text UNIQUE, Status varchar(25) constraint R_U check(Status in ('reviewed','unreviewed')), Organism text, EnsemblPlants text)");
    $dbh->do("CREATE TABLE DonneesUniprot(EntryName text constraint cle_EntreeNom primary key references MetaDonneesUniprot(EntryName), GeneName text, GeneNameSynonymous text, GeneOntology text, ProteineName text, Sequence text, Length int check(Length>0), ECNumber text)");
    $dbh->do("CREATE TABLE DonneesEnsembl(UniprotKBTrEMBLID varchar(100) constraint cle_Fichiermart primary key references MetaDonneesUniprot(Entry), TranscriptStableID varchar(100), GeneStableID varchar(100), PlantReactomeId text)");
}

#Insertion des donnees du fichier Uniprot .tab 
sub FichierUniprot(){
    open(IN,"../uniprot-arabidopsisthalianaSequence.tab") || die "No file";
    my $ligne1=0;
    my %Longueur_Proteine;
    my @test_entry;
    while(<IN>){
	$ligne1++;
	$_=~s/'//g;
	if($ligne1!=1){
	    my @val=split(/\t/,$_);
	    my $organism="'$val[5]'";
	    if($organism=~/Arabidopsis thaliana/){
		my $ec="'NaN'";
		my $entry="'$val[0]'";
		push(@test_entry,$entry);
		my $entry_name="'$val[1]'";
		my $status="'$val[2]'";
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
		$Longueur_Proteine{$entry}=[$entry_name,$status,$protein_name,$gene_name,$length,$gene_namesyn,$gene_ontology,$ensembl,$sequence];
		$dbh->do("INSERT INTO MetaDonneesUniprot VALUES($entry, $entry_name, $status, $organism, $ensembl)");
		$dbh->do("INSERT INTO DonneesUniprot VALUES($entry_name, $gene_name, $gene_namesyn, $gene_ontology, $protein_name, $sequence, $length, $ec)");	    
	    }
	}
    }
    close(IN);
    print "Termine Insertion Uniprot \n";
    return @test_entry;
}

#Insertion des donnees du fichier Ensembl .csv
sub FichierEnsembl($){
    open(IN_2,"../mart_export.csv") || die "No file";
    my @test=@{$_[0]};
    my $ligne1=0;
    my @doublon;
    push(@doublon,"");
    while(<IN_2>){
	$ligne1++;
	$_=~s/'//g;
	if($ligne1!=1){
	    my @val=split(/,/,$_);
	    my $Uniprot="'$val[2]'";
	    if(($Uniprot ~~ @doublon) eq ""  && $Uniprot ne '' && ($Uniprot ~~ @test)==1){
		my $GeneStable="'$val[0]'";
		my $Transcript="'$val[1]'";
		my $PlantReac="'$val[3]'";
		$dbh->do("INSERT INTO DonneesEnsembl VALUES($Uniprot, $Transcript, $GeneStable, $PlantReac)");
	    }
	    push(@doublon,$Uniprot);
	}	
    }
    close(IN);
    print "Termine Insertion Ensembl \n";
}


#Main
Create_Table();
my @entry=FichierUniprot();
FichierEnsembl(\@entry);

#Deconnexion
$dbh->disconnect();
