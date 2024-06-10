#!/bin/bash

#MUST DO BEFORE:
#conda create -n multiqc_env -c bioconda -c conda-forge fastqc multiqc cutadapt
#conda activate multiqc
#export LC_ALL=en_US.UTF-8
#export LANG=en_US.UTF-8

project_shortname="biofilm_062923_500v600"
workingPATH="/home/genomics/raw/biofilm_062923_500v600" 	# Path to the parent directory. It is not the directory where are stored the fastqs. Should NOT finish with "/"
fastq_directory=$workingPATH/"Apr_2023_V4V5_500_cycle_fastq"	# Name of the folder containing the fastqs. It must be located in the parent directory.
scriptsPATH="/home/genomics/scripts/cutadapt-FASTQC-multiQC-dada2_scripts_2023"

#cutadapt--------
cd $fastq_directory
for f in *R1_001.fastq.gz; do

    n=`echo $f | rev | cut -d _ -f 3- | rev` &&

    cutadapt -j 8 -g GTGYCAGCMGCCGCGGTAA -G CCGYCAATTYMTTTRAGTTT -o $n'_R1_001_trimmed.fastq.gz' -p $n'_R2_001_trimmed.fastq.gz' $f $n'_R2_001.fastq.gz'

done

#read 1 fastqc, multiqc-------------------
cd $fastq_directory

mkdir fastqc-R1
fastqc *_R1_001_trimmed.fastq.gz -o fastqc-R1
cd fastqc-R1
multiqc --export .

#read 2 fastqc, multiqc-------------------
cd ..
mkdir fastqc-R2
fastqc *_R2_001_trimmed.fastq.gz -o fastqc-R2
cd fastqc-R2
multiqc --export .

#run helper R script to get quality scores-------------------
fastqcPATH_R1=$fastq_directory/"fastqc-R1/multiqc_data"
fastqcPATH_R2=$fastq_directory/"fastqc-R2/multiqc_data"

cd $scriptsPATH
Rscript --vanilla fastqc_per_base_quality_max.R ${fastq_directory} ${fastqcPATH_R1} ${fastqcPATH_R2}
MAX_Q1=$(sed '2q;d' $fastq_directory/maxQ_R1.txt)
MAX_Q2=$(sed '2q;d' $fastq_directory/maxQ_R2.txt)

Q1_90=$(echo "$MAX_Q1 * 0.9" | bc)
Q1_75=$(echo "$MAX_Q1 * 0.75" | bc)
Q1_50=$(echo "$MAX_Q1 * 0.5" | bc)
Q2_90=$(echo "$MAX_Q2 * 0.9" | bc)
Q2_75=$(echo "$MAX_Q2 * 0.75" | bc)
Q2_50=$(echo "$MAX_Q2 * 0.5" | bc)

printf "\n"
paste <(echo "cut-off") <(echo "") <(echo "read1") <(echo "read2")
paste <(echo "") <(echo "max") <(printf %s "$MAX_Q1") <(printf %s "$MAX_Q2")
paste <(echo "") <(echo "90%") <(printf %s "$Q1_90") <(printf %s "$Q2_90")
paste <(echo "") <(echo "75%") <(printf %s "$Q1_75") <(printf %s "$Q2_75")
paste <(echo "") <(echo "50%") <(printf %s "$Q1_50") <(printf %s "$Q2_50")
printf "\n"

#run dada2 with filter scores-------------------
cd $scriptsPATH
Rscript --vanilla dada2_runfile2.r ${fastq_directory} ${Q1_90} ${Q2_90}
DADA2_VAR_90=$(sed '2q;d' $fastq_directory/average_quality.txt)
rm $fastq_directory/filtered/*_filt.fastq.gz
rmdir $fastq_directory/filtered

Rscript --vanilla dada2_runfile2.r ${fastq_directory} ${Q1_75} ${Q2_75}
DADA2_VAR_75=$(sed '2q;d' $fastq_directory/average_quality.txt)
rm $fastq_directory/filtered/*_filt.fastq.gz
rmdir $fastq_directory/filtered

Rscript --vanilla dada2_runfile2.r ${fastq_directory} ${Q1_50} ${Q2_50}
DADA2_VAR_50=$(sed '2q;d' $fastq_directory/average_quality.txt)
rm $fastq_directory/filtered/*_filt.fastq.gz
rmdir $fastq_directory/filtered

#print values from dada2-------------------
printf "\n"
paste <(echo "cut-off") <(echo "") <(echo "perc. retain")
paste <(echo "") <(echo "90%")  <(printf %s "$DADA2_VAR_90")
paste <(echo "") <(echo "75%")  <(printf %s "$DADA2_VAR_75")
paste <(echo "") <(echo "50%")  <(printf %s "$DADA2_VAR_50")
printf "\n"


exit 0
