#must do before:
#install.packages("dada2")
library(dada2)

args <- commandArgs(trailingOnly = TRUE)
str(args)
cat(args, sep = "\n")

path <- args[1]
path
###### get file names ###### 
fnFs <- sort(list.files(path, pattern="R1_001_trimmed.fq", full.names = TRUE))
fnRs <- sort(list.files(path, pattern="R2_001_trimmed.fq", full.names = TRUE))
sample.names <- sapply(strsplit(basename(fnFs), "_R"), `[`, 1)
sample.names2 <- sapply(strsplit(basename(fnRs), "_R"), `[`, 1)
filtFs <- file.path(path, "filtered", paste0(sample.names, "_F_filt.fq.gz"))
filtRs <- file.path(path, "filtered", paste0(sample.names2, "_R_filt.fq.gz"))
###### get file names ###### 

len_R1<-as.numeric(args[2])
len_R2<-as.numeric(args[3])
len_R1
len_R2
out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs, 
                     truncLen=c(len_R1, len_R2),
                     maxEE=c(2,2), truncQ=2, rm.phix=TRUE,
                     compress=TRUE, multithread=T, matchIDs=TRUE, verbose = T)
print("filter done :)")

out.export<-as.data.frame(out)
write.csv(out.export, file = file.path(path, "seqs_in_table.csv"))

#learn error rates---------
###### get file names ###### 
path2<-file.path(path, "filtered")
filtFs <- sort(list.files(path2, pattern="_F_filt", full.names = TRUE))
filtRs <- sort(list.files(path2, pattern="_R_filt", full.names = TRUE))
###### get file names ###### 

errF <- learnErrors(filtFs, multithread=TRUE, verbose=T)
errR <- learnErrors(filtRs, multithread=TRUE, verbose=T)

print("errors done :)")

#dereplication----------------
derepFs <- derepFastq(filtFs, verbose=TRUE)
derepRs <- derepFastq(filtRs, verbose=TRUE)

print("derep done :)")

#sample inferences--------
dadaFs <- dada(derepFs, err=errF, multithread=TRUE, verbose=T)
dadaRs <- dada(derepRs, err=errR, multithread=TRUE, verbose=T)

print("dada done :)")

#merge R1 and R2--------
mergers <- mergePairs(dadaFs, derepFs, dadaRs, derepRs, verbose=TRUE)

#get merger table--------
seqtab <- makeSequenceTable(mergers)
seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE)
seqtab.nochim<-as.data.frame(seqtab.nochim)
seqtab.nochim<-as.data.frame(t(seqtab.nochim))

#writing/appending out file--------
next_csv <- function() {
  f <- list.files(path, pattern = "^merger_table_V2_\\d+\\.csv")
  num <- max(as.numeric(gsub("^merger_table_V2_(\\d)\\.csv", "\\1", f)) + 1)
  paste0("/merger_table_V2_", num, ".csv")
}

if (length(grep("merger_table_V2", list.files(path)))==0){
  write.table(seqtab.nochim,
              file = file.path(path, "merger_table_V2_1.csv"),
              row.names = F, append = F, sep = ",")
} else {
  write.csv(seqtab.nochim, file = file.path(path, next_csv()))
}

#get average percent retained--------
av <- round(mean((colSums(seqtab.nochim) / out$reads.in)*100), 2)
av
write.table(av, file=file.path(path, "average_quality_V2.txt"), row.names=F)


#get tracking--------
getN <- function(x) sum(getUniques(x))
df1<-data.frame(dadaFs=sapply(dadaFs, getN))
df2<-data.frame(dadaRs=sapply(dadaRs, getN))
df3<-data.frame(mergers=sapply(mergers, getN))
df4<-data.frame(seqtab.nochim=colSums(seqtab.nochim))
df.track<-cbind(df1, df2, df3, df4)
df.track$samps<-rownames(df.track)
df.track$samps<-gsub("_F_filt.fastq.gz", "", df.track$samps)
out.df<-as.data.frame(out)
out.df$samps<-rownames(out.df)
out.df$samps<-gsub("_R1_001_trimmed.fq.gz", "", out.df$samps)

track<-merge(out.df, df.track, by="samps", all.x=T)

track$perc.retain<-(track$seqtab.nochim/track$input)

#writing/appending track file--------
if (file.exists(file.path(path, "fastqc_multiqc_dada2_filteronly_results_V2.csv"))){
  write.table(track,
              file = file.path(path, "fastqc_multiqc_dada2_filteronly_results_V2.csv"),
              row.names = F, append = T, sep = ",")
} else {
  write.table(track,
              file = file.path(path, "fastqc_multiqc_dada2_filteronly_results_V2.csv"),
              row.names = F, append = F, sep = ",")
}

