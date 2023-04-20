#!/bin/bash

#conda activate qiime2-2021.11 <----- MUST CONDA ACTIVATE BEORE RUNNING SCRIPT

homePATH="/home/kyliel"
workingPATH="/home/kyliel/03292023_CO1"  	# Path to the parent directory. It is not the directory where are stored the fastqs. Should NOT finish with "/"
fastq_directory="03292023_CO1_fastq"	# Name of the folder containing the fastqs. It must be located in the parent directory.
fastqPATH=$workingPATH/$fastq_directory
project_shortname="03292023_CO1"

taxonomy="bold_derep1" #put only base name of taxonomy
taxonomy_names=$homePATH/$taxonomy"_taxa.qza" #include file type!
taxonomy_fasta=$homePATH/$taxonomy"_seqs.qza" #include file type!

import_tax_yes_no="no" #only options are "yes" (taxonomy is in fasta/txt) or "no" (taxonomy is in qza)
#fill out below if "yes"
taxonomy_names1=$homePATH/$taxonomy"-tax.tsv" #include file type!
taxonomy_fasta1=$homePATH/$taxonomy"-seqs.fasta" #include file type!

#fill out below with specifics for primer set of interest
primerF=GGDACWGGWTGAACWGTWTAYCCHCC       #forward primer
primerR=CAAACAAATARDGGTATTCGDTY            #reverse primer
id=0.97                                   #max similarity id (0.9-1)
length_min=200
length_max=450                            #max length of taxonomic reads
jobs_num=20                               #number of job for computer (parallel)
batch_size="auto"
orientation="forward"                     #orientatino of taxonomic reads
chunk=20000                               #chunk of reads for making classifier (parallel)

######################################
#taxonomy sourced from https://forum.qiime2.org/t/building-a-coi-database-from-bold-references/16129
#bold_rawSeqs.qza and bold_rawTaxa.qza used
#bold_rawSeqs.qza = aligned sequences, cannot use to create QIIME2 classifier

qiime tools export --input-path bold_derep1_seqs.qza --output-path bold_derep1_seqs.fasta
awk 'NR==1 {print;next} /^>/ {ORS="\n"; print "\n"$0;next} {ORS=""; gsub(/\.|-/,"")}1' < bold_derep1_seqs/bold_derep1_seqs.fasta > bold_derep1_unaligned_seqs.fasta
qiime tools import --input-path bold_derep1_unaligned_seqs.fasta --type 'FeatureData[Sequence]' --output-path bold_derep1_unaligned_seqs.qza

#qiime feature-classifier extract-reads \ #<--- never completed, discarded
#--i-sequences bold_derep1_unaligned_seqs.qza \
#--p-f-primer GGDACWGGWTGAACWGTWTAYCCHCC \
#--p-r-primer CAAACAAATARDGGTATTCGDTY \
#--p-identity 0.97 \
#--p-min-length 200 \
#--p-max-length 450 \
#--p-n-jobs 20 \
#--p-batch-size 10000 \
#--p-read-orientation "forward" \
#--verbose \
#--output-dir bold_derep1_unaligned_extracted_seqs

#qiime feature-classifier fit-classifier-naive-bayes \ #<--- memory error, discarded
#--i-reference-taxonomy bold_derep1_taxa.qza \
#--i-reference-reads bold_derep1_seqs.qza \
#--p-verbose \
#--o-classifier bold_derep1_seqs_NB_classifier

qiime feature-classifier classify-consensus-blast \
--i-query 03292023_CO1/03292023_CO1_trim_dada2_rep_seq.qza \
--i-reference-taxonomy bold_derep1_taxa.qza \
--i-reference-reads bold_derep1_seqs.qza \
--output-dir CO1_bold_depep1_blast_taxonomy_90 \
--p-perc-identity 0.90 \
--p-maxaccepts 1
