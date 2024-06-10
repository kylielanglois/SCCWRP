#change sourcetracker mapping file column "SS" from source --> sink
#run sourcetracker for each change
library(tidyverse)
library(ggplot2)
library(reshape2)

#---------- import mapping file ---------- 
path<-"/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/all_biofilm_16S_V4V5_030322_filtered_analysis/sourcetracker_manip_071323/"
map<-read.csv(file.choose(), head=T)
#metadata file
map0<-map
map0$SS<-ifelse(map0$Sample.Type=="SEWER", "source",
                ifelse(map0$Sample.Type=="STORMDRAIN", "source", "sink"))

#---------- leave one out ---------- 
r<-which(map0$SS=="source")     #get rows of "source"

for(i in r){
  assign(paste0("mp", i), as.data.frame(map0))   #make new dataframes
}

mm<-do.call("list", mget(sprintf("mp%d", r)))  #put new dataframes in list
rm(list=ls(pattern="mp"))     #remove newly created dataframes (still stored in mm)

mm0<-list()   #empty list

for(i in 1:length(r)){      #number of "source" rows
  dat <- mm[[i]]    #create new dataframe for inside loop
  a<-which(dat$SS=="source")[i]     #get row number of "source"
  dat$SS[a]<-"sink"     #change just that row from "source" to "sink"
  mm0[[i]]<-assign(paste0("map", i), as.data.frame(dat))       #add to empty list and new dataframe names
}
 
#---------- export ---------- 
mm1<-do.call("list", mget(sprintf("map%d", 1:length(r))))  #put new dataframes in list
sapply(names(mm1),
       function(x) write.table(x = mm1[[x]], row.names = F, 
                               file=paste0(path, paste(x, "txt", sep=".")), sep = "\t"))
#need to be "file=paste0()" NOT "file=paste()"
#need to be "\t" NOT " \t"

#---------- get sourcetracker code ---------- 

path <- "/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/all_biofilm_16S_V4V5_030322_filtered_analysis/sourcetracker_manip_071323/" #path to parent directory
local.path <- "/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/all_biofilm_16S_V4V5_030322_filtered_analysis/sourcetracker_manip_071323/"
table <- file.path(path, "all_biofilm_16S_V4V5_030322_pairedend_demux_trimmed_dada2_table_nozero_BFonly.csv") #path to table, MUST BE IN BIOM FORMAT
results.path <- file.path(path, "results_LOO") #path to results directory, within parent directory
map.path <- file.path(path, "metadata_LOO") #folder with LOO metadata files from R code, within parent directory
maps <- list.files(file.path(local.path, "metadata_LOO"), full.names = F) #list of mapping files

code.st2<-list()
for(i in 1:length(maps)){
  map.loo<-paste(map.path, maps[i], sep="/")
  results.loo<-paste0("results_loo_", i)
  st<-paste0("sourcetracker2 -i ", table,
           " -m ", map.loo,
           " --source_rarefaction_depth 0 --sink_rarefaction_depth 0 --jobs 4 --per_sink_feature_assignments --source_sink_column SS --source_column_value source --sink_column_value sink ", 
           "-o ", results.path, "/", results.loo, sep="")
  code.st2[i]<-st

}

code.st2.df<-do.call(rbind.data.frame, code.st2)

write.table(code.st2.df, file.path(local.path, "code_st2_loo_071323.txt"), row.names = F, sep = " \t")
#export
#open in atom.io
#save as .sh

#---------- to do in san gabriel ---------- 

# ssh -X root@172.16.1.76
# 3535Harbor
# cd ..
# cd home/kyliel/sourcetracker_manip_011323
# conda activate st2
# chmod +x [[CODE HERE]]
# ./[[CODE HERE]]

##---------- get results of LOO ---------- 
path <- "/Users/kylielanglois/Desktop/sourcetracker_manip_010423/results_LOO/"
files <- list.files(path, full.names = TRUE)

mix <- sort(list.files(files, pattern="mixing_proportions.txt", full.names = TRUE))

out <- lapply(mix,function(x) {
  read.delim(x)   
}) #read all files 

out.df<-as.data.frame(out) #put all files together
out.df.t<-as.data.frame(t(out.df)) #rows as samples, columns as sources
colnames(out.df.t)<-out.df.t[1, ] #put sources as column names
outout.df.t.df<-out.df.t[-1,] #remove first row (former sources)
out.df.t$SampleID<-rownames(out.df.t)

#import LOO data-------------
loo<-read.csv("/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/all_biofilm_16S_V4V5_030322_filtered_analysis/sourcetracker_manip_071323/demux_all_biofilm_metadata_030322_BFonly_sourcetracker_LOO_mixing_prop.csv")
loo1<-loo

#import mapping file ------------
map<-read.csv("/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/all_biofilm_16S_V4V5_030322_filtered_analysis/demux_all_biofilm_metadata_030322_BFonly.csv")
#metadata file
map0<-map

#plot-------------
map0<-map0[!grepl("REMOVE", map0$redo_discard), ]
r<-map0[grepl("source", map0$sourcetracker1), ]
r.samp<-paste0(r$sample.full.name, collapse = "|")

out.df.r<-loo1[grepl(r.samp, loo1$Sample.ID), ] #take all source samples from LOO results
#not need below for full data set
df.r<-paste0(out.df.r$Sample.ID, collapse = "|")
map.r<- r[grepl(df.r, r$sample.full.name), ] #take only some out of metadata file

df.map.r.m<-melt(out.df.r, id.vars = "Sample.ID")
df.map.r.m$value<-as.numeric(as.character(df.map.r.m$value))
df.map.r.m<-merge(df.map.r.m, map.r, by.x="Sample.ID", by.y="sample.full.name", all.x = T) #get original source env

bf<-c("#c70505", "#aa8109", "grey")
g.r<-ggplot(df.map.r.m)+
  geom_bar(aes(x=LOC_EVENT_ID, y=value, fill=variable), 
           stat = "identity")+
  scale_fill_manual(values=bf)+
  facet_grid(~Sample.Type*Jurisdiction, scales = "free_x", space="free")+
  theme(axis.text.x = element_text(angle=60, hjust=1, size=10))+
  labs(y="proportion", x="", fill="sources")
g.r

ggsave(plot=g.r, 
       "sourcetracker_LOO_results_071323.pdf", 
       path = "/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/all_biofilm_16S_V4V5_030322_filtered_analysis/sourcetracker_manip_071323/",
       height = 8, width = 16)

#export condensed sourcetracker-------------
out.df.r.map<-merge(out.df.r, map.r, by.x="Sample.ID", by.y="SampleID", all.x = T)
out.df.r.map$SEWER<-as.numeric(out.df.r.map$SEWER)
out.df.r.map$STORMDRAIN<-as.numeric(out.df.r.map$STORMDRAIN)
out.df.r.map$result.50perc<-ifelse(out.df.r.map$SEWER>0.5, "SEWER", 
                                   ifelse(out.df.r.map$STORMDRAIN>0.5, "STORMDRAIN", "unknown"))
out.df.r.map$result.75perc<-ifelse(out.df.r.map$SEWER>0.75, "SEWER", 
                                   ifelse(out.df.r.map$STORMDRAIN>0.75, "STORMDRAIN", "unknown"))
out.df.r.map$result.90perc<-ifelse(out.df.r.map$SEWER>0.9, "SEWER", 
                                   ifelse(out.df.r.map$STORMDRAIN>0.9, "STORMDRAIN", "unknown"))
sum(out.df.r.map$Env==out.df.r.map$result.50perc) #86
sum(out.df.r.map$Env==out.df.r.map$result.75perc) #73
sum(out.df.r.map$Env==out.df.r.map$result.90perc) #42

write.csv(out.df.r.map, row.names = F,
          "/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/all_biofilm_16S_V4V5_030322_filtered_analysis/sourcetracker_manip_071323/demux_all_biofilm_metadata_030322_BFonly_sourcetracker_LOO_results_condensed.csv")

#import sourcetracker data-------------
s<-read.csv("/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/all_biofilm_16S_V4V5_030322_filtered_analysis/all_biofilm_16S_030322_sourcetracker_mixing_proportions_metadata.csv")
s1<-s

m<-read.csv("/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/all_biofilm_16S_V4V5_030322_filtered_analysis/demux_all_biofilm_metadata_030322_BFonly.csv")
m1<-m

sm<-merge(m1, s1, by.x="sample.full.name", by.y="SAMPLE.ID", all.y=T)
sm<-sm[grepl("STORMWATER|EXP", sm$Sample.Type), ]
sm<-sm[!grepl("REMOVE", sm$redo_discard),]

sm$ID_EVENT<-paste(sm$SAMPLE_NAME.y, sm$STORM_EVENT)
sm$EXPERIMENT<-as.numeric(sm$EXPERIMENT)
sm<-sm[order(sm$EXPERIMENT), ]
sm$ID_EVENT<-factor(sm$ID_EVENT, levels=unique(sm$ID_EVENT))

sm.m<-melt(sm[,match(c("ID_EVENT", "SEWER", "STORMDRAIN", "Unknown"), colnames(sm))], id.vars = "ID_EVENT")
sm.m$value<-as.numeric(as.character(sm.m$value))
sm.m.map<-merge(sm.m, sm, by="ID_EVENT", all.x = T) #get original source env

bf<-c("#c70505", "#aa8109", "grey")
g.r<-ggplot(sm.m.map)+
  geom_bar(aes(x=ID_EVENT, y=value, fill=variable), 
           stat = "identity")+
  scale_fill_manual(values=bf)+
  facet_grid(~Sample.Type*Event, scales = "free_x", space="free")+
  theme(axis.text.x = element_text(angle=45, hjust=1, size=10))+
  labs(y="proportion", x="", fill="sources")
g.r

ggsave(plot=g.r, 
       "sourcetracker_results_030322_BFonly.pdf", 
       path = "/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/all_biofilm_16S_V4V5_030322_filtered_analysis/",
       height = 8, width = 16)

#pollutograph only-------------
sm<-merge(m1, s1, by.x="sample.full.name", by.y="SAMPLE.ID", all.y=T)
sm<-sm[grepl("POLLUT", sm$TYPE), ]
sm<-sm[!grepl("REMOVE", sm$redo_discard),]

sm$ID_EVENT<-sm$SAMPLE_NAME.y
sm$SAMPLE_TYPE<-gsub("COMP", "", sm$SAMPLE_TYPE)
sm$SAMPLE_TYPE_NUM<-as.numeric(sm$SAMPLE_TYPE)
sm<-sm[order(sm$SAMPLE_TYPE_NUM), ]
sm$ID_EVENT<-factor(sm$ID_EVENT, levels=unique(sm$ID_EVENT))

sm.m<-melt(sm[,match(c("ID_EVENT", "SEWER", "STORMDRAIN", "Unknown"), colnames(sm))], id.vars = "ID_EVENT")
sm.m$value<-as.numeric(as.character(sm.m$value))
sm.m.map<-merge(sm.m, sm, by="ID_EVENT", all.x = T) #get original source env

bf<-c("#c70505", "#aa8109", "grey")
g.r<-ggplot(sm.m.map)+
  geom_bar(aes(x=ID_EVENT, y=value, fill=variable), 
           stat = "identity")+
  scale_fill_manual(values=bf)+
  facet_grid(~LOCATION, scales = "free_x", space="free")+
  theme(axis.text.x = element_text(angle=45, hjust=1, size=10))+
  labs(y="proportion", x="", fill="sources")
g.r

ggsave(plot=g.r, 
       "sourcetracker_results_030322_PG_only.pdf", 
       path = "/Users/kylielanglois/OneDrive - SCCWRP/SD I-O data/all_biofilm_16S_V4V5_030322_filtered_analysis/",
       height = 8, width = 16)
