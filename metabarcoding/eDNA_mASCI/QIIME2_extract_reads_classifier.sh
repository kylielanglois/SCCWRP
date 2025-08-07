#!/bin/bash

#conda activate qiime2-2022.2 <----- or most updated qiime2 image

taxPATH="/home/genomics/raw/taxonomy_databases" # Path to the parent directory.  Should NOT finish with "/"

##### database specific #####
refSeq=$taxPATH/"12S_MareMage_fasta" #Path to the sample sequences are stored. Should NOT finish with "/"
refTax=$taxPATH
refName="MiFish" #name of assay

printf "\n"
paste <(echo "file paths read")
printf "\n"

##### parameters #####
primerF="GCCGGTAAAACTCGTGCCAGC" #forward primer             <-MiFish F
primerR="CATAGTGGGGTATCTAATCCCAGTTTG" #reverse primer       <-MiFish R
truncLen=300
lengthMin=200
lengthMax=400

printf "\n"
paste <(echo "parameters read")
printf "\n"

#qiime tools import \
#--type 'FeatureData[Sequence]' \
#--input-path $taxPATH/$refSeq".fasta" \
#--output-path $taxPATH/$refSeq".qza"

qiime feature-classifier extract-reads \
--i-sequences $refSeq".qza" \
--p-f-primer $primerF \
--p-r-primer $primerR \
--p-trunc-len $truncLen \
--p-min-length $lengthMin \
--p-max-length $lengthMax \
--p-n-jobs 4 \
--o-reads $refSeq"_"$refName"_extract.qza"

#qiime tools export --input-path $workingPATH/$project_shortname"_trim_dada2_table.qza" \
#--output-path $workingPATH/$project_shortname"_trim_dada2_table_exported"
