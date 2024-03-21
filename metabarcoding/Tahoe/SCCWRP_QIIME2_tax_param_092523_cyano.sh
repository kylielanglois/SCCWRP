#!/bin/bash

#conda activate qiime2-2021.11 <----- MUST CONDA ACTIVATE BEORE RUNNING SCRIPT

homePATH="/home/genomics/raw" # Path to the parent directory.  Should NOT finish with "/"
workingPATH="/home/genomics/raw/092523_16S_cyano"  	#Path to  where the fastqs are stored. Should NOT finish with "/" It must be located in the parent directory.
fastq_directory="092523_16S_cyano_demux"	# Name of the folder containing the fastqs. It must be located in the parent directory.
fastqPATH=$workingPATH/$fastq_directory
SampReads=$fastqPATH"/092523_cyano_merger_table_85_rep_set" #DO NOT INCLUDE file type!
project_shortname="092523_cyano"

refReads="cyano_monchamp" #new name for taxonomy database

#taxonomy="silva-138-99" #put only base name of taxonomy
taxonomy_names=$homePATH/"tax.cyano.txt" #include file type!
taxonomy_fasta=$homePATH/"dna.cyano.fasta" #include file type!

import_tax_yes_no="yes" #only options are "yes" (taxonomy is in fasta/txt) or "no" (taxonomy is in qza)

#fill out below with specifics for primer set of interest
#only quotes around batch_size and orientation arguments
primerF=GGGGAATYTTCCGCAATGGG
primerR=ACTACWGGGGTATCTAATCCC
id=0.75
length_min=200
length_max=450
jobs_num=20
batch_size="auto"
orientation="forward"
chunk=20000

############## source shell script with qiime commands ##############
. ./SCCWRP_QIIME2_tax_runfile.sh

############## source R script with dada2 commands ##############
# Rscript --vanilla /home/kyliel/mini_attempt/SCCWRP_comp_dada2.R $workingPATH $project_shortname $fastqPATH $primerF $primerR $lengthF $lengthR $truncQ $maxEE_F $maxEE_R
#arguments are put after R script file path and file name
#MUST MATCH ARGUMENTS FROM PARAMETERS FILE
