#!/usr/bin/perl
use strict;
use warnings;
use DBI;

my $dbh=DBI->connect("DBI:Pg:dbname=dcetchegaray;host=dbserver","dcetchegaray","b2wehd7t",{'RaiseError'=>1});
my $req;
my $compteur=0;
my $fichier;
my $Ename;
my $Genename;
my $Synonymous;
my $Ontology;
my $Protname;
my $Seq;
my $Statut;
my $Length;
my $Entry;
my $Organism;
my $Ensemblplants;
my $ID;
my $Transcript;
my $Reaction;
my $Proteine;
my $New_seq;
my $EC;
my $ECnumber;


sub Ajouter_proteine(){
  print "Rentrez l'Entryname\n";
  $Ename=<STDIN>;
  chomp($Ename);
  $Ename="'$Ename'";
  print "\nRentrez le GeneName :\n";
  $Genename=<STDIN>;
  chomp($Genename);
  $Genename="'$Genename'";
  print "\nRentrez le GeneName Synonymous :\n";
  $Synonymous=<STDIN>;
  chomp($Synonymous);
  $Synonymous="'$Synonymous'";
  print "\nRentrez le GeneOntology :\n";
  $Ontology=<STDIN>;
  chomp($Ontology);
  $Ontology="'$Ontology'";
  print "\nRentrez le ProteineName :\n";
  $Protname=<STDIN>;
  chomp($Protname);
  $Protname="'$Protname'";
  print "\nRentrez la Sequence :\n";
  $Seq=<STDIN>;
  chomp($Seq);
  $Seq="'$Seq'";
  print "\nRentrez le Statut de la séquence :\n";
  $Statut=<STDIN>;
  chomp($Statut);
  $Statut="'$Statut'";
  print "\nRentrez la longueur de la séquence :\n";
  $Length=<STDIN>;
  chomp($Length);
  $Length=int($Length);
  print "\nRentrez l'ECnumber :\n";
  $ECnumber=<STDIN>;
  chomp($ECnumber);
  $ECnumber="'$ECnumber'";
  $dbh->do("insert into NameUniprot values($Ename,$Genename,$Synonymous,$Ontology,$Protname,$Seq,$Statut,$Length,$ECnumber)");
  print "coucou";
  print "\nRentrez le code Entry :\n";
  $Entry=<STDIN>;
  $Entry="'$Entry'";
  print "\nRentrez le nom de l'organisme :\n";
  $Organism=<STDIN>;
  $Organism="'$Organism'";
  print "\nRentrez le EnsemblPlants :\n";
  $Ensemblplants=<STDIN>;
  $Ensemblplants="'$Ensemblplants'";
  $dbh->do("insert into EntreeUniprot values($Entry,$Protname,$Organism,$Ensemblplants)");
  print "\nRentrez le GeneTableID :\n";
  $ID=<STDIN>;
  $ID="'$ID'";
  print "\nRentrez le Transcript :\n";
  $Transcript=<STDIN>;
  $Transcript="'$Transcript'";
  print "\nRentrez le PlantReactomeReactionID :\n";
  $Reaction=<STDIN>;
  $Reaction="'$Reaction'";
  $dbh->do("insert into FichierEnsembl values($ID,$Transcript,$Entry,$Reaction)");
  print "\nFini\n";
}

sub Modifier_Corriger(){
  print "\nRentrez le nom de la protéine de la séquence à modifier :\n";
  $Proteine=<STDIN>;
  chomp($Proteine);
  $Proteine="'$Proteine'";
  print "\nRentrez la nouvelle séquence de $Proteine :\n";
  $New_seq=<STDIN>;
  chomp($New_seq);
  $New_seq="'$New_seq'";
  $req=$dbh->prepare("update NameUniprot set Sequence=$New_seq where ProteineName=$Proteine") or die $dbh->strerr();
  $req->execute() or die $req->errstr();
  $req->finish;
}

sub Nom_proteine(){
  $req=$dbh->prepare("select ProteineName,Length from NameUniprot where EntryName in (select EntryName from EntreeUniprot where Entry in (select UniprotKBTrEMBLID from FichierEnsembl))") or die $dbh->strerr();
  $req->execute() or die $req->errstr();
  while (my @t = $req->fetchrow_array()){
    print join(" ",@t),"\n";
  }
  $req->finish;
}

sub Nom_genes{
  my $choix=(shift)+".html";
  print "$choix";
  if ($choix==1){
    print FILE "<h1 style=\"text-align:center\">Voici le nom des gènes</h1>\n<table style=\"border:2px solid\">\n<tr>\n<td style=\"border:2px solid;color:red;text-align:center\">Nom des gènes</td></tr>\n";
  }
  $req=$dbh->prepare("select GeneName from NameUniprot where EntryName in (select EntryName from EntreeUniprot where Entry in (select UniprotKBTrEMBLID from FichierEnsembl))") or die $dbh->strerr();
  $req->execute() or die $req->errstr();
  while (my @t = $req->fetchrow_array()){
    print join(" ",@t),"\n";
    if ($choix==1){
      print FILE "<tr>\n<td>", join(" ",@t),"</td>\n</tr>\n";
    }
  }
  if($choix==1){
    print FILE "</table>\n";
  }
  $req->finish;
}

sub Longueur_proteine{
  my $choix=shift;
  $compteur=0;
  if ($choix==1){
    print FILE "<h1 style=\"text-align:center\">Voici le nom des protéines correspondant à votre demande</h1>\n<table style=\"border:2px solid\">\n<tr>\n<td style=\"border:2px solid;color:red;text-align:center\">Nom des protéines</td></tr>\n";
  }
  print "\nRentrez le valeur minimum de la longueur des séquences :\n";
  my $longueur=<STDIN>;
  chomp($longueur);
  $longueur=int($longueur);
  $req=$dbh->prepare("select ProteineName from NameUniprot where Length>=$longueur") or die $dbh->strerr();
  $req->execute() or die $req->errstr();
  while (my @t = $req->fetchrow_array()){
    print join(" ",@t),"\n";
    if ($choix==1){
      print FILE "<tr>\n<td>",join(" ",@t),"</td>\n</tr>\n";
    }
    $compteur=$compteur+1;
  }
  $req->finish;
  print "\nNombre de protéines de longueur $longueur : $compteur\n";
  if ($choix==1){
    print FILE "</table>\n<p> Il y a $compteur protéines de longueur $longueur</p>\n";
  }
}

sub Proteine_caracteristique(){
  print FILE "<h1 style=\"text-align:center\">Voici les caractéristiques de la protéine de votre demande</h1>\n<table style=\"border:2px solid\">\n";
  print FILE "<tr>\n<td style=\"border:2px solid;color:red;text-align:center\">EntryName</td>\n<td style=\"border:2px solid;color:red;text-align:center\">GeneName</td>\n<td style=\"border:2px solid;color:red;text-align:center\">Synonymous</td>\n<td style=\"border:2px solid;color:red;text-align:center\">GeneOntology</td>\n<td style=\"border:2px solid;color:red;text-align:center\">ProteineName</td>\n<td style=\"border:2px solid;color:red;text-align:center\">Sequence</td>\n<td style=\"border:2px solid;color:red;text-align:center\">Statut</td>\n<td style=\"border:2px solid;color:red;text-align:center\">Length</td>\n<td style=\"border:2px solid;color:red;text-align:center\">ECNumber</td>\n<td style=\"border:2px solid;color:red;text-align:center\">Entry</td>\n<td style=\"border:2px solid;color:red;text-align:center\">Organism</td>\n<td style=\"border:2px solid;color:red;text-align:center\">EnsemblPlants</td>\n<td style=\"border:2px solid;color:red;text-align:center\">TranscriptStableID</td>\n<td style=\"border:2px solid;color:red;text-align:center\">GenestableID</td>\n<td style=\"border:2px solid;color:red;text-align:center\">PlantReactomeId</td>\n</tr>\n";
  print "\nRentrez l'EC number de la protéine : \n";
  $EC=<STDIN>;
  chomp($EC);
  $EC="'$EC'";
  $req=$dbh->prepare("select NameUniprot.Entryname,Genename,Synonymous,GeneOntology,ProteineName,Sequence,Statut,Length,ECNumber,Entry,Organism,EnsemblPlants,TranscriptStableID,GenestableID,PlantReactomeId from NameUniprot join EntreeUniprot on NameUniprot.EntryName=EntreeUniprot.EntryName join FichierEnsembl on EntreeUniprot.Entry=FichierEnsembl.UniprotKBTrEMBLID where ECNumber=$EC") or die $dbh->strerr();
  $req->execute() or die $req->errstr();
  while (my @t = $req->fetchrow_array()){
    print join(" ",@t),"\n";
    print FILE "<tr>\n";
    for my $x(@t){
      print FILE "<td style=\"border:1px solid\">$x</td>\n";
    }
    print FILE "</tr>\n";
  }
  $req->finish;
  print FILE "</table>\n";
}

sub begin_html{
  $fichier = shift;
  open(FILE,">$fichier");
  print FILE "<!DOCTYPE html>\n<html lang=\"fr\">\n<head>\n<title>Vos résultats</title>\n<meta charset=\"utf-8\">\n</head>\n<body>\n<div>\n";
}
sub end_html(){
  print FILE "</div>\n</body>";
  close(FILE);
}

#Menu

my $a=0;
while($a==0){
  print "\n1: Ajouter une protéine\n";
  print "2: Modifier/Corriger une séquence\n";
  print "3: Afficher le nom des protéines qui sont référencés dans le fichier EnsemblPlant\n";
  print "4: Afficher le nom des gènes du fichier UniProt qui sont également réferencés dans le fichier EnsemblPlant\n";
  print "5: Afficher les protéines ayant une longueur au moins égale à une valeur\n";
  print "6: Afficher les caractéristiques de la ou les protéines correspondant à un E.C. number\n";
  print "0: Quitter\n";
  my $b=<STDIN>;
  chomp($b);
  $b=int($b);
  if ($b==1){
    Ajouter_proteine();
  }
  elsif($b==2){
    Modifier_Corriger();
  }
  elsif($b==3){
    Nom_proteine();
  }
  elsif($b==4){
    print "\nVoudrez-vous sauvegarder votre recherche ?\n1: Oui\n2: Non\n";
    my $choix=<STDIN>;
    chomp($choix);
    $choix=int($choix);
    if ($choix==1){
      print "\nQuel nom voulez-vous donner au fichier de sauvegarde ?\n";
      $choix=<STDIN>;
      chomp($choix);
      begin_html($choix);
      Nom_genes(1);
      end_html();
    }
    elsif($choix==2){
      Nom_genes(2);
    }
  }
  elsif($b==5){
    print "\nVoudrez-vous sauvegarder votre recherche ?\n1: Oui\n2: Non\n";
    my $choix=<STDIN>;
    chomp($choix);
    $choix=int($choix);
    if ($choix==1){
      begin_html("Longueur_proteine.html");
      Longueur_proteine(1);
      end_html();
    }
    elsif($choix==2){
      Longueur_proteine(2);
    }
  }
  elsif($b==6){
    begin_html("Proteine_caracteristiques.html");
    Proteine_caracteristique();
    end_html();
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
