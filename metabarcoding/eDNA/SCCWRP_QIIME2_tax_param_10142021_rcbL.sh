#!/bin/bash

#conda activate qiime2-2021.11 <----- MUST CONDA ACTIVATE BEORE RUNNING SCRIPT

homePATH="/home/kyliel"
workingPATH="/home/kyliel/10142021_rcbL"  	# Path to the parent directory. It is not the directory where are stored the fastqs. Should NOT finish with "/"
fastq_directory="10142021_rcbL_fastq"	# Name of the folder containing the fastqs. It must be located in the parent directory.
fastqPATH=$workingPATH/$fastq_directory
project_shortname="10142021_rcbL"

taxonomy="rcbL" #put only base name of taxonomy
taxonomy_names=$homePATH/$taxonomy"-tax.qza" #include file type!
taxonomy_fasta=$homePATH/$taxonomy"-seqs.qza" #include file type!

import_tax_yes_no="yes" #only options are "yes" (taxonomy is in fasta/txt) or "no" (taxonomy is in qza)
#fill out below if "yes"
taxonomy_names1=$homePATH/$taxonomy"-tax.tsv" #include file type!
taxonomy_fasta1=$homePATH/$taxonomy"-seqs.fasta" #include file type!

#fill out below with specifics for primer set of interest
primerF=AGGTGAAGTTAAAGGTTCATACTTDAA              #forward primer
primerR=CCTTCTAATTTACCAACAACTG                #reverse primer
id=0.97                                   #max similarity id (0.9-1)
length_min=200
length_max=450                            #max length of taxonomic reads
jobs_num=20                               #number of job for computer (parallel)
batch_size="auto"
orientation="forward"                     #orientatino of taxonomic reads
chunk=20000                               #chunk of reads for making classifier (parallel)

############## source shell script with qiime commands ##############
. ./SCCWRP_QIIME2_tax_runfile.sh

############## source R script with dada2 commands ##############
# Rscript --vanilla /home/kyliel/mini_attempt/SCCWRP_comp_dada2.R $workingPATH $project_shortname $fastqPATH $primerF $primerR $lengthF $lengthR $truncQ $maxEE_F $maxEE_R
#arguments are put after R script file path and file name
#MUST MATCH ARGUMENTS FROM PARAMETERS FILE
