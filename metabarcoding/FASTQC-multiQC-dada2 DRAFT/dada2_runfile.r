#must do before:
#install.packages("dada2")
library(dada2)

args <- commandArgs(trailingOnly = TRUE)
str(args)
cat(args, sep = "\n")

library(dada2)
path <- args[1]
path
fnFs <- sort(list.files(path, pattern="L001_R1_001_trimmed.fastq", full.names = TRUE))
fnRs <- sort(list.files(path, pattern="L001_R2_001_trimmed.fastq", full.names = TRUE))
sample.names <- sapply(strsplit(basename(fnFs), "_L001"), `[`, 1)
sample.names

filtFs <- file.path(path, "filtered", paste0(sample.names, "_F_filt.fastq.gz"))
filtRs <- file.path(path, "filtered", paste0(sample.names, "_R_filt.fastq.gz"))

len_R1<-as.numeric(args[2])
len_R2<-as.numeric(args[3])
out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs, truncLen=c(len_R1, len_R2),
                     maxEE=c(2,2), truncQ=2, rm.phix=TRUE,
                     compress=TRUE, multithread=T, matchIDs=TRUE, verbose = T)

#learn error rates---------
errF <- learnErrors(filtFs, multithread=TRUE, verbose=T)
errR <- learnErrors(filtRs, multithread=TRUE, verbose=T)

#dereplication----------------
derepFs <- derepFastq(filtFs, verbose=TRUE)
derepRs <- derepFastq(filtRs, verbose=TRUE)
names(derepFs) <- sample.names
names(derepRs) <- sample.names

#sample inferences--------
dadaFs <- dada(derepFs, err=errF, multithread=TRUE, verbose=T)
dadaRs <- dada(derepRs, err=errR, multithread=TRUE, verbose=T)

#merge R1 and R2--------
mergers <- mergePairs(dadaFs, derepFs, dadaRs, derepRs, verbose=TRUE)

#get merger table--------
seqtab <- makeSequenceTable(mergers)
seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE)
seqtab.nochim<-as.data.frame(seqtab.nochim)
seqtab.nochim<-as.data.frame(t(seqtab.nochim))

#get tracking--------
getN <- function(x) sum(getUniques(x))
out.df <- cbind(out, sapply(dadaFs, getN), sapply(dadaRs, getN), sapply(mergers, getN), colSums(seqtab.nochim))
colnames(out.df) <- c("input", "filtered", "denoisedF", "denoisedR", "merged", "nonchim")
rownames(out.df) <- sample.names
out.df<-as.data.frame(out.df)

out.df$perc.retain<-(out.df$nonchim/out.df$input)
out.df$sample<-rownames(out.df)

#writing/appending out file--------
next_csv <- function() {
  f <- list.files(path, pattern = "^merger_table_\\d+\\.csv")
  num <- max(as.numeric(gsub("^merger_table_(\\d)\\.csv", "\\1", f)) + 1)
  paste0("/merger_table_", num, ".csv")
}

if (length(grep("merger_table", list.files(path)))==0){
  write.table(seqtab.nochim,
              file = file.path(path, "merger_table_1.csv"),
              row.names = F, append = F, sep = ",")
} else {
  write.csv(seqtab.nochim, file = file.path(path, next_csv()))
}

#writing/appending track file--------
if (file.exists(file.path(path, "fastqc_multiqc_dada2_filteronly_results.csv"))){
  write.table(out.df,
              file = file.path(path, "fastqc_multiqc_dada2_filteronly_results.csv"),
              row.names = F, append = T, sep = ",")
} else {
  write.table(out.df,
              file = file.path(path, "fastqc_multiqc_dada2_filteronly_results.csv"),
              row.names = F, append = F, sep = ",")
}

#get average percent retained--------
av <- round(mean((out.df$nonchim / out.df$input)*100), 2)
av
write.table(av, file=file.path(path, "average_quality.txt"), row.names=F)
