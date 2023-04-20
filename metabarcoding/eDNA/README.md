### eDNA metabarcoding sequence analysis performed by Kylie Langlois kyliel@sccwrp.org Mar-Apr 2023

Samples extracted using Qiagen PowerSoil Pro kit at SCCWRP (Costa Mesa, CA)

DNA extracts were sequenced by Laragen Inc. (Culver City, CA)

QIIME runfiles and parameter files were used to process raw FASTQ files at SCCWRP
* assume working knowledge and installation of QIIME2 (v.2021.11)
* assume working knowledge of shell scripts

| gene	| sequencing date	| QIIME parameters	| QIIME parameters-taxonomy	| taxonomy link|
| ----| ----| ----| ----| ----|
| 16S	| 10/7/21	| SCCWRP_QIIME2_param_100721_16S.sh	| SCCWRP_QIIME2_tax_param_1007202_16S.sh	| https://docs.qiime2.org/2021.11/data-resources/ (MD5: de8886bb2c059b1e8752255d271f3010)| 
| 18S| 	3/31/22	| SCCWRP_QIIME2_param_03312022_18S.sh| 	SCCWRP_QIIME2_tax_param_03312022_18S.sh	| 	https://docs.qiime2.org/2021.11/data-resources/ (MD5: f12d5b78bf4b1519721fe52803581c3d)| 
| rcbL	| 10/14/21	| SCCWRP_QIIME2_param_10142021_rcbL.sh	| SCCWRP_QIIME2_tax_param_10142021_rcbL.sh	| Susanna Theroux, Zack Gold| 
| CO1| 	3/29/23	| SCCWRP_QIIME2_param_03292023_CO1.sh	| SCCWRP_QIIME2_tax_param_032923_CO1.sh	| https://forum.qiime2.org/t/building-a-coi-database-from-bold-references/16129 | 


example code (no taxonomy):
```
chmod +x SCCWRP_QIIME2_param_[date]_[gene].sh
chmod +x SCCWRP_QIIME2_runfile_no_tax.sh
./SCCWRP_QIIME2_param_[date]_[gene].sh
```

example code for assigning taxonomy:
```
chmod +x SCCWRP_QIIME2_tax_param_[date]_[gene].sh
chmod +x SCCWRP_QIIME2_tax_runfile.sh
./SCCWRP_QIIME2_tax_param_[date]_[gene].sh
```

