#!/bin/bash

#MUST DO BEFORE:
#conda create -n st3 -c biocore python=3.2 numpy scipy scikit-bio biom-format h5py hdf5 seaborn
#pip install https://github.com/biota/sourcetracker2/archive/master.zip
#nano /home/genomics/.local/pipx/venvs/sourcetracker/lib/python3.11/site-packages/sourcetracker/_cli/gibbs.py
##Change line 157 to: sample_metadata = parse_sample_metadata(open(mapping_fp, ‘r’))

homePATH="/home/genomics/processed/SDIO_indiv_combo" # Path to parent directory; not where FASTQ files are stored. Should NOT finish with "/"

cd $homePATH

#biom convert -i SDIO_indiv_combo_table_norep_nobl_nozero_SS.txt  -o SDIO_indiv_combo_table_norep_nobl_nozero_SS.biom --table-type="OTU table" --to-hdf5

sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero_SS.biom -m SD_IO_metadata_combo_012624_norep_nobl_nozero_SS_23wetgrabs.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o SDIO_combo_2024_st2_result_sg
