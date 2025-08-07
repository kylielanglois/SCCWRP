#!/bin/bash

#conda activate qiime2-2022.2
#or most updated qiime2 image

if [[ $import_tax_yes_no == "yes" ]]
then
  qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path $taxonomy_fasta \
  --output-path $homePATH/$refReads"_seq.qza"

  qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-path $taxonomy_names \
  --output-path $homePATH/$refReads"_tax.qza"

elif [[ $import_tax_yes_no == "no" ]]
then
	echo "taxonomy already .qza"
fi

qiime tools import \
--input-path $SampReads".fasta" \
--type 'FeatureData[Sequence]' \
--output-path $SampReads".qza"

qiime feature-classifier extract-reads \
--i-sequences $homePATH/$refReads"_seq.qza" \
--p-f-primer $primerF \
--p-r-primer $primerR \
--p-identity $id \
--p-min-length $length_min \
--p-max-length $length_max \
--p-read-orientation $orientation \
--verbose \
--output-dir $workingPATH/$refReads"_extracted"

qiime feature-classifier fit-classifier-naive-bayes \
--i-reference-taxonomy $homePATH/$refReads"_tax.qza" \
--i-reference-reads $workingPATH/$refReads"_extracted/reads.qza" \
--p-classify--chunk-size $chunk \
--p-verbose \
--o-classifier $workingPATH/$refReads"_extracted_NB_classifier"

qiime feature-classifier classify-sklearn \
--i-reads $SampReads".qza" \
--i-classifier $workingPATH/$refReads"_extracted_NB_classifier.qza" \
--verbose \
--output-dir $fastqPATH/$project_shortname"_"$refReads"_NB_tax"

qiime tools export \
--input-path $fastqPATH/$project_shortname"_"$refReads"_NB_tax/classification.qza" \
--output-path $fastqPATH/$project_shortname"_"$refReads"_NB_tax/classification_export"


#

#qiime taxa barplot \
#  --i-table $workingPATH/$project_shortname"_trim_dada2_table.qza" \
#  --i-taxonomy $workingPATH/$project_shortname"_trim_dada2_tax.qza" \
#  --o-visualization $workingPATH/$project_shortname"_trim_dada2_table_tax_viz.qzv"

#  qiime tools export --input-path $workingPATH/$project_shortname"_trim_dada2_table_tax_viz.qzv" \
#  --output-path $workingPATH/$project_shortname"_trim_dada2_table_tax_viz_exported"
