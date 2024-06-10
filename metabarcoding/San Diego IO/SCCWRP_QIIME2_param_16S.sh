#!/bin/bash

#conda activate qiime2-2021.11 <----- MUST CONDA ACTIVATE BEORE RUNNING SCRIPT

workingPATH="/home/kyliel/10072021_16S_V4"  	# Path to the parent directory. It is not the directory where are stored the fastqs. Should NOT finish with "/"
fastq_directory="10072021_16S_V4_fastq"	# Name of the folder containing the fastqs. It must be located in the parent directory.
fastqPATH=$workingPATH/$fastq_directory
project_shortname="10072021_16S_V4"

#taxonomy_names=$workingPATH"/tax.txt"
#taxonomy_fasta=$workingPATH"/fasta_mod.fasta" ################### MUST BE UPPERCASE, NO SPECIAL CHARACTERS

primerF=GTGYCAGCMGCCGCGGTAA
primerR=GGACTACNVGGGTWTCTAAT
errorR=0.1
trimF=0
trimR=0
lengthF=220
lengthR=220
truncQ=2

max_id=0.97

############## source shell script with qiime commands ##############
. ./SCCWRP_QIIME2_runfile_no_tax.sh

############## source R script with dada2 commands ##############
#              Rscript --vanilla /home/kyliel/mini_attempt/SCCWRP_comp_dada2.R $workingPATH $project_shortname $fastqPATH $primerF $primerR $lengthF $lengthR $truncQ $maxEE_F $maxEE_R
#arguments are put after R script file path and file name
#MUST MATCH ARGUMENTS FROM PARAMETERS FILE
