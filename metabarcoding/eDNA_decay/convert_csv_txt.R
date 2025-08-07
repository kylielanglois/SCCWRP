args <- commandArgs(trailingOnly = TRUE)
str(args)
cat(args, sep = "\n")

wp0 <- args[1]

files <- list.files(wp0, pattern=".csv", full.names = TRUE)
file.names <- list.files(wp0, pattern=".csv")
file.names <- gsub("\\.csv", "\\.txt", file.names)

#read all files in "files"
out <- lapply(files,function(x) {
  read.csv(x)   
})

#write all files in "files"
w <- 1:length(out) 
for(i in w){
  write.table(out[i], row.names=F, sep="\t",
              file.path(wp0, file.names[i]))
}
