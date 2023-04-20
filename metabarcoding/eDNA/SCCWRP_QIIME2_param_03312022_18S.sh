#!/bin/bash

#conda activate qiime2-2021.4 <----- MUST CONDA ACTIVATE BEORE RUNNING SCRIPT

homePATH="/home/kyliel"
workingPATH="/home/kyliel/03312022_18S_V4"  	# Path to the parent directory. It is not the directory where are stored the fastqs. Should NOT finish with "/"
fastq_directory="03312022_18S_fastq"	# Name of the folder containing the fastqs. It must be located in the parent directory.
fastqPATH=$workingPATH/$fastq_directory
project_shortname="03312022_18S_V4"

taxonomy="silva-138-99" #put only base name of taxonomy
taxonomy_names=$homePATH/$taxonomy"-tax.qza" #include file type!
taxonomy_fasta=$homePATH/$taxonomy"-seqs.qza" #include file type!

import_tax_yes_no="no" #only options are "yes" (taxonomy is in fasta/txt) or "no" (taxonomy is in qza)

#fill out below for specific targets
primerF=CCAGCASCYGCGGTAATTCC       #forward primer
primerR=ACTTTCGTTCTTGATYRA            #reverse primer
errorR=0.1                                #error rates (0-1)
trimF=0                                   #trim 3' end of forward primer
trimR=0                                   #trim 3' end of reverse primer
lengthF=220                               #truncate 5' end of forward primer
lengthR=220                               #truncate 5' end of reverse primer
truncQ=2

id=0.95                                   #max similarity id (0.9-1)
length_min=$lengthF
length_max=450                            #max length of taxonomic reads
jobs_num=20                               #number of job for computer (parallel)
batch_size="auto"
orientation="forward"                     #orientatino of taxonomic reads
chunk=20000                               #chunk of reads for making classifier (parallel)

############## source shell script with qiime commands ##############
. ./SCCWRP_QIIME2_runfile.sh
