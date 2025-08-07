#!/bin/bash

#MUST DO BEFORE:
#conda create -n multiqc_env -c bioconda -c conda-forge fastqc multiqc cutadapt
#conda activate multiqc_env
#export LC_ALL=en_US.UTF-8
#export LANG=en_US.UTF-8

#computer information-------------------
rawPATH="/home/genomics/raw" 	# Path to the parent directory. It is not the directory where are stored the fastqs. Should NOT finish with "/"
scriptsPATH="/home/genomics/scripts/cutadapt-FASTQC-multiQC-dada2_scripts" #where scripts are located; must contain fastqc_per_base_sequence_quality_dropoff.py dada2_runfile.r Should NOT finish with "/"
processedPATH="/home/genomics/processed" # Path to the processed files will be housed. Should NOT finish with "/"

#user input-------------------
project_shortname="R1_anaC_012623" #PUT PROJECT SHORT NAME HERE
fastq_directory=$rawPATH/"BGC_R1_anaC_012623/fastq_files"	# Name of the folder containing the fastqs. It must be located in the parent directory. Should NOT finish with "/"
processed_directory=$processedPATH/$project_shortname #Name of folder that will contain processed files
trimmed_fastqPATH=$processed_directory/"trimmed_fastq"
primerF="TCTGGTATTCAGTCCCCTCTAT" #forward primer
primerR="CCCAATAGCCTGTCATCAA" #reverse primer

#mkdir $processed_directory


#read 1 fastqc, multiqc-------------------
cd $processed_directory/fastqc-R1

FASTQC_VAR1_95=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py  --input $processed_directory/"fastqc-R1/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.95)
FASTQC_VAR1_99=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py  --input $processed_directory/"fastqc-R1/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.99)

#read 2 fastqc, multiqc-------------------
cd $processed_directory/fastqc-R2

FASTQC_VAR2_95=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py --input $processed_directory/"fastqc-R2/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.95)
FASTQC_VAR2_99=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py --input $processed_directory/"fastqc-R2/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 0.99)

#run dada2 filterandtrim-------------------
cd $scriptsPATH
Rscript --vanilla dada2_runfile.r ${trimmed_fastqPATH} ${FASTQC_VAR1_95} ${FASTQC_VAR2_95}
DADA2_VAR_95=$(sed '2q;d' $trimmed_fastqPATH/average_quality.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

cd $scriptsPATH
Rscript --vanilla dada2_runfile.r ${trimmed_fastqPATH} ${FASTQC_VAR1_95} ${FASTQC_VAR2_99}
DADA2_VAR_95_99=$(sed '2q;d' $trimmed_fastqPATH/average_quality.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

Rscript --vanilla dada2_runfile.r ${trimmed_fastqPATH} ${FASTQC_VAR1_99} ${FASTQC_VAR2_99}
DADA2_VAR_99=$(sed '2q;d' $trimmed_fastqPATH/average_quality.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

Rscript --vanilla dada2_runfile.r ${trimmed_fastqPATH} ${FASTQC_VAR1_99} ${FASTQC_VAR2_95}
DADA2_VAR_99_95=$(sed '2q;d' $trimmed_fastqPATH/average_quality.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered


#print values from multiqc-------------------
printf "\n"
paste <(echo "cut-off") <(echo "") <(echo "read1") <(echo "read2") <(echo "perc. retain")
paste <(echo "") <(echo "95%") <(printf %s "$FASTQC_VAR1_95") <(printf %s "$FASTQC_VAR2_95") <(printf %s "$DADA2_VAR_95")
paste <(echo "") <(echo "95/99%") <(printf %s "$FASTQC_VAR1_95") <(printf %s "$FASTQC_VAR2_99") <(printf %s "$DADA2_VAR_95_99")
paste <(echo "") <(echo "99%") <(printf %s "$FASTQC_VAR1_99") <(printf %s "$FASTQC_VAR2_99") <(printf %s "$DADA2_VAR_99")
paste <(echo "") <(echo "99%/95%") <(printf %s "$FASTQC_VAR1_99") <(printf %s "$FASTQC_VAR2_95") <(printf %s "$DADA2_VAR_99_95")
printf "\n"


exit 0
