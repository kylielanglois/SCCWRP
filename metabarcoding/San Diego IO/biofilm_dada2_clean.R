#created by Kylie Langlois
#kyliel@sccwrp.org for use with biofilm data

#install dada2-------
#if (!requireNamespace("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")
#BiocManager::install("dada2", version = "3.13")
#library(devtools)
#devtools::install_github("benjjneb/dada2", ref="v1.20")

#packages------
#install.packages("dada2")
library(dada2)

#files------
path <- "/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/all_biofilm_16S_V4V5_012023/012023_16SV4V5/"
head(list.files(path))

#inspect files-------
fnFs <- sort(list.files(path, pattern="L001_R1_001.fastq", full.names = TRUE))[1:20]
fnRs <- sort(list.files(path, pattern="L001_R2_001.fastq", full.names = TRUE))[1:20]

plotQualityProfile(fnFs[1:12]) #check if path and file names are correct
plotQualityProfile(fnRs[1:12])

sample.names <- sapply(strsplit(basename(fnFs), "_L001"), `[`, 1)

#filter and trim-------
filtFs <- file.path(path, "filtered", paste0(sample.names, "_F_filt.fastq.gz"))
filtRs <- file.path(path, "filtered", paste0(sample.names, "_R_filt.fastq.gz"))
out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs, truncLen=c(250,200),
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

mergers <- mergePairs(dadaFs, derepFs, dadaRs, derepRs, verbose=TRUE)
head(mergers[[1]])

seqtab <- makeSequenceTable(mergers)
dim(seqtab)
table(nchar(getSequences(seqtab)))
seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE)
dim(seqtab.nochim)
sum(seqtab.nochim)/sum(seqtab)

getN <- function(x) sum(getUniques(x))
track <- cbind(out, sapply(dadaFs, getN), sapply(dadaRs, getN), sapply(mergers, getN), rowSums(seqtab.nochim))
colnames(track) <- c("input", "filtered", "denoisedF", "denoisedR", "merged", "nonchim")
rownames(track) <- sample.names
head(track)
write.csv(track,
          file.path(path, "all_biofilm_16S_V4V5_030322_pairedend_demux_trimmed_dada2_track.csv"))

#inspect and edit------------------
df<-as.data.frame(seqtab.nochim)
head(rownames(df))
head(colnames(df))

#export----------
#rep set-----------
vec1<- toupper(colnames(df))
vec2<- paste("ASV", 1:length(vec1), sep = "_")

write.fasta(sequences= as.list(vec1), names = vec2,
            file.out = file.path(path, "all_biofilm_16S_V4V5_030322_pairedend_demux_trimmed_rep_set.fasta"))

#ASV table-----------
colnames(df)<-vec2
head(colnames(df))
head(rownames(df))
df1<-as.data.frame(t(df))
df1$seq<-rownames(df1)
df1<-df1[,c(ncol(df1), 1:(ncol(df1)-1))]
write.csv(df1,
          file.path(path, "all_biofilm_16S_V4V5_030322_pairedend_demux_trimmed_dada2_table.csv"), row.names = F)
write.table(df1,
          file.path(path, "all_biofilm_16S_V4V5_030322_pairedend_demux_trimmed_dada2_table.txt"), sep=" \t", row.names = F)

df$seq.total<-rowSums(df)
head(df$seq.total)
df.notmerge<-rownames(df)[df$seq.total==0]
df<-subset(df, df$seq.total>0)
rownames(df)
df$seq<-rownames(df)
df.t<-as.data.frame(t(df))
write.csv(df.t,
          file.path(path, "all_biofilm_16S_V4V5_030322_pairedend_demux_trimmed_dada2_table_nozero.txt"))
