#!usr/bin/perl
use strict;
use warnings;
use DBI;

#Connexion de la base de donnee
my $dbh=DBI->connect("DBI:Pg:dbname=dcetchegaray;host=dbserver","dcetchegaray","b2wehd7t",{'RaiseError' => 1});
$dbh->do("drop table GeneNameUniprot cascade");
$dbh->do("drop table ProteinNameUniprot cascade");
$dbh->do("drop table EntreeUniprot cascade");
$dbh->do("drop table FichierEnsembl cascade");
#Creation des tables et de leurs attributs
$dbh->do("create table GeneNameUniprot(EntryName text constraint cle_Gene primary key, GeneName text, Synonymous text, GeneOntology text)");
$dbh->do("create table ProteinNameUniprot(EntryName text constraint cle_Prot primary key references GeneNameUniprot(EntryName), ProteineName text, GeneName text, Sequence text, Statut varchar(25) constraint R_U check(Statut in ('reviewed','unreviewed')), Length int)");
$dbh->do("create table EntreeUniprot(Entry varchar(100) constraint cle_Entree primary key, EntryName text references ProteinNameUniprot(EntryName), Organism text, EnsemblPlants text)");
$dbh->do("create table FichierEnsembl(PlantReactomeReactionID text, UniprotKBTrEMBLID varchar(100), TranscriptStableID varchar(100), GeneStableID varchar(100), constraint cle_Uni primary key(PlantReactomeReactionID, TranscriptStableID))");
