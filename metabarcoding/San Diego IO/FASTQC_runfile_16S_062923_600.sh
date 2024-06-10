#!/bin/bash

#MUST DO BEFORE:
#conda create -n multiqc_env -c bioconda -c conda-forge fastqc multiqc cutadapt
#conda activate multiqc
#export LC_ALL=en_US.UTF-8
#export LANG=en_US.UTF-8

project_shortname="biofilm_062923_600"
workingPATH="/home/genomics/raw/biofilm_062923_500v600" 	# Path to the parent directory. It is not the directory where are stored the fastqs. Should NOT finish with "/"
fastq_directory=$workingPATH/"Apr_2023_V4V5_600_cycle_fastq"	# Name of the folder containing the fastqs. It must be located in the parent directory.
scriptsPATH="/home/genomics/scripts/cutadapt-FASTQC-multiQC-dada2_scripts_2023"

#cutadapt--------
#cd $fastq_directory
#for f in *R1_001.fastq.gz; do

#    n=`echo $f | rev | cut -d _ -f 3- | rev` &&

#    cutadapt -j 8 -g AGGTGAAGTAAAAGGTTCWTACTTAAA -G CCTTCTAATTTACCWACWACTG -o $n'_R1_001_trimmed.fastq.gz' -p $n'_R2_001_trimmed.fastq.gz' $f $n'_R2_001.fastq.gz'

#done

#read 1 fastqc, multiqc-------------------
cd $fastq_directory

mkdir fastqc-R1
fastqc *_R1_001_trimmed.fastq.gz -o fastqc-R1
cd fastqc-R1
multiqc --export .
FASTQC_VAR1_50=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py  --input $fastq_directory/"fastqc-R1/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.50)
FASTQC_VAR1_75=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py  --input $fastq_directory/"fastqc-R1/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.75)
FASTQC_VAR1_85=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py  --input $fastq_directory/"fastqc-R1/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.85)
FASTQC_VAR1_95=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py  --input $fastq_directory/"fastqc-R1/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.95)

#read 2 fastqc, multiqc-------------------
cd ..
mkdir fastqc-R2
fastqc *_R2_001_trimmed.fastq.gz -o fastqc-R2
cd fastqc-R2
multiqc --export .
FASTQC_VAR2_50=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py --input $fastq_directory/"fastqc-R2/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.50)
FASTQC_VAR2_75=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py --input $fastq_directory/"fastqc-R2/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.75)
FASTQC_VAR2_85=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py --input $fastq_directory/"fastqc-R2/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.85)
FASTQC_VAR2_95=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py --input $fastq_directory/"fastqc-R2/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.95)

#run dada2 filterandtrim-------------------
cd $scriptsPATH
Rscript --vanilla dada2_runfile.r ${fastq_directory} ${FASTQC_VAR1_50} ${FASTQC_VAR2_50}
DADA2_VAR_50=$(sed '2q;d' $fastq_directory/average_quality.txt)
rm $fastq_directory/filtered/*_filt.fastq.gz
rmdir $fastq_directory/filtered

Rscript --vanilla dada2_runfile.r ${fastq_directory} ${FASTQC_VAR1_75} ${FASTQC_VAR2_75}
DADA2_VAR_75=$(sed '2q;d' $fastq_directory/average_quality.txt)
rm $fastq_directory/filtered/*_filt.fastq.gz
rmdir $fastq_directory/filtered


Rscript --vanilla dada2_runfile.r ${fastq_directory} ${FASTQC_VAR1_85} ${FASTQC_VAR2_85}
DADA2_VAR_85=$(sed '2q;d' $fastq_directory/average_quality.txt)
rm $fastq_directory/filtered/*_filt.fastq.gz
rmdir $fastq_directory/filtered


Rscript --vanilla dada2_runfile.r ${fastq_directory} ${FASTQC_VAR1_95} ${FASTQC_VAR2_95}
DADA2_VAR_95=$(sed '2q;d' $fastq_directory/average_quality.txt)
rm $fastq_directory/filtered/*_filt.fastq.gz
rmdir $fastq_directory/filtered


#print values from multiqc-------------------
printf "\n"
paste <(echo "cut-off") <(echo "") <(echo "read1") <(echo "read2") <(echo "perc. retain")
paste <(echo "") <(echo "80%") <(printf %s "$FASTQC_VAR1_50") <(printf %s "$FASTQC_VAR2_50") <(printf %s "$DADA2_VAR_50")
paste <(echo "") <(echo "85%") <(printf %s "$FASTQC_VAR1_75") <(printf %s "$FASTQC_VAR2_75") <(printf %s "$DADA2_VAR_75")
paste <(echo "") <(echo "90%") <(printf %s "$FASTQC_VAR1_85") <(printf %s "$FASTQC_VAR2_85") <(printf %s "$DADA2_VAR_85")
paste <(echo "") <(echo "95%") <(printf %s "$FASTQC_VAR1_95") <(printf %s "$FASTQC_VAR2_95") <(printf %s "$DADA2_VAR_95")
printf "\n"


exit 0
