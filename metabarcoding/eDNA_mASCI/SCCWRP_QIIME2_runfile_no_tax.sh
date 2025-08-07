#!/bin/bash

qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \
--input-path $workingPATH/$fastq_directory \
--input-format CasavaOneEightSingleLanePerSampleDirFmt \
--output-path $workingPATH/$project_shortname".qza"

qiime cutadapt trim-paired \
--i-demultiplexed-sequences $workingPATH/$project_shortname".qza" \
--p-cores 1 \
--p-front-f $primerF \
--p-front-r $primerR \
--p-error-rate $errorR \
--o-trimmed-sequences $workingPATH/$project_shortname"_trim.qza"

qiime dada2 denoise-paired \
--i-demultiplexed-seqs $workingPATH/$project_shortname"_trim.qza" \
--p-trim-left-f $trimF \
--p-trim-left-r $trimR \
--p-trunc-len-f $lengthF \
--p-trunc-len-r $lengthR \
--p-trunc-q $truncQ \
--p-n-threads 0 \
--o-representative-sequences $workingPATH/$project_shortname"_trim_dada2_rep_seq.qza" \
--o-table $workingPATH/$project_shortname"_trim_dada2_table.qza" \
--verbose \
--o-denoising-stats $workingPATH/$project_shortname"_trim_dada2_stats.qza"


qiime tools export --input-path $workingPATH/$project_shortname"_trim_dada2_table.qza" \
--output-path $workingPATH/$project_shortname"_trim_dada2_table_exported"

biom convert -i $workingPATH/$project_shortname"_trim_dada2_table_exported/feature-table.biom" \
-o $workingPATH/$project_shortname"_trim_dada2_table.txt" \
--to-tsv

qiime tools export --input-path $workingPATH/$project_shortname"_trim_dada2_rep_seq.qza" \
--output-path $workingPATH/$project_shortname"_trim_dada2_rep_seq_exported"

qiime tools export --input-path $workingPATH/$project_shortname"_trim_dada2_stats.qza" \
--output-path $workingPATH/$project_shortname"_trim_dada2_stats_exported"
