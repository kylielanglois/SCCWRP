#!/bin/bash

#conda activate multiqc_env
#ONLY TO BE USED IF "FASTQC_runfile.sh" HAS ALREADY BEEN run
#NEED A PRIORI KNOWLEDGE FOR TRIM LENGTHS IN DADA2
#PRIMERS MUST BE REMOVED, FASTQC FOLDER CREATED

#computer information-------------------
rawPATH="/home/genomics/raw" 	# Path to the parent directory. It is not the directory where are stored the fastqs. Should NOT finish with "/"
scriptsPATH="/home/genomics/scripts/cutadapt-FASTQC-multiQC-dada2_scripts" #where scripts are located; must contain fastqc_per_base_sequence_quality_dropoff.py dada2_runfile2_16S_eDNAdecay_102924.r Should NOT finish with "/"
processedPATH="/home/genomics/processed" # Path to the processed files will be housed. Should NOT finish with "/"

#user input-------------------
project_shortname="BIO_CTAB_16S_012925" #PUT PROJECT SHORT NAME HERE
fastq_directory=$rawPATH/"BIO_CTAB_16S_012925/fastq_16S"	# Name of the folder containing the fastqs. It must be located in the parent directory. Should NOT finish with "/"
processed_directory=$processedPATH/$project_shortname #Name of folder that will contain processed files
trimmed_fastqPATH=$processed_directory/"trimmed_fastq"

ampliconL=250 #number, must be 300 or 250

FOR_TRIM1=5  #number
FOR_TRIM2=10 #number
FOR_TRIM3=15  #number
FOR_TRIM4=20  #number
FOR_TRIM5=25  #number
FOR_TRIM6=30  #number

REV_TRIM1=10  #number
REV_TRIM2=20  #number
REV_TRIM3=30  #number
REV_TRIM4=40  #number
REV_TRIM5=50  #number
REV_TRIM6=50  #number

#multiqc-------------------
cd $processed_directory/fastqc-R1
FASTQC_VAR1=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py  --input $processed_directory/"fastqc-R1/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 1)
echo $FASTQC_VAR1

cd $processed_directory/fastqc-R2
FASTQC_VAR2=$($scriptsPATH/fastqc_per_base_sequence_quality_dropoff.py --input $processed_directory/"fastqc-R2/multiqc_data/mqc_fastqc_per_base_sequence_quality_plot_1.txt" --cutoff 1)
echo $FASTQC_VAR2

#get trim length-------------------
TRIM1_VAR0="$(($ampliconL - $FASTQC_VAR1))"
TRIM1_VAR1="$(($ampliconL - $FASTQC_VAR1-$FOR_TRIM1))"
TRIM1_VAR2="$(($ampliconL - $FASTQC_VAR1-$FOR_TRIM2))"
TRIM1_VAR3="$(($ampliconL - $FASTQC_VAR1-$FOR_TRIM3))"
TRIM1_VAR4="$(($ampliconL - $FASTQC_VAR1-$FOR_TRIM4))"
TRIM1_VAR5="$(($ampliconL - $FASTQC_VAR1-$FOR_TRIM5))"
TRIM1_VAR6="$(($ampliconL - $FASTQC_VAR1-$FOR_TRIM6))"

TRIM2_VAR0="$(($ampliconL - $FASTQC_VAR2))"
TRIM2_VAR1="$(($ampliconL - $FASTQC_VAR2-$REV_TRIM1))"
TRIM2_VAR2="$(($ampliconL - $FASTQC_VAR2-$REV_TRIM2))"
TRIM2_VAR3="$(($ampliconL - $FASTQC_VAR2-$REV_TRIM3))"
TRIM2_VAR4="$(($ampliconL - $FASTQC_VAR2-$REV_TRIM4))"
TRIM2_VAR5="$(($ampliconL - $FASTQC_VAR2-$REV_TRIM5))"
TRIM2_VAR6="$(($ampliconL - $FASTQC_VAR2-$REV_TRIM6))"

#run dada2 filterandtrim-------------------
Rscript --vanilla dada2_runfile2.r ${trimmed_fastqPATH} ${TRIM1_VAR0} ${TRIM2_VAR0}
DADA2_VAR_0=$(sed '2q;d' $trimmed_fastqPATH/average_quality_V2.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

cd $scriptsPATH
Rscript --vanilla dada2_runfile2.r ${trimmed_fastqPATH} ${TRIM1_VAR1} ${TRIM2_VAR1}
DADA2_VAR_1=$(sed '2q;d' $trimmed_fastqPATH/average_quality_V2.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

cd $scriptsPATH
Rscript --vanilla dada2_runfile2.r ${trimmed_fastqPATH} ${TRIM1_VAR1} ${TRIM2_VAR2}
DADA2_VAR_2=$(sed '2q;d' $trimmed_fastqPATH/average_quality_V2.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

cd $scriptsPATH
Rscript --vanilla dada2_runfile2.r ${trimmed_fastqPATH} ${TRIM1_VAR2} ${TRIM2_VAR2}
DADA2_VAR_3=$(sed '2q;d' $trimmed_fastqPATH/average_quality_V2.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

cd $scriptsPATH
Rscript --vanilla dada2_runfile2.r ${trimmed_fastqPATH} ${TRIM1_VAR2} ${TRIM2_VAR3}
DADA2_VAR_4=$(sed '2q;d' $trimmed_fastqPATH/average_quality_V2.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

cd $scriptsPATH
Rscript --vanilla dada2_runfile2.r ${trimmed_fastqPATH} ${TRIM1_VAR3} ${TRIM2_VAR3}
DADA2_VAR_5=$(sed '2q;d' $trimmed_fastqPATH/average_quality_V2.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

cd $scriptsPATH
Rscript --vanilla dada2_runfile2.r ${trimmed_fastqPATH} ${TRIM1_VAR3} ${TRIM2_VAR4}
DADA2_VAR_6=$(sed '2q;d' $trimmed_fastqPATH/average_quality_V2.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

cd $scriptsPATH
Rscript --vanilla dada2_runfile2.r ${trimmed_fastqPATH} ${TRIM1_VAR4} ${TRIM2_VAR4}
DADA2_VAR_7=$(sed '2q;d' $trimmed_fastqPATH/average_quality_V2.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

cd $scriptsPATH
Rscript --vanilla dada2_runfile2.r ${trimmed_fastqPATH} ${TRIM1_VAR4} ${TRIM2_VAR5}
DADA2_VAR_8=$(sed '2q;d' $trimmed_fastqPATH/average_quality_V2.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

cd $scriptsPATH
Rscript --vanilla dada2_runfile2.r ${trimmed_fastqPATH} ${TRIM1_VAR5} ${TRIM2_VAR5}
DADA2_VAR_9=$(sed '2q;d' $trimmed_fastqPATH/average_quality_V2.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

cd $scriptsPATH
Rscript --vanilla dada2_runfile2.r ${trimmed_fastqPATH} ${TRIM1_VAR5} ${TRIM2_VAR6}
DADA2_VAR_10=$(sed '2q;d' $trimmed_fastqPATH/average_quality_V2.txt)
rm $trimmed_fastqPATH/filtered/*_filt.fastq.gz
rmdir $trimmed_fastqPATH/filtered

#print values from multiqc-------------------
printf "\n"
paste <(echo "cut-off") <(echo "") <(echo "read1") <(echo "read2") <(echo "perc. retain")
paste <(echo "") <(echo "TOP")                <(printf %s "$FASTQC_VAR1") <(printf %s "$FASTQC_VAR2") <(printf %s "$DADA2_VAR_0")
paste <(echo "") <(echo "TOP-V1")             <(printf %s "$TRIM1_VAR1") <(printf %s "$TRIM2_VAR1") <(printf %s "$DADA2_VAR_1")
paste <(echo "") <(echo "TOP-V1/TOP-V2")      <(printf %s "$TRIM1_VAR1") <(printf %s "$TRIM2_VAR2") <(printf %s "$DADA2_VAR_2")
paste <(echo "") <(echo "TOP-V2")             <(printf %s "$TRIM1_VAR2") <(printf %s "$TRIM2_VAR2") <(printf %s "$DADA2_VAR_3")
paste <(echo "") <(echo "TOP-V2/TOP-V3")      <(printf %s "$TRIM1_VAR2") <(printf %s "$TRIM2_VAR3") <(printf %s "$DADA2_VAR_4")
paste <(echo "") <(echo "TOP-V3")             <(printf %s "$TRIM1_VAR3") <(printf %s "$TRIM2_VAR3") <(printf %s "$DADA2_VAR_5")
paste <(echo "") <(echo "TOP-V3/TOP-V4")      <(printf %s "$TRIM1_VAR3") <(printf %s "$TRIM2_VAR4") <(printf %s "$DADA2_VAR_6")
paste <(echo "") <(echo "TOP-V4")             <(printf %s "$TRIM1_VAR4") <(printf %s "$TRIM2_VAR4") <(printf %s "$DADA2_VAR_7")
paste <(echo "") <(echo "TOP-V4/TOP-V5")      <(printf %s "$TRIM1_VAR4") <(printf %s "$TRIM2_VAR5") <(printf %s "$DADA2_VAR_8")
paste <(echo "") <(echo "TOP-V5")             <(printf %s "$TRIM1_VAR5") <(printf %s "$TRIM2_VAR5") <(printf %s "$DADA2_VAR_9")
paste <(echo "") <(echo "TOP-V5/TOP-V6")      <(printf %s "$TRIM1_VAR5") <(printf %s "$TRIM2_VAR6") <(printf %s "$DADA2_VAR_10")
printf "\n"


exit 0
