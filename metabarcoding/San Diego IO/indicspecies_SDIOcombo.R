#created by Kylie Langlois kyliel@sccwrp.org
#2/15/24
#indicator species analysis to run on virtual machine

#do:
#Rscript --vanilla indicspecies_SDIOcombo.R

#-------------------------parameters to change-------------------------
setwd<-"/home/processed/SDIO_indiv_combo/fastq_combo"
path<-"/home/processed/SDIO_indiv_combo/fastq_combo" #same as setwd()
name<-"SDIO_fastq_combo" #name of project
dat<-read.delim(file.path(path, "SDIO_fastq_combo_table_norep_nobl_nozero.txt"), head=T) #name of ASV table, must be in wd
map<-read.csv(file.path(path, "SD_IO_metadata_fastq_combo_012624_norep_nobl_nozero.csv"), head=T) #name of metadata, must be in wd

path #check path

#-------------------------do not change-------------------------
#packages-------------------------
require(indicspecies)

dat1<-dat
map1<-map

map3<-map1[,match(c("SEQUENCING_NAME", "SAMPLE_TYPE"), colnames(map1))]
map3$SEQUENCING_NAME<-trimws(map3$SEQUENCING_NAME)

dat2<-dat1 #if working with imported table
dim(dat2) #check dimensions
rownames(dat2)<-dat2$X.OTUID
dat2<-dat2[, -1]
#remove low abundance asv--
#dat2$seqsums<-rowSums(dat2)
#dat2<-subset(dat2, dat2$seqsums > sum(dat2$seqsums)*0.00005) #only ASV greater than 0.005%
#dat2<-dat2[, !grepl("seqsums", colnames(dat2))]
dim(dat2) #check dimension

dat2.t<-as.data.frame(t(dat2))
dat2.t$samp<-rownames(dat2.t)
dat2.t$samp<-trimws(dat2.t$samp)

datmap<-merge(map3, dat2.t, by.x = "SEQUENCING_NAME", by.y = "samp", all.y = T)
datmap$SAMPLE_TYPE[is.na(datmap$SAMPLE_TYPE)]<-"STORMDRAIN"
dim(datmap) #check dimensions

#isa--
inv<-multipatt(datmap[,3:ncol(datmap)], datmap$SAMPLE_TYPE, func = "IndVal", 
               control = how(nperm=999), print.perm = T)
iv.df<-as.data.frame(inv$sign)
colnames(iv.df)<-paste(colnames(iv.df), "IV")
iv.df$seq<-rownames(iv.df)
a.df<-as.data.frame(inv$A)
colnames(a.df)<-paste(colnames(a.df), "A") 
a.df$seq<-rownames(a.df)
b.df<-as.data.frame(inv$B)
colnames(b.df)<-paste(colnames(b.df), "B")
b.df$seq<-rownames(b.df)

indic<-merge(iv.df, a.df, by="seq")
indic<-merge(indic, b.df, by="seq")

indic.p<-subset(indic, indic$`stat IV`>0.9)
indic.p<-subset(indic.p, indic.p$`p.value IV`<0.05)

write.csv(indic, row.names = F,
          file.path(path, paste0(name, "ISA_results.csv")))
write.csv(indic.p, row.names = F,
          file.path(path, paste0(name, "ISA_signif.csv")))

