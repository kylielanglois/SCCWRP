#3/28/23
#created by Kylie Langlois kyliel@sccwrp.org
#to be used with water filter samples run on ddPCR (Bio-Rad)

#before running script----------
#add Extraction Volume (ul) and Filtration Volume (ml) to ddPCR raw data
#add Correction Factor to ddPCR raw data (lysis buffer added divided by supernatant taken)

#packages---------
library(ggplot2)
library(ggpubr)
library(stringr)

#files---------
dat<-read.csv(file.choose(),head=T)
#YOUR FILENAME HERE
dat1<-dat

##CHANGE DEPENDING ON QX MANAGER VERSION--------
drop.v1<-0.00085 #version 1
drop.v2<-0.000795 #version 2
drop.size<-ifelse(any(str_detect(names(dat1), "Ch6")), drop.v2, drop.v1)

#change column names--------
dat1$Extraction.vol.ul<-dat1$Extraction.Volume #make sure Extraction Volume column name is correct
dat1$Filtration.vol.ml<-dat1$Filtration.Volume..mL. #make sure Filtration Volume column name is correct
dat1$Template.uL<-5
dat1$Reaction.vol.ul<-20 #change to your reaction volume
dat1$Correction.Factor<-dat1$Correction.Factor #make sure extraction kit Correction Factor column name is correct
dat1$dilution<-dat1$Sample.description.4

#add other columns if you want

dat1$sample.unique<-paste(dat1$Sample.description.1, dat1$Target, dat1$dilution) #make unique column

#autofill------------
#only need some columns
mtch<-c("sample.unique", 
        "Sample.description.1", "Sample.description.2", "Sample.description.3", "Sample.description.4",
        "Well", "MergedWells", "Target", "Conc.copies.µL.", 
        "TotalConfMax", "TotalConfMin",
        "PoissonConfMax", "PoissonConfMin", "Positives", "Negatives", 
        "Accepted.Droplets", 
        "TotalConfidenceMin68", "TotalConfidenceMax68", 
        "PoissonConfidenceMin68", "PoissonConfidenceMax68",
        "Filtration.vol.ml", "Extraction.vol.ul", "Template.uL", "Reaction.vol.ul",
        "Correction.Factor", "dilution")

dat3<-dat1[ ,match(mtch, colnames(dat1))]
dat1.m<-dat3[grepl("M", dat3$Well),] #only deal with merged wells
dat1.m$num<-1:nrow(dat1.m)

#QC checks-------
ntc<-dat3[grepl("NTC", dat3$sample.unique),match(c("sample.unique", "Target", "Well",
                                            "Positives","Negatives", 
                                            "Accepted.Droplets"), colnames(dat3))] #pull out no template controls
ntc$Positives #check that individual NTC well positives > 3

POS<-dat3[grepl("POS", dat3$sample.unique),match(c("sample.unique", "Target", 
                                            "Positives","Negatives", 
                                            "Accepted.Droplets"), colnames(dat3))] #pull out no template controls
POS$Positives #check that positive control positives < 3

dat1.m<-dat1.m[!grepl("NTC", dat1.m$sample.unique), ] #remove NTCs
dat1.m<-dat1.m[!grepl("POS", dat1.m$sample.unique), ] #remove positive controls

dat1.m$well.num<-str_count(dat1.m$MergedWells, ',')+1 #count number of wells that were merged
dat1.m<-subset(dat1.m, dat1.m$Accepted.Droplets>(dat1.m$well.num*10000))  #all wells should have 10,000
dat1.m<-subset(dat1.m, dat1.m$Negatives>5) #all merged wells have > 5 negative droplets

#convert to per microliter-------
dat1.m$Conc.copies.µL.<-as.numeric(as.character(dat1.m$Conc.copies.µL.))
dat1.m$Copies.ul<-((dat1.m$Conc.copies.µL.*Reaction.vol.ul)/dat1.m$Template.uL)*dat1.m$dilution 
dat1.m$PoissConfMaxcopiesperµL<-((dat1.m$PoissonConfMax*Reaction.vol.ul)/dat1.m$Template.uL)*dat1.m$dilution
dat1.m$PoissConfMincopiesperµL<-((dat1.m$PoissonConfMin*Reaction.vol.ul)/dat1.m$Template.uL)*dat1.m$dilution

#convert to different metrics--------
dat1.m$LOQ.Conc.<--log(1-(3/dat1.m$Accepted.Droplets))/drop.size
dat1.m$LOQ.ul<-(dat1.m$LOQ.Conc.*20)/dat1.m$Template.uL
dat1.m$LOQ.Filter<-dat1.m$LOQ.ul*dat1.m$Extraction.vol.ul #equivalent to LOQ.per.100ml if filter 100 ml
dat1.m$LOQ.per.100ml<-(dat1.m$LOQ.Filter/dat1.m$Filtration.vol.ml)*100
dat1.m$LOQ.per.L<-dat1.m$LOQ.per.100ml*10

#convert to per filter--------
dat1.m$Copies.Filter<-dat1.m$Copies.ul*dat1.m$Extraction.vol.ul
dat1.m$PoissConfMaxCopies.Filter<-dat1.m$PoissConfMaxcopiesperµL*dat1.m$Extraction.vol.ul
dat1.m$PoissConfMinCopies.Filter<-dat1.m$PoissConfMincopiesperµL*dat1.m$Extraction.vol.ul

#convert to per 100mL---------
dat1.m$Copies.100mL<-(dat1.m$Copies.Filter/dat1.m$Filtration.vol.ml)*100 #equivalent to Copies.Filter if filter 100 ml
dat1.m$PoissConfMaxCopiesper100mL<-(dat1.m$PoissConfMaxCopies.Filter/dat1.m$Filtration.vol.ml)*100
dat1.m$PoissConfMinCopiesper100mL<-(dat1.m$PoissConfMinCopies.Filter/dat1.m$Filtration.vol.ml)*100

#correction factor--------
dat1.m$Corr.Factor<-dat1.m$Correction.Factor

dat1.m$Copies.ulCorr<-dat1.m$Copies.ul*dat1.m$Corr.Factor
dat1.m$Copiesper100mlCorr<-dat1.m$Copies.100mL*dat1.m$Corr.Factor

dat1.m$PoissConfMaxCopiesper100mlCorr<-dat1.m$PoissConfMaxCopiesper100mL*dat1.m$Corr.Factor
dat1.m$PoissConfMinCopiesper100mlCorr<-dat1.m$PoissConfMinCopiesper100mL*dat1.m$Corr.Factor
dat1.m$CopiesperLCorr<-dat1.m$Copiesper100mlCorr*10
dat1.m$PoissConfMaxCopiesperLCorr<-dat1.m$PoissConfMaxCopiesper100mlCorr*10
dat1.m$PoissConfMinCopiesperLCorr<-dat1.m$PoissConfMinCopiesper100mlCorr*10

#flag if under LOQ-----------
dat1.m$underLOQ<-ifelse(dat1.m$Copies.ul<dat1.m$LOQ.ul, "under LOQ", "")

#confidence68--------
dat1.m$TotalConfidenceMin68perµL<-((dat1.m$TotalConfidenceMin68*Reaction.vol.ul)/dat1.m$Template.uL)*dat1.m$dilution
dat1.m$TotalConfidenceMax68perµL<-((dat1.m$TotalConfidenceMax68*Reaction.vol.ul)/dat1.m$Template.uL)*dat1.m$dilution

dat1.m$TotalConfidenceMin68.Filter<-dat1.m$TotalConfidenceMin68perµL*dat1.m$Extraction.vol.ul
dat1.m$TotalConfidenceMax68.Filter<-dat1.m$TotalConfidenceMax68perµL*dat1.m$Extraction.vol.ul
dat1.m$TotalConfidenceMin68.100mL<-(dat1.m$TotalConfidenceMin68.Filter/dat1.m$Filtration.vol.ml)*100
dat1.m$TotalConfidenceMax68.100mL<-(dat1.m$TotalConfidenceMax68.Filter/dat1.m$Filtration.vol.ml)*100
dat1.m$TotalConfidenceMin68.100mLCorr<-dat1.m$TotalConfidenceMin68.100mL*dat1.m$Corr.Factor
dat1.m$TotalConfidenceMax68.100mLCorr<-dat1.m$TotalConfidenceMax68.100mL*dat1.m$Corr.Factor
dat1.m$TotalConfidenceMin68.perLCorr<-dat1.m$TotalConfidenceMin68.100mLCorr*10
dat1.m$TotalConfidenceMax68.perLCorr<-dat1.m$TotalConfidenceMax68.100mLCorr*10

dat1.m$PoissonConfidenceMax68perµL<-((dat1.m$PoissonConfidenceMax68*20)/dat1.m$Template.uL)*dat1.m$dilution
dat1.m$PoissonConfidenceMin68perµL<-((dat1.m$PoissonConfidenceMin68*20)/dat1.m$Template.uL)*dat1.m$dilution
dat1.m$PoissonConfidenceMax68.Filter<-dat1.m$PoissonConfidenceMax68perµL*dat1.m$Extraction.vol.ul
dat1.m$PoissonConfidenceMin68.Filter<-dat1.m$PoissonConfidenceMin68perµL*dat1.m$Extraction.vol.ul
dat1.m$PoissonConfidenceMax68.100mL<-(dat1.m$PoissonConfidenceMax68.Filter/dat1.m$Filtration.vol.ml)*100
dat1.m$PoissonConfidenceMin68.100mL<-(dat1.m$PoissonConfidenceMin68.Filter/dat1.m$Filtration.vol.ml)*100
dat1.m$PoissonConfidenceMax68.100mLCorr<-dat1.m$PoissonConfidenceMax68.100mL*dat1.m$Corr.Factor
dat1.m$PoissonConfidenceMin68.100mLCorr<-dat1.m$PoissonConfidenceMin68.100mL*dat1.m$Corr.Factor
dat1.m$PoissonConfidenceMax68.perLCorr<-dat1.m$PoissonConfidenceMax68.100mLCorr*10
dat1.m$PoissonConfidenceMin68.perLCorr<-dat1.m$PoissonConfidenceMin68.100mLCorr*10

#QC check for CI------------
#95 Poisson check
ifelse(grepl("FAIL", dat1.m$sample.unique), "fail QC", 
       ifelse(dat1.m$Copiesper100mlCorr<dat1.m$PoissConfMaxCopiesper100mlCorr, "true", "FAIL"))
ifelse(grepl("FAIL", dat1.m$sample.unique), "fail QC", 
       ifelse(dat1.m$Positives==0, "zero pos.", 
              ifelse(dat1.m$Copiesper100mlCorr>dat1.m$PoissConfMinCopiesper100mlCorr, "true", "FAIL")))

#68 total check
ifelse(grepl("FAIL", dat1.m$sample.unique), "fail QC", 
       ifelse(dat1.m$Copiesper100mlCorr<dat1.m$TotalConfidenceMax68.100mLCorr, "true", "FAIL"))
ifelse(grepl("FAIL", dat1.m$sample.unique), "fail QC", 
       ifelse(dat1.m$Positives==0, "zero pos.", 
              ifelse(dat1.m$Copiesper100mlCorr>dat1.m$TotalConfidenceMin68.100mLCorr, "true", "FAIL")))

#export------------
write.csv(dat1.m, row.names = F,
          "YOUR FILEPATH HERE")


