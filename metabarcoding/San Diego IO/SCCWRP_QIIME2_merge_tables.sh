#!/bin/bash

#conda activate qiime2-2022.2 <----- MUST CONDA ACTIVATE BEORE RUNNING SCRIPT

#computer information-------------------
processedPATH="/home/genomics/processed" # Path to the processed files will be housed. Should NOT finish with "/"
scriptsPATH="/home/genomics/scripts/QIIME2_scripts" #where scripts are located;  Should NOT finish with "/"

#user input-------------------
project_shortname="biofilm_indiv_combo" #PUT PROJECT SHORT NAME HERE
processed_directory=$processedPATH/"biofilm_indiv_combo" #Name of folder that will contain processed files

cd $processed_directory

#manually change .csv merger tables to .txt (tab delimited)
table1="SDIO_011024_85_merger"
table2="SDIO_012023_NA_merger"
table3="SDIO_022822_90_merger"
table4="SDIO_060221_75_85_merger"
table5="SDIO_062920_90_merger"
table6="SDIO_081221_90_merger"
table7="SDIO_Apr2023_95_merger"
table8="SDIO_Aug2023_85_90_merger"
table9="SDIO_revisits21newnames2024_NA_merger"

biom convert -i $table1".txt" -o $table1".biom" --table-type="OTU table" --to-hdf5
biom convert -i $table2".txt" -o $table2".biom" --table-type="OTU table" --to-hdf5
biom convert -i $table3".txt" -o $table3".biom" --table-type="OTU table" --to-hdf5
biom convert -i $table4".txt" -o $table4".biom" --table-type="OTU table" --to-hdf5
biom convert -i $table5".txt" -o $table5".biom" --table-type="OTU table" --to-hdf5
biom convert -i $table6".txt" -o $table6".biom" --table-type="OTU table" --to-hdf5
biom convert -i $table7".txt" -o $table7".biom" --table-type="OTU table" --to-hdf5
biom convert -i $table8".txt" -o $table8".biom" --table-type="OTU table" --to-hdf5
biom convert -i $table9".txt" -o $table9".biom" --table-type="OTU table" --to-hdf5
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
qiime tools import \
  --input-path $table5".biom" \
  --type 'FeatureTable[Frequency]' \
  --input-format BIOMV210Format \
  --output-path $table5".qza"
qiime tools import \
  --input-path $table6".biom" \
  --type 'FeatureTable[Frequency]' \
  --input-format BIOMV210Format \
  --output-path $table6".qza"
qiime tools import \
  --input-path $table7".biom" \
  --type 'FeatureTable[Frequency]' \
  --input-format BIOMV210Format \
  --output-path $table7".qza"
qiime tools import \
  --input-path $table8".biom" \
  --type 'FeatureTable[Frequency]' \
  --input-format BIOMV210Format \
  --output-path $table8".qza"
qiime tools import \
  --input-path $table9".biom" \
  --type 'FeatureTable[Frequency]' \
  --input-format BIOMV210Format \
  --output-path $table9".qza"

qiime feature-table merge \
  --i-tables $table1".qza" $table2".qza" $table3".qza" $table4".qza" $table5".qza" $table6".qza" $table7".qza" $table8".qza" $table9".qza" \
  --p-overlap-method 'sum' \
  --o-merged-table biofilm_indiv_combo_merger.qza

qiime tools export --input-path biofilm_indiv_combo_merger.qza \
  --output-path biofilm_indiv_combo_merger_exported

biom convert -i biofilm_indiv_combo_merger_exported"/feature-table.biom" \
  -o biofilm_indiv_combo_merger.txt \
  --to-tsv
