#!/bin/bash

#MUST DO BEFORE:
#conda create -n multiqc_env -c bioconda -c conda-forge fastqc multiqc cutadapt
#conda activate multiqc_env
#export LC_ALL=en_US.UTF-8
#export LANG=en_US.UTF-8

#computer information-------------------
rawPATH="/home/genomics/raw/biofilm_demux_indiv" 	# Path to the parent directory. It is not the directory where are stored the fastqs. Should NOT finish with "/"
scriptsPATH="/home/genomics/scripts/cutadapt-FASTQC-multiQC-dada2_scripts_2023" #where scripts are located; must contain fastqc_per_base_sequence_quality_dropoff.py dada2_runfile.r Should NOT finish with "/"
processedPATH="/home/genomics/processed" # Path to the processed files will be housed. Should NOT finish with "/"

#user input-------------------
project_shortname="16S_V4V5_Aug2022" #PUT PROJECT SHORT NAME HERE
fastq_directory=$rawPATH/"Aug_2022_V4V5_demux"	# Name of the folder containing the fastqs. It must be located in the parent directory. Should NOT finish with "/"
processed_directory=$processedPATH/$project_shortname #Name of folder that will contain processed files
trimmed_fastqPATH=$processed_directory/"trimmed_fastq"
primerF="GTGYCAGCMGCCGCGGTAA" #forward primer
primerR="GGACTACNVGGGTWTCTAAT" #reverse primer

mkdir $processed_directory

#cutadapt--------
cd $fastq_directory

for f in *R1_001.fastq.gz; do

    n=`echo $f | rev | cut -d _ -f 3- | rev` &&

    cutadapt -j 8 -g $primerF -G $primerR -o $n'_R1_001_trimmed.fastq.gz' -p $n'_R2_001_trimmed.fastq.gz' $f $n'_R2_001.fastq.gz'

done

mkdir $processed_directory/"trimmed_fastq"
mv *_trimmed.fastq.gz $processed_directory/"trimmed_fastq"/

#read 1 fastqc, multiqc-------------------
cd $processed_directory/"trimmed_fastq"

mkdir $processed_directory/fastqc-R1
fastqc *_R1_001_trimmed.fastq.gz -o $processed_directory/fastqc-R1

cd $processed_directory/fastqc-R1
multiqc --export .
FASTQC_VAR1_50=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py  --input $processed_directory/"fastqc-R1/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.50)
FASTQC_VAR1_75=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py  --input $processed_directory/"fastqc-R1/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.75)
FASTQC_VAR1_85=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py  --input $processed_directory/"fastqc-R1/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.85)
FASTQC_VAR1_90=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py  --input $processed_directory/"fastqc-R1/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.90)

#read 2 fastqc, multiqc-------------------
cd $processed_directory/"trimmed_fastq"

mkdir $processed_directory/fastqc-R2
fastqc *_R2_001_trimmed.fastq.gz -o $processed_directory/fastqc-R2

cd $processed_directory/fastqc-R2
multiqc --export .
FASTQC_VAR2_50=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py --input $processed_directory/"fastqc-R2/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.50)
FASTQC_VAR2_75=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py --input $processed_directory/"fastqc-R2/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.75)
FASTQC_VAR2_85=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py --input $processed_directory/"fastqc-R2/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.85)
FASTQC_VAR2_90=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py --input $processed_directory/"fastqc-R2/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.90)

#run dada2 filterandtrim-------------------
cd $scriptsPATH
Rscript --vanilla dada2_runfile.r ${trimmed_fastqPATH} ${FASTQC_VAR1_50} ${FASTQC_VAR2_50}
DADA2_VAR_50=$(sed '2q;d' $trimmed_fastqPATH/average_quality.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

cd $scriptsPATH
Rscript --vanilla dada2_runfile.r ${trimmed_fastqPATH} ${FASTQC_VAR1_75} ${FASTQC_VAR2_50}
DADA2_VAR_75_50=$(sed '2q;d' $trimmed_fastqPATH/average_quality.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

Rscript --vanilla dada2_runfile.r ${trimmed_fastqPATH} ${FASTQC_VAR1_75} ${FASTQC_VAR2_75}
DADA2_VAR_75=$(sed '2q;d' $trimmed_fastqPATH/average_quality.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

Rscript --vanilla dada2_runfile.r ${trimmed_fastqPATH} ${FASTQC_VAR1_85} ${FASTQC_VAR2_75}
DADA2_VAR_85_75=$(sed '2q;d' $trimmed_fastqPATH/average_quality.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

Rscript --vanilla dada2_runfile.r ${trimmed_fastqPATH} ${FASTQC_VAR1_85} ${FASTQC_VAR2_85}
DADA2_VAR_85=$(sed '2q;d' $trimmed_fastqPATH/average_quality.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

Rscript --vanilla dada2_runfile.r ${trimmed_fastqPATH} ${FASTQC_VAR1_90} ${FASTQC_VAR2_85}
DADA2_VAR_90_85=$(sed '2q;d' $trimmed_fastqPATH/average_quality.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

Rscript --vanilla dada2_runfile.r ${trimmed_fastqPATH} ${FASTQC_VAR1_90} ${FASTQC_VAR2_90}
DADA2_VAR_90=$(sed '2q;d' $trimmed_fastqPATH/average_quality.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered


#print values from multiqc-------------------
printf "\n"
paste <(echo "cut-off") <(echo "") <(echo "read1") <(echo "read2") <(echo "perc. retain")
paste <(echo "") <(echo "50%") <(printf %s "$FASTQC_VAR1_50") <(printf %s "$FASTQC_VAR2_50") <(printf %s "$DADA2_VAR_50")
paste <(echo "") <(echo "50/75%") <(printf %s "$FASTQC_VAR1_75") <(printf %s "$FASTQC_VAR2_50") <(printf %s "$DADA2_VAR_75_50")
paste <(echo "") <(echo "75%") <(printf %s "$FASTQC_VAR1_75") <(printf %s "$FASTQC_VAR2_75") <(printf %s "$DADA2_VAR_75")
paste <(echo "") <(echo "75/85%") <(printf %s "$FASTQC_VAR1_85") <(printf %s "$FASTQC_VAR2_75") <(printf %s "$DADA2_VAR_85_75")
paste <(echo "") <(echo "85%") <(printf %s "$FASTQC_VAR1_85") <(printf %s "$FASTQC_VAR2_85") <(printf %s "$DADA2_VAR_85")
paste <(echo "") <(echo "85/90%") <(printf %s "$FASTQC_VAR1_90") <(printf %s "$FASTQC_VAR2_85") <(printf %s "$DADA2_VAR_90_85")
paste <(echo "") <(echo "90%") <(printf %s "$FASTQC_VAR1_90") <(printf %s "$FASTQC_VAR2_90") <(printf %s "$DADA2_VAR_90")
printf "\n"


exit 0
