#Kylie Langlois kyliel@sccwrp.org
#to be used after succssfully running dada2

#packages-----------
library(seqinr)

#files-----------
path<-"/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/all SD IO combo 2024/"

dat<-read.csv(file.path(path, "SDIO_fastqcombo_merger_90.csv"), head=T)
filename<-"SDIO_fastqcombo_merger_90"

#rep set-----------
vec1<- toupper(dat$X)
vec2<- paste("ASV", 1:length(vec1), sep = "_")

write.fasta(sequences= as.list(vec1), names = vec2,
            file.out = file.path(path, "SDIO_fastq_combo_rep_set.fasta"))

#ASV table-----------
dat$X<-vec2
colnames(dat)[1]<-"ASV"
write.csv(dat,
          file.path(path, "SDIO_fastq_combo_table.csv"), row.names = F)
write.table(dat,
            file.path(path, "SDIO_fastq_combo_table.txt"), sep=" \t", row.names = F)


