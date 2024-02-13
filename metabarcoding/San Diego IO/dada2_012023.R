#run locally on Kylie Langlois machine
#put processed files in sangabriel/genomics/processed/
#1/11/24

#packages------
#install.packages("dada2")
library(dada2)
library(seqinr)

#files------
path <- "/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/012023_16SV4_demux/"
head(list.files(path))

#inspect files-------
fnFs <- sort(list.files(path, pattern="L001_R1_001.fastq", full.names = TRUE))
fnRs <- sort(list.files(path, pattern="L001_R2_001.fastq", full.names = TRUE))
#ignore the I1 and I2 files

sample.names <- sapply(strsplit(basename(fnFs), "_L001"), `[`, 1)

#filter and trim-------
filtFs <- file.path(path, "filtered", paste0(sample.names, "_F_filt.fastq.gz"))
filtRs <- file.path(path, "filtered", paste0(sample.names, "_R_filt.fastq.gz"))
out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs, truncLen=c(225,200), #based on multiQC reports
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

seqtab <- makeSequenceTable(mergers)
table(nchar(getSequences(seqtab)))
seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE)

getN <- function(x) sum(getUniques(x))
track <- cbind(out, sapply(dadaFs, getN), sapply(dadaRs, getN), sapply(mergers, getN), rowSums(seqtab.nochim))
colnames(track) <- c("input", "filtered", "denoisedF", "denoisedR", "merged", "nonchim")
rownames(track) <- sample.names

#export----------
write.csv(track, 
          "/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/all SD IO 010824/fastqc_multiqc_dada2_filteronly_results_012023.csv")

seqtab.nochim1<-as.data.frame(t(seqtab.nochim))
write.csv(seqtab.nochim1, 
          "/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/all SD IO 010824/SDIO_012023_NA_merger.csv")
write.table(seqtab.nochim1, sep="\t",
          "/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/all SD IO 010824/SDIO_012023_NA_merger.txt")




