#must do before:
#install.packages("dada2")
library(dada2)

args <- commandArgs(trailingOnly = TRUE)
str(args)
cat(args, sep = "\n")

library(dada2)
path <- args[1]
path
cutFs <- sort(list.files(path, pattern="_1.fq.gz", full.names = TRUE))
cutRs <- sort(list.files(path, pattern="_2.fq.gz", full.names = TRUE))
sample.names <- sapply(strsplit(basename(cutFs), "_1.fq.gz"), `[`, 1)
sample.names
cutfiltFs <- file.path(path, "fastq_files_discardShort", paste0(sample.names, "_R1_cut.fastq.gz"))
cutfiltRs <- file.path(path, "fastq_files_discardShort", paste0(sample.names, "_R2_cut.fastq.gz"))
print("files found + sorted")

print("start trim at 250")
out <- filterAndTrim(cutFs, cutfiltFs, cutRs, cutfiltRs, 
                     minLen = c(250, 250),
                     compress=TRUE, multithread=T, matchIDs=TRUE, verbose = T)
print("stop trim at 250")