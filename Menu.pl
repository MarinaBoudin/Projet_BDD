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
my $EMBLID;



sub Ajouter_proteine(){
  print "\nRentrez le code Entry :\n";
  $Entry=<STDIN>;
  chomp($Entry);
  $Entry="'$Entry'";
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
  print "\nRentrez le Status de la séquence : (reviewed/unreviewed)\n";
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
  print "\nRentrez le nom de l'organisme :\n";
  $Organism=<STDIN>;
  $Organism="'$Organism'";
  print "\nRentrez le EnsemblPlants :\n";
  $Ensemblplants=<STDIN>;
  $Ensemblplants="'$Ensemblplants'";
  print "\nRentrez le UniprotKBTrEMBLID :\n";
  $EMBLID=<STDIN>;
  chomp($EMBLID);
  $EMBLID="'$EMBLID'";
  print "\nRentrez le GeneTableID :\n";
  $ID=<STDIN>;
  chomp($ID);
  $ID="'$ID'";
  print "\nRentrez le Transcript :\n";
  $Transcript=<STDIN>;
  chomp($Transcript);
  $Transcript="'$Transcript'";
  print "\nRentrez le PlantReactomeReactionID :\n";
  $Reaction=<STDIN>;
  chomp($Reaction);
  $Reaction="'$Reaction'";
  $dbh->do("insert into MetaDonneesUniprot values($Entry,$Ename,$Statut,$Organism,$Ensemblplants)");
  $dbh->do("insert into DonneesUniprot values($Ename,$Genename,$Synonymous,$Ontology,$Protname,$Seq,$Length,$ECnumber)");
  $dbh->do("insert into DonneesEnsembl values($EMBLID,$Transcript,$ID,$Reaction)");
  print "\nFini\n";
}

sub Modifier_Corriger(){
  print "\nRentrez le nom de la protéine de la séquence à modifier :\n";
  $Proteine=<STDIN>;
  chomp($Proteine);
  $Proteine="'$Proteine'";
  $req=$dbh->prepare("select Sequence from DonneesUniprot where ProteineName=$Proteine") or die $dbh->strerr();
  $req->execute() or die $req->errstr();
  while (my @t = $req->fetchrow_array()){
    print join(" ",@t),"\n";
  }
  $req->finish;
  print "\nRentrez la nouvelle séquence de $Proteine :\n";
  $New_seq=<STDIN>;
  chomp($New_seq);
  $New_seq="'$New_seq'";
  $req=$dbh->prepare("update DonneesUniprot set Sequence=$New_seq where ProteineName=$Proteine") or die $dbh->strerr();
  $req->execute() or die $req->errstr();
  $req->finish;
}

sub Nom_proteine(){
  $req=$dbh->prepare("select ProteineName,Length from DonneesUniprot where EntryName in (select EntryName from MetaDonneesUniprot where Entry in (select UniprotKBTrEMBLID from DonneesEnsembl))") or die $dbh->strerr();
  $req->execute() or die $req->errstr();
  while (my @t = $req->fetchrow_array()){
    print join(" ",@t),"\n";
  }
  $req->finish;
}

sub Nom_genes{
  my $choix=shift;
  print "$choix";
  if ($choix==1){
    print FILE "<h1 style=\"text-align:center\">Voici le nom des gènes</h1>\n<table style=\"border:2px solid\">\n<tr>\n<td style=\"border:2px solid;color:red;text-align:center\">Nom des gènes</td></tr>\n";
  }
  $req=$dbh->prepare("select GeneName from DonneesUniprot where EntryName in (select EntryName from MetaDonneesUniprot where Entry in (select UniprotKBTrEMBLID from DonneesEnsembl))") or die $dbh->strerr();
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
  $req=$dbh->prepare("select ProteineName from DonneesUniprot where Length>=$longueur") or die $dbh->strerr();
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

sub Longueur_Proteine_Perl{
    open(IN,"../uniprot-arabidopsisthalianaSequence.tab") || die "No file";
    my $ligne1=0;
    my %Longueur_Proteine;
    while(<IN>){
	$ligne1++;
	if($ligne1!=1){
	    my @val=split(/\t/,$_);
	    my $organism="$val[5]";
	    if($organism=~/Arabidopsis thaliana/){
		my $ec="NaN";
		my $entry="$val[0]";
		my $entry_name="$val[1]";
		my $status="$val[2]";
		my $protein_name="$val[3]";
		if($protein_name=~/(EC\s(\d+|\-)\.(\d+|\-)\.(\d+|\-)\.(\d+|\-))/){
		    $ec="$1";
		}
		my $gene_name="$val[4]";
		my $length=int($val[6]);
		my $gene_namesyn="$val[7]";
		my $gene_ontology="$val[8]";
		my $ensembl="$val[9]";
		my $sequence="$val[10]";
		$Longueur_Proteine{$entry}=[$entry_name,$status,$protein_name,$gene_name,$length,$gene_namesyn,$gene_ontology,$ensembl,$sequence,$ec];	    
	    }
	}
    }
    $compteur=0;
    print "\nRentrez la valeur minimum de la longueur des séquence :(Perl)\n";
    my $longueur=<STDIN>;
    chomp($longueur);
    $longueur=int($longueur);
    foreach my $key(keys %Longueur_Proteine){
	if($Longueur_Proteine{$key}[4]>=$longueur){
	    $compteur++;
	    for my $i(0 .. $#{ $Longueur_Proteine{$key}}){
		print "$Longueur_Proteine{$key}[$i] \n";
	    }
	    print "\n";
	}
    }
    print "Nombre de Protéines de longueur $longueur : $compteur (Perl)\n";
}
		
sub Proteine_caracteristique{
  my $choix=shift;
  if ($choix==1){
    print FILE "<h1 style=\"text-align:center\">Voici les caractéristiques de la protéine de votre demande</h1>\n<table style=\"border:2px solid\">\n";
    print FILE "<tr>\n<td style=\"border:2px solid;color:red;text-align:center\">EntryName</td>\n<td style=\"border:2px solid;color:red;text-align:center\">GeneName</td>\n<td style=\"border:2px solid;color:red;text-align:center\">Synonymous</td>\n<td style=\"border:2px solid;color:red;text-align:center\">GeneOntology</td>\n<td style=\"border:2px solid;color:red;text-align:center\">ProteineName</td>\n<td style=\"border:2px solid;color:red;text-align:center\">Sequence</td>\n<td style=\"border:2px solid;color:red;text-align:center\">Statut</td>\n<td style=\"border:2px solid;color:red;text-align:center\">Length</td>\n<td style=\"border:2px solid;color:red;text-align:center\">ECNumber</td>\n<td style=\"border:2px solid;color:red;text-align:center\">Entry</td>\n<td style=\"border:2px solid;color:red;text-align:center\">Organism</td>\n<td style=\"border:2px solid;color:red;text-align:center\">EnsemblPlants</td>\n<td style=\"border:2px solid;color:red;text-align:center\">TranscriptStableID</td>\n<td style=\"border:2px solid;color:red;text-align:center\">GenestableID</td>\n<td style=\"border:2px solid;color:red;text-align:center\">PlantReactomeId</td>\n</tr>\n";
  }
  print "\nRentrez l'EC number de la protéine : \n";
  $EC=<STDIN>;
  chomp($EC);
  $EC="'$EC'";
  $req=$dbh->prepare("select DonneesUniprot.Entryname,Genename,GeneNameSynonymous,GeneOntology,ProteineName,Sequence,Status,Length,ECNumber,Entry,Organism,EnsemblPlants,TranscriptStableID,GenestableID,PlantReactomeId from DonneesUniprot join MetaDonneesUniprot on DonneesUniprot.EntryName=MetaDonneesUniprot.EntryName join DonneesEnsembl on MetaDonneesUniprot.Entry=DonneesEnsembl.UniprotKBTrEMBLID where ECNumber=$EC") or die $dbh->strerr();
  $req->execute() or die $req->errstr();
  while (my @t = $req->fetchrow_array()){
    print join(" ",@t),"\n";
    if ($choix==1){
      print FILE "<tr>\n";
      for my $x(@t){
        print FILE "<td style=\"border:1px solid\">$x</td>\n";
      }
      print FILE "</tr>\n";
    }
  }
  $req->finish;
  if ($choix==1){
    print FILE "</table>\n";
  }
}

sub begin_html{
  $fichier = shift;
  $fichier="$fichier.html";
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
    print "1: Ajouter une protéine\n";
    print "2: Modifier/Corriger une séquence\n";
    print "3: Afficher le nom des protéines qui sont référencés dans le fichier EnsemblPlant\n";
    print "4: Afficher le nom des gènes du fichier UniProt qui sont également réferencés dans le fichier EnsemblPlant\n";
    print "5: Afficher les protéines ayant une longueur au moins égale à une valeur SQL\n";
    print "6: Afficher les caractéristiques des protéines ayant une longueur au moins égale à une valeur Perl\n";
    print "7: Afficher les caractéristiques de la ou les protéines correspondant à un E.C. number\n";
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
	    print "\nQuel nom voulez-vous donner au fichier de sauvegarde ?\n";
	    $choix=<STDIN>;
	    chomp($choix);
	    begin_html($choix);
	    Longueur_proteine(1);
	    end_html();
	}
	elsif($choix==2){
	    Longueur_proteine(2);
	}
    }
    elsif($b==6){
	Longueur_Proteine_Perl();
    }
    elsif($b==7){
	print "\nVoudrez-vous sauvegarder votre recherche ?\n1: Oui\n2: Non\n";
	my $choix=<STDIN>;
	chomp($choix);
	$choix=int($choix);
	if ($choix==1){
	    print "\nQuel nom voulez-vous donner au fichier de sauvegarde ?\n";
	    $choix=<STDIN>;
	    chomp($choix);
	    begin_html($choix);
	    Proteine_caracteristique(1);
	    end_html();
	}
	elsif($choix==2){
	    Proteine_caracteristique(2);
	}
    }
    elsif($b==0){
	$a=1;
    }
}
$dbh->disconnect();
