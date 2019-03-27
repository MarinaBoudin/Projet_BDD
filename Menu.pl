#!/usr/bin/perl
use strict;
use warnings;
use DBI;

my $dbh=DBI->connect("DBI:Pg:dbname=dcetchegaray;host=dbserver","dcetchegaray","b2wehd7t",{'RaiseError'=>1});
my $req;

sub Ajouter_proteine(){
    print "Rentrez le GeneName :\n";
    my $Genename=<STDIN>;
    chomp($Genename);
    $Genename="'$Genename'";
    print "\nRentrez le GeneName Synonymous :\n";
    my $Synonymous=<STDIN>;
    chomp($Synonymous);
    $Synonymous="'$Synonymous'";
    print "\nRentrez le GeneOntology :\n";
    my $Ontology=<STDIN>;
    chomp($Ontology);
    $Ontology="'$Ontology'";
    $dbh->do("insert into GeneNameUniprot values($Genename,$Synonymous,$Ontology)");
    print "\nRentrez le ProteineName :\n";
    my $Protname=<STDIN>;
    chomp($Protname);
    $Protname="'$Protname'";
    print "\nRentrez la Sequence :\n";
    my $Seq=<STDIN>;
    chomp($Seq);
    $Seq="'$Seq'";
    print "\nRentrez le Statut de la séquence :\n";
    my $Statut=<STDIN>;
    chomp($Statut);
    $Statut="'$Statut'";
    print "\nRentrez la longueur de la séquence :\n";
    my $Length=<STDIN>;
    chomp($Length);
    $Length=int($Length);
    $dbh->do("insert into ProteineNameUniprot values($Protname,$Genename,$Seq,$Statut,$Length)");
    print "\nRentrez le code Entry :\n";
    my $Entry=<STDIN>;
    $Entry="'$Entry'";
    print "\nRentrez le nom de l'organisme :\n";
    my $Organism=<STDIN>;
    $Organism="'$Organism'";
    print "\nRentrez le EnsemblPlants :\n";
    my $Ensemblplants=<STDIN>;
    $Ensemblplants="'$Ensemblplants'";
    $dbh->do("insert into EntreeUniprot values($Entry,$Protname,$Organism,$Ensemblplants)");
    print "\nRentrez le GeneTableID :\n";
    my $ID=<STDIN>;
    $ID="'$ID'";
    print "\nRentrez le Transcript :\n";
    my $Transcript=<STDIN>;
    $Transcript="'$Transcript'";
    print "\nRentrez le PlantReactomeReactionID :\n";
    my $Reaction=<STDIN>;
    $Reaction="'$Reaction'";
    $dbh->do("insert into FichierEnsembl values($ID,$Transcript,$Entry,$Reaction)");
    print "\nFini\n";    
}

sub Modifier_Corriger(){
    print "\nRentrez le nom de la protéine de la séquence à modifier :\n";
    my $Proteine=<STDIN>;
    chomp($Proteine);
    print "\nRentrez la nouvelle séquence de $Proteine :\n";
    my $New_seq=<STDIN>;
    chomp($New_seq);
    $req=$dbh->prepare("update ProteineNameUniprot set Sequence=$New_seq where ProteineName=$Proteine") or die $dbh->strerr();
    $req->execute() or die $req->errstr();
    
    $req->finish;
}

sub Nom_proteine(){
    $req=$dbh->prepare("select ProteinName from EntreeUniprot where Entryin (select UniprotKBTrEMBLID from FichierEnsembl)") or die $dbh->strerr();
    $req->execute() or die $req->errstr();
    while (my @t = $req->fetchrow_array()){
	print join(" ",@t),"\n";
    }
    $req->finish;
}

sub Nom_genes(){
    $req=$dbh->prepare("select GeneName from ProteineNameUniprot where ProteineName in (select ProteinName from EntreeUniprot where Entryin (select UniprotKBTrEMBLID from FichierEnsembl))") or die $dbh->strerr();
    $req->execute() or die $req->errstr();
    while (my @t = $req->fetchrow_array()){
	print join(" ",@t),"\n";
    }
    $req->finish;
}

sub Longueur_proteine(){
    print "\nRentrez le valeur minimum de la longueur des séquences :\n";
    my $longueur=<STDIN>;
    chomp($longueur);
    $longueur=int($longueur);
    $req=$dbh->prepare("select ProteineName from ProteineNameUniprot where Length>=$longueur") or die $dbh->strerr();
    $req->execute() or die $req->errstr();
    while (my @t = $req->fetchrow_array()){
	print join(" ",@t),"\n";
    }
    $req->finish;
}

sub Proteine_caracteristique(){
    
}

#Menu

my $a=0;
while($a==0){
    print "1: Ajouter une protéine\n";
    print "2: Modifier/Corriger une séquence\n";
    print "3: Afficher le nom des protéines qui sont référencés dans le fichier EnsemblPlant\n";
    print "4: Afficher le nom des gènes du fichier UniProt qui sont également réferencés dans le fichier EnsemblPlant\n";
    print "5: Afficher les protéines ayant une longueur au moins égale ç une valeur\n";
    print "6: Afficher les caractéristiques de la ou les protéines correspondant à un E.C. number\n";
    print "0: Quitter\n";
    my $b=<STDIN>;
    chomp($b);
    $b=int($b);
    if ($b==1){
	Ajouter_proteine();
    }
    elsif($b==2){
	Modifier_corriger();
    }
    elsif($b==3){
	Nom_proteine();
    }
    elsif($b==4){
	Nom_genes();
    }
    elsif($b==5){
	Longueur_proteine();
    }
    elsif($b==6){
	Proteine_caracteristique();
    }
    elsif($b==0){
	$a=1;
    }
}
#my $req=$dbh->prepare("select NomImmeuble,avg(Superficie) from Appart group by NomImmeuble") or die $dbh->strerr();
#$req->execute() or die $req->errstr();
#while (my @t = $req->fetchrow_array()){
    #print join(" ",@t),"\n";
#}
#$req->finish;
$dbh->disconnect();
