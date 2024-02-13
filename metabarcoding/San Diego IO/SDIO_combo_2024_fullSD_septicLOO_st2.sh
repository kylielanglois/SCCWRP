#!/bin/bash

#MUST DO BEFORE:
#conda create -n st2_env -c biocore python=3.2 numpy scipy scikit-bio biom-format h5py hdf5 seaborn
#pip install https://github.com/biota/sourcetracker2/archive/master.zip
#nano /home/genomics/.local/pipx/venvs/sourcetracker/lib/python3.11/site-packages/sourcetracker/_cli/gibbs.py
##Change line 157 to: sample_metadata = parse_sample_metadata(open(mapping_fp, ‘r’))

homePATH="/home/genomics/processed/SDIO_indiv_combo" # Path to parent directory; not where FASTQ files are stored. Should NOT finish with "/"
resultsPATH=$homePATH/"fullSD_septicLOO_st2/resultsLOO"
metadataPATH=$homePATH/"fullSD_septicLOO_st2/metadataLOO"

cd $homePATH

#biom convert -i SDIO_indiv_combo_table_norep_nobl_nozero.txt  -o SDIO_indiv_combo_table_norep_nobl_nozero.biom --table-type="OTU table" --to-hdf5

sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map1.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_1
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map2.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_2
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map3.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_3
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map4.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_4
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map5.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_5
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map6.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_6
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map7.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_7
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map8.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_8
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map9.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_9
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map10.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_10
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map11.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_11
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map12.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_12
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map13.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_13
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map14.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_14
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map15.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_15
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map16.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_16
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map17.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_17
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map18.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_18
sourcetracker2 -i SDIO_indiv_combo_table_norep_nobl_nozero.biom -m $metadataPATH/map19.txt --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink -o $resultsPATH/LOO_19
