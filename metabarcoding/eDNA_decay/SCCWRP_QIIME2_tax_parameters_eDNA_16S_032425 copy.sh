#!/bin/bash

#conda activate qiime2-amplicon-2024.5 <----- or most updated qiime2 image

taxPATH="/home/genomics/raw/taxonomy_databases" # Path to the parent directory.  Should NOT finish with "/"
processedPATH="/home/genomics/processed/BIO_eDNA_16S_032425" # Path to the processed files will be housed. Should NOT finish with "/"
sampReads=$processedPATH/"BIO_eDNA_032425_16S_dada2_merger8_repset" #Path to the sample sequences are stored. Should NOT finish with "/"
project_shortname="BIO_eDNA_032425_16S_dada2_merger8"
refName="silva" #name of assay

############## pick either refReads/refTax OR refClassifier ##############
refReads="silva-138-99-seqs" #name of taxonomy sequences, must be in taxPATH, NO filetype
refTax="silva-138-99-tax" #name of taxonomy assignments, must be in taxPATH, NO filetype

#refClassifier="cyano_monchamp_extracted_NB_classifier.qza"

############## parameters ##############
chunk=20000
maxAccepts=10
percID=0.99
eValue=0.001

############## source shell script with qiime commands ##############
. ./SCCWRP_QIIME2_tax_runfile_general.sh
