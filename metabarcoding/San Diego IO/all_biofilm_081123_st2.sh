#!/bin/bash

#MUST DO BEFORE:
#conda create -n st2 -c biocore python=3.5 numpy scipy scikit-bio biom-format h5py hdf5 seaborn
#pip3 install https://github.com/biota/sourcetracker2/archive/master.zip

homePATH="/home/genomics/raw/all_biofilm_demux_081123" # Path to parent directory; not where FASTQ files are stored. Should NOT finish with "/"

biom convert -i $homePATH/"all_biofilm_16S_V4V5_demux_081123_90cutoff_dada2_table_norep_nobl_nozero.txt"  -o $homePATH/"all_biofilm_16S_V4V5_demux_081123_90cutoff_dada2_table_norep_nobl_nozero.biom" --table-type="OTU table" --to-hdf5

sourcetracker2 -i $homePATH/"all_biofilm_16S_V4V5_demux_081123_90cutoff_dada2_table_norep_nobl_nozero.biom" -m $homePATH/"demux_all_biofilm_metadata_081123_norep_nobl_SS.txt" --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 8 --per_sink_feature_assignments --source_sink_column "SS" --source_column_value "source" --sink_column_value "sink" -o $homePATH/"all_biofilm_081123_st2_result"
