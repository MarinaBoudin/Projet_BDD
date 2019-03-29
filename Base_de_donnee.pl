#!usr/bin/perl
use strict;
use warnings;
use DBI;

#Connexion de la base de donnee
my $dbh=DBI->connect("DBI:Pg:dbname=dcetchegaray;host=dbserver","dcetchegaray","b2wehd7t",{'RaiseError' => 1});
$dbh->do("drop table NameUniprot cascade");
$dbh->do("drop table EntreeUniprot cascade");
$dbh->do("drop table FichierEnsembl cascade");
#Creation des tables et de leurs attributs
$dbh->do("create table NameUniprot(EntryName text constraint cle_EntreeNom primary key, GeneName text, Synonymous text, GeneOntology text, ProteineName text, Sequence text, Statut varchar(25) constraint R_U check(Statut in ('reviewed','unreviewed')), Length int, ECNumber text)");
$dbh->do("create table EntreeUniprot(Entry varchar(100) constraint cle_Entree primary key, EntryName text references NameUniprot(EntryName), Organism text, EnsemblPlants text)");
$dbh->do("create table FichierEnsembl(UniprotKBTrEMBLID varchar(100) constraint cle_Fichiermart primary key, TranscriptStableID varchar(100), GeneStableID varchar(100), PlantReactomeId text)");

$dbh->disconnect();
