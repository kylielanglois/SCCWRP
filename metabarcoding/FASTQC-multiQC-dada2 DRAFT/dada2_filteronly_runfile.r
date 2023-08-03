

args <- commandArgs(trailingOnly = TRUE)
str(args)
cat(args, sep = "\n")

library(dada2)
path <- args[1]
path
fnFs <- sort(list.files(path, pattern="L001_R1_001.fastq", full.names = TRUE))
fnRs <- sort(list.files(path, pattern="L001_R2_001.fastq", full.names = TRUE))
sample.names <- sapply(strsplit(basename(fnFs), "_L001"), `[`, 1)
sample.names

filtFs <- file.path(path, "filtered", paste0(sample.names, "_F_filt.fastq.gz"))
filtRs <- file.path(path, "filtered", paste0(sample.names, "_R_filt.fastq.gz"))

len_R1<-as.numeric(args[2])
len_R2<-as.numeric(args[3])
out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs, truncLen=c(len_R1, len_R2),
                     maxEE=c(2,2), truncQ=2, rm.phix=TRUE,
                     compress=TRUE, multithread=T, matchIDs=TRUE, verbose = T)
out.df <- as.data.frame(out)
out.df$perc.retain<-(out.df$reads.out/out.df$reads.in)
out.df$sample<-rownames(out.df)

if (file.exists(file.path(path, "fastqc_multiqc_dada2_filteronly_results.csv"))){
  write.table(out.df[ ,c("sample", "perc.retain")],
              file = file.path(path, "fastqc_multiqc_dada2_filteronly_results.csv"),
              row.names = F, append = T, sep = ",")
} else {
  write.table(out.df[ ,c("sample", "perc.retain")],
              file = file.path(path, "fastqc_multiqc_dada2_filteronly_results.csv"),
              row.names = F, append = F, sep = ",")
}

#av <- round(mean((out.df$reads.out / out.df$reads.in)*100), 2)
#av
#write.table(av, file=file.path(path, "average_quality.txt"), row.names=F)
