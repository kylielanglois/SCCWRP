args <- commandArgs(trailingOnly = TRUE)
str(args)
cat(args, sep = "\n")

library(reshape2)
library(ggplot2)

wp0 <- args[1]
wp1 <- args[2]
wp2 <- args[3]
q1<-read.delim(file.path(wp1, "mqc_fastqc_per_base_sequence_quality_plot_1.txt"), head=T)
q2<-read.delim(file.path(wp2, "mqc_fastqc_per_base_sequence_quality_plot_1.txt"), head=T)

q.list<-list(q1, q2)

for (i in 1:length(q.list)) {
  dat1<-q.list[[i]]
  
  q1.m<-melt(dat1)
  h1 <- qplot(q1.m$value, geom="histogram")
  df<-as.data.frame(ggplot_build(h1)$data)
  
  m<-round(df$x[df$count == max(df$count)], 1)
  assign(paste0("maxQ_", i), m)
}

write.table(maxQ_1, file=file.path(wp0, "maxQ_R1.txt"), row.names=F)
write.table(maxQ_2, file=file.path(wp0, "maxQ_R2.txt"), row.names=F)