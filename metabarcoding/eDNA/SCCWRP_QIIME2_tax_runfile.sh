#!/bin/bash

#conda activate qiime2-2021.11
#or most updated qiime2 image

if [[ $import_tax_yes_no == "yes" ]]
then
  qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path $taxonomy_fasta \
  --output-path $homePATH/tax_fasta
  $taxonomy_fasta = $homePATH/tax_fasta

  qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-path $taxonomy_names \
  --output-path $homePATH/tax_names
  $taxonomy_names = $homePATH/tax_names

elif [[ $import_tax_yes_no == "no" ]]
then
	echo "taxonomy already .qza"
fi

qiime feature-classifier extract-reads \
--i-sequences $taxonomy_fasta \
--p-f-primer $primerF \
--p-r-primer $primerR \
--p-identity $id \
--p-min-length $length_min \
--p-max-length $length_max \
--p-n-jobs $jobs_num \
--p-batch-size $batch_size \
--p-read-orientation $orientation \
--verbose \
--output-dir $workingPATH/$taxonomy"_extracted"


qiime feature-classifier fit-classifier-naive-bayes \
--i-reference-taxonomy $taxonomy_names \
--i-reference-reads $workingPATH/$taxonomy"_extracted/reads.qza" \
--p-classify--chunk-size $chunk \
--p-verbose \
--o-classifier $workingPATH/$taxonomy"_extracted_NB_classifier"

qiime feature-classifier classify-sklearn \
--i-reads $workingPATH/$project_shortname"_trim_dada2_rep_seq.qza" \
--i-classifier $workingPATH/$taxonomy"_extracted_NB_classifier.qza" \
--p-reads-per-batch $chunk \
--p-n-jobs $jobs_num \
--verbose \
--output-dir $workingPATH/$project_shortname"_"$taxonomy"_NB_tax"

qiime tools export \
--input-path $workingPATH/$project_shortname"_"$taxonomy"_NB_tax/classification.qza" \
--output-path $workingPATH/$project_shortname"_"$taxonomy"_NB_tax/classification_export"


#

#qiime taxa barplot \
#  --i-table $workingPATH/$project_shortname"_trim_dada2_table.qza" \
#  --i-taxonomy $workingPATH/$project_shortname"_trim_dada2_tax.qza" \
#  --o-visualization $workingPATH/$project_shortname"_trim_dada2_table_tax_viz.qzv"

#  qiime tools export --input-path $workingPATH/$project_shortname"_trim_dada2_table_tax_viz.qzv" \
#  --output-path $workingPATH/$project_shortname"_trim_dada2_table_tax_viz_exported"
