#!/bin/bash

#conda activate qiime2-amplicon-2024.5 <----- or most updated qiime2 image

###### MUST EDIT FOR TAXONOMY THAT YOU WANT TO USE ######

################## import files ##################
qiime tools import \
--type 'FeatureData[Sequence]' \
--input-path $sampReads".fasta" \
--output-path $sampReads".qza"

#qiime tools import \
#--type 'FeatureData[Sequence]' \
#--input-path $taxPATH/$refReads".fasta" \
#--output-path $taxPATH/$refReads".qza"

#qiime tools import \
#--type 'FeatureData[Taxonomy]' \
#--input-path $taxPATH/$refTax".txt" \
#--output-path $taxPATH/$refTax".qza"

################## naive bayes ##################
#qiime feature-classifier fit-classifier-naive-bayes \
#--i-reference-taxonomy $taxPATH/$refTax".qza" \
#--i-reference-reads $taxPATH/$refReads".qza" \
#--p-classify--chunk-size $chunk \
#--p-verbose \
#--o-classifier $taxPATH/$project_shortname"_"$refName"_NB_classifier"

#qiime feature-classifier classify-sklearn \
#--i-reads $sampReads".qza" \
#--i-classifier $taxPATH/$refClassifier \
#--verbose \
#--output-dir $processedPATH/$project_shortname"_"$refName"_NB_tax"

#qiime tools export \
#--input-path $processedPATH/$project_shortname"_"$refName"_NB_tax/classification.qza" \
#--output-path $processedPATH/$project_shortname"_"$refName"_NB_tax_export"

################## blast ##################
qiime feature-classifier classify-consensus-blast \
--i-query $sampReads".qza" \
--i-reference-taxonomy $taxPATH/$refTax".qza" \
--i-reference-reads $taxPATH/$refReads".qza" \
--p-maxaccepts $maxAccepts \
--p-perc-identity $percID \
--p-evalue $eValue \
--verbose \
--o-classification $processedPATH/$project_shortname"_"$refName"_bl_tax"$perID \
--o-search-results $processedPATH/$project_shortname"_"$refName"_bl"$perID"_search_results"

qiime tools export \
--input-path $processedPATH/$project_shortname"_"$refName"_bl_tax"$perID".qza" \
--output-path $processedPATH/$project_shortname"_"$refName"_bl_tax_"$perID"export"
