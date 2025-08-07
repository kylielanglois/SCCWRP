#!/bin/bash

#conda activate qiime2-amplicon-2024.5 <----- or most updated qiime2 image

#computer information-------------------
processedPATH="/home/genomics/processed" # Path to the processed files will be housed. Should NOT finish with "/"
scriptsPATH="/home/genomics/scripts/QIIME2_scripts" #where scripts are located;  Should NOT finish with "/"

#user input-------------------
project_shortname="BIO_eDNA_field_12S_16S" #PUT PROJECT SHORT NAME HERE
processed_directory=$processedPATH/"BIO_eDNA_field_12S_16S" #Name of folder that will contain processed files

cd $processed_directory

#manually change .csv merger tables to .txt (tab delimited)
table1="BIO_eDNA_032425_12S_dada2_merger10_table"
table2="eDNA_CTAB_12S_012925_merger_12_table"
table3="BIO_eDNA_032425_16S_dada2_merger8_table"
table4="eDNA_CTAB_16S_012925_merger_8_table"
#table5="SDIO_062920_90_merger"
#table6="SDIO_081221_90_merger"
#table7="SDIO_Apr2023_95_merger"
#table8="SDIO_Aug2023_85_90_merger"
#table9="SDIO_revisits21newnames2024_NA_merger"

biom convert -i $table1".txt" -o $table1".biom" --table-type="OTU table" --to-hdf5
biom convert -i $table2".txt" -o $table2".biom" --table-type="OTU table" --to-hdf5
biom convert -i $table3".txt" -o $table3".biom" --table-type="OTU table" --to-hdf5
biom convert -i $table4".txt" -o $table4".biom" --table-type="OTU table" --to-hdf5
#biom convert -i $table5".txt" -o $table5".biom" --table-type="OTU table" --to-hdf5
#biom convert -i $table6".txt" -o $table6".biom" --table-type="OTU table" --to-hdf5
#biom convert -i $table7".txt" -o $table7".biom" --table-type="OTU table" --to-hdf5
#biom convert -i $table8".txt" -o $table8".biom" --table-type="OTU table" --to-hdf5
#biom convert -i $table9".txt" -o $table9".biom" --table-type="OTU table" --to-hdf5

qiime tools import \
  --input-path $table1".biom" \
  --type 'FeatureTable[Frequency]' \
  --input-format BIOMV210Format \
  --output-path $table1".qza"
qiime tools import \
  --input-path $table2".biom" \
  --type 'FeatureTable[Frequency]' \
  --input-format BIOMV210Format \
  --output-path $table2".qza"
qiime tools import \
  --input-path $table3".biom" \
  --type 'FeatureTable[Frequency]' \
  --input-format BIOMV210Format \
  --output-path $table3".qza"
qiime tools import \
  --input-path $table4".biom" \
  --type 'FeatureTable[Frequency]' \
  --input-format BIOMV210Format \
  --output-path $table4".qza"

#16S------
qiime feature-table merge \
  --i-tables $table3".qza" $table4".qza"  \
  --p-overlap-method 'sum' \
  --o-merged-table BIO_eDNA_field_16S_combo_merger.qza

qiime tools export --input-path BIO_eDNA_field_16S_combo_merger.qza \
  --output-path BIO_eDNA_field_16S_combo_merger_exported

biom convert -i BIO_eDNA_field_16S_combo_merger_exported"/feature-table.biom" \
  -o BIO_eDNA_field_16S_combo_merger.txt \
  --to-tsv

#12S------
qiime feature-table merge \
  --i-tables $table1".qza" $table2".qza"  \
  --p-overlap-method 'sum' \
  --o-merged-table BIO_eDNA_field_12S_combo_merger.qza

qiime tools export --input-path BIO_eDNA_field_12S_combo_merger.qza \
  --output-path BIO_eDNA_field_12S_combo_merger_exported

biom convert -i BIO_eDNA_field_12S_combo_merger_exported"/feature-table.biom" \
  -o BIO_eDNA_field_12S_combo_merger.txt \
  --to-tsv
