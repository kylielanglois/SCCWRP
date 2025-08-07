#!/bin/bash

#conda activate qiime2-2021.4 <----- MUST CONDA ACTIVATE BEORE RUNNING SCRIPT

homePATH="/home/raw"
workingPATH="/home/raw/test"  	# Path to the parent directory. It is not the directory where are stored the fastqs. Should NOT finish with "/"
fastq_directory="06152023_CO1_fastq"	# Name of the folder containing the fastqs. It must be located in the parent directory.
fastqPATH=$workingPATH/$fastq_directory
project_shortname="06152023_CO1"

taxonomy="CO1_UCLA" #put only base name of taxonomy
taxonomy_names=$workingPATH/$taxonomy"-tax.qza" #include file type!
taxonomy_fasta=$workingPATH/$taxonomy"-seqs.qza" #include file type!
#https://ucla.app.box.com/v/CO1-July-2019/folder/89496025519

import_tax_yes_no="yes" #only options are "yes" (taxonomy is in fasta/txt) or "no" (taxonomy is in qza)
#fill out below if "yes"
taxonomy_names1=$workingPATH/$taxonomy"-tax.txt" #include file type!
taxonomy_fasta1=$workingPATH/$taxonomy"-seqs.fasta" #include file type!

#fill out below for specific targets
primerF=GGWACWGGWTGAACWGTWTAYCCYCC       #forward primer
primerR=GGRGGRTASACSGTTCASCCSGTSCC            #reverse primer
errorR=0.1                                #error rates (0-1)
trimF=0                                   #trim 3' end of forward primer
trimR=0                                   #trim 3' end of reverse primer
lengthF=242                               #truncate 5' end of forward primer
lengthR=192                               #truncate 5' end of reverse primer
truncQ=2

id=0.95                                   #max similarity id (0.9-1)
length_min=$lengthF
length_max=450                            #max length of taxonomic reads
jobs_num=20                               #number of job for computer (parallel)
batch_size="auto"
orientation="forward"                     #orientatino of taxonomic reads
chunk=20000                               #chunk of reads for making classifier (parallel)

############## source shell script with qiime commands ##############
#. ./SCCWRP_QIIME2_runfile.sh

. ./SCCWRP_QIIME2_runfile_no_tax.sh
