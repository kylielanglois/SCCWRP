getting code read: 
* save all code files in single directory
* edit FASTQC_run.sh to your correct file paths (first block of bash variables)
* edit nothing else!

pre-processing:

```
conda create -n multiqc -c bioconda -c conda-forge fastqc multiqc
conda activate multiqc
export LC_ALL-en_US.UTF-8
export LANG=en_US.UTF-8
```

run code after navigating to appropriate directory: 

```
chmod +x FASTQC_runfile.sh
./FASTQC_runfile.sh
```
