#!/bin/bash

#conda activate qiime2-amplicon-2024.5 <----- or most updated qiime2 image

taxPATH="/home/genomics/raw/taxonomy_databases" # Path to the parent directory.  Should NOT finish with "/"
processedPATH="/home/genomics/processed/BIO_CTAB_12S_012925" # Path to the processed files will be housed. Should NOT finish with "/"
sampReads=$processedPATH/"eDNA_CTAB_12S_012925_merger_12_repset" #Path to the sample sequences are stored. Should NOT finish with "/"
project_shortname="eDNA_CTAB_12S_012925_merger_12"
refName="MareMage" #name of assay

############## pick either refReads/refTax OR refClassifier ##############
refReads="12S_MareMage_fasta" #name of taxonomy sequences, must be in taxPATH, NO filetype
refTax="12S_MareMage_tax" #name of taxonomy assignments, must be in taxPATH, NO filetype

#refClassifier="cyano_monchamp_extracted_NB_classifier.qza"

############## parameters ##############
chunk=20000
maxAccepts=10
percID=0.95
eValue=0.001

############## source shell script with qiime commands ##############
. ./SCCWRP_QIIME2_tax_runfile_general.sh
