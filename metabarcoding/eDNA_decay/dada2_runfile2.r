#must do before:
#install.packages("dada2")
library(dada2)

args <- commandArgs(trailingOnly = TRUE)
str(args)
cat(args, sep = "\n")

#path<-"/Users/kylielanglois/OneDrive - SCCWRP/eDNA decay/BIO_eDNA_032425/trimmed_fastq/"
path <- args[1]
path

#get sample names-----
fnFs <- sort(list.files(path, pattern="R1_001_trimmed.fq.gz", full.names = TRUE))
fnRs <- sort(list.files(path, pattern="R2_001_trimmed.fq.gz", full.names = TRUE))
sample.names <- sapply(strsplit(basename(fnFs), "_R1"), `[`, 1)
sample.names
filtFs <- file.path(path, "filtered", paste0(sample.names, "_R1_filt.fastq.gz"))
filtRs <- file.path(path, "filtered", paste0(sample.names, "_R2_filt.fastq.gz"))

#filter-----
len_R1<-as.numeric(args[2])
len_R2<-as.numeric(args[3])
out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs, 
                     truncLen=c(len_R1, len_R2),
                     maxEE=c(2,2), truncQ=2, rm.phix=TRUE,
                     compress=TRUE, multithread=T, matchIDs=TRUE, verbose = T)
#out.export<-as.data.frame(out)
#write.csv(out.export, file = file.path(path, "seqs_in_table.csv"))

#get sample names after filter (sometimes samples kicked out)-----
errFfs <- sort(list.files(file.path(path, "filtered"), pattern="_R1_", full.names = TRUE))
errRfs <- sort(list.files(file.path(path, "filtered"), pattern="_R2_", full.names = TRUE))
sample.names.1 <- sapply(strsplit(basename(errFfs), "_R1"), `[`, 1)
sample.names.1

#learn error rates---------
errF <- learnErrors(errFfs, multithread=TRUE, verbose=T)
errR <- learnErrors(errRfs, multithread=TRUE, verbose=T)

#dereplication----------------
derepFs <- derepFastq(errFfs, verbose=TRUE)
derepRs <- derepFastq(errRfs, verbose=TRUE)
names(derepFs) <- sample.names.1
names(derepRs) <- sample.names.1

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

#writing/appending out file--------
next_csv <- function() {
  f <- length(list.files(path, pattern = "merger_table_V2"))
  num <- as.numeric(f)+1
  paste0("/merger_table_V2_", num, ".csv")
}

if (length(grep("merger_table_V2", list.files(path)))==0){
  write.table(seqtab.nochim,
              file = file.path(path, "merger_table_V2_1.csv"),
              row.names = F, append = F, sep = ",")
} else {
  write.csv(seqtab.nochim, file = file.path(path, next_csv()))
}

#get tracking--------
getN <- function(x) sum(getUniques(x))
samples.kicked<-nrow(out)-length(dadaFs)

dd.df<-data.frame(sample.names=sample.names.1, 
                  dadaF=sapply(dadaFs, getN), 
                  dadaR=sapply(dadaRs, getN), 
                  merger=sapply(mergers, getN),
                  no.chimera=colSums(seqtab.nochim))
out <- as.data.frame(out)
out$sample.names <- sample.names
out.df <- merge(out, dd.df, by="sample.names", all.x = T)

out.df$perc.retain<-(out.df$no.chimera/out.df$reads.in)

#writing/appending track file--------
if (file.exists(file.path(path, "fastqc_multiqc_dada2_filteronly_results_V2.csv"))){
  write.table(out.df,
              file = file.path(path, "fastqc_multiqc_dada2_filteronly_results_V2.csv"),
              row.names = F, append = T, sep = ",")
} else {
  write.table(out.df,
              file = file.path(path, "fastqc_multiqc_dada2_filteronly_results_V2.csv"),
              row.names = F, append = F, sep = ",")
}

#get average percent retained--------
av <- round(mean((out.df$no.chimera / out.df$reads.in)*100), 2)
av
write.table(av, file=file.path(path, "average_quality_V2.txt"), row.names=F)
