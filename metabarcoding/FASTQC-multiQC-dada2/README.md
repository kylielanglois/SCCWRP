getting code read: 
* save all code files in single directory
* edit FASTQC_runfile.sh to your correct file paths (first block of bash variables)
* edit nothing else!

pre-processing:

```
conda create -n multiqc_env -c bioconda -c conda-forge fastqc multiqc cutadapt
conda activate multiqc_env
export LC_ALL-en_US.UTF-8
export LANG=en_US.UTF-8
conda list #ensure you have 'pandas' installed
```

run code after navigating to appropriate directory: 

```
chmod +x FASTQC_runfile.sh
./FASTQC_runfile.sh
```

output: 
![Screen Shot 2023-07-21 at 4 56 58 PM](https://github.com/kylielanglois/SCCWRP/assets/31413115/4080f4d3-b246-4a9f-97c7-79a7b7b7393c)
* may not show final column if R code broke
* data should be available in fastqc_multiqc_dada2_filteronly_results.csv
