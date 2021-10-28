setwd("/Users/mackeylab-adm/Downloads/test/")

pre_filenames <- Sys.glob("*pre*.csv")
post_filenames <- Sys.glob("*post*.csv")

for (pre_filename in pre_filenames) {
  pre_filedata<-read.csv(file=pre_filename,header=TRUE,sep=",")
  attach(pre_filedata)
  subID <-strsplit(pre_filename, "_")[[1]][1]
  first2bkblock <- read.csv(file=pre_filename,nrows=24)
  write.csv(first2bkblock,paste0(subID,"_pre_firstblocks.csv"),sep=",",row.names=FALSE, col.names=FALSE,append=TRUE)

  first3bkblock <- read.csv(file=pre_filename,skip = 24,nrows = 24) 
  write.table(first3bkblock,paste0(subID,"_pre_firstblocks.csv"),sep=",",row.names=FALSE, col.names=FALSE,append=TRUE)
  
  first4bkblock <- read.csv(file=pre_filename,skip = 48,nrows = 24) 
  write.table(first4bkblock,paste0(subID,"_pre_firstblocks.csv"),sep=",",row.names=FALSE, col.names=FALSE,append=TRUE)

  df <- cbind('Trial','Nback','Sound','Response','RT_seconds','NBackTrue','isCorrect')
  write.table(df,paste0(subID,"_pre_secondblocks.csv"),sep=",",row.names = FALSE, col.names=FALSE,append=TRUE)
    
  second2bkblock <-read.csv(file=pre_filename,skip=72,nrows=24)
  write.table(second2bkblock,paste0(subID,"_pre_secondblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
  second3bkblock <-read.csv(file=pre_filename,skip=96,nrows=24)
  write.table(second3bkblock,paste0(subID,"_pre_secondblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
  second4bkblock <-read.csv(file=pre_filename,skip=120,nrows=24)
  write.table(second4bkblock,paste0(subID,"_pre_secondblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
  df <- cbind('Trial','Nback','Sound','Response','RT_seconds','NBackTrue','isCorrect')
  write.table(df,paste0(subID,"_pre_thirdblocks.csv"),sep=",",row.names = FALSE, col.names=FALSE,append=TRUE)
  
  third2bkblock <-read.csv(file=pre_filename,skip=144,nrows=24)
  write.csv(third2bkblock,paste0(subID,"_pre_thirdblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
  third3bkblock <-read.csv(file=pre_filename,skip=168,nrows=24)
  write.table(third3bkblock,paste0(subID,"_pre_thirdblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
  third4bkblock <-read.csv(file=pre_filename,skip=192,nrows=24)
  write.table(third4bkblock,paste0(subID,"_pre_thirdblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
  df <- cbind('Trial','Nback','Sound','Response','RT_seconds','NBackTrue','isCorrect')
  write.table(df,paste0(subID,"_pre_fourthblocks.csv"),sep=",",row.names = FALSE, col.names=FALSE,append=TRUE)
  
  fourth2bkblock <-read.csv(file=pre_filename,skip=216,nrows=24)
  write.csv(fourth2bkblock,paste0(subID,"_pre_fourthblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
  fourth3bkblock <-read.csv(file=pre_filename,skip=240,nrows=24)
  write.table(fourth3bkblock,paste0(subID,"_pre_fourthblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
  fourth4bkblock <-read.csv(file=pre_filename,skip=264,nrows=24)
  write.table(fourth4bkblock,paste0(subID,"_pre_fourthblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
}



for (post_filename in post_filenames) {
  post_filedata<-read.csv(file=post_filename,header=TRUE,sep=",")
  attach(post_filedata)
  subID <-strsplit(post_filename, "_")[[1]][1]
  first2bkblock <- read.csv(file=post_filename,nrows=24)
  write.csv(first2bkblock,paste0(subID,"_post_firstblocks.csv"),sep=",",row.names=FALSE, col.names=FALSE,append=TRUE)
  
  first3bkblock <- read.csv(file=post_filename,skip = 24,nrows = 24) 
  write.table(first3bkblock,paste0(subID,"_post_firstblocks.csv"),sep=",",row.names=FALSE, col.names=FALSE,append=TRUE)
  
  first4bkblock <- read.csv(file=post_filename,skip = 48,nrows = 24) 
  write.table(first4bkblock,paste0(subID,"_post_firstblocks.csv"),sep=",",row.names=FALSE, col.names=FALSE,append=TRUE)
  
  df <- cbind('Trial','Nback','Sound','Response','RT_seconds','NBackTrue','isCorrect')
  write.table(df,paste0(subID,"_post_secondblocks.csv"),sep=",",row.names = FALSE, col.names=FALSE,append=TRUE)
  
  second2bkblock <-read.csv(file=post_filename,skip=72,nrows=24)
  write.table(second2bkblock,paste0(subID,"_post_secondblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
  second3bkblock <-read.csv(file=post_filename,skip=96,nrows=24)
  write.table(second3bkblock,paste0(subID,"_post_secondblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
  second4bkblock <-read.csv(file=post_filename,skip=120,nrows=24)
  write.table(second4bkblock,paste0(subID,"_post_secondblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
  df <- cbind('Trial','Nback','Sound','Response','RT_seconds','NBackTrue','isCorrect')
  write.table(df,paste0(subID,"_pre_thirdblocks.csv"),sep=",",row.names = FALSE, col.names=FALSE,append=TRUE)
  
  third2bkblock <-read.csv(file=post_filename,skip=144,nrows=24)
  write.csv(third2bkblock,paste0(subID,"_post_thirdblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
  third3bkblock <-read.csv(file=post_filename,skip=168,nrows=24)
  write.table(third3bkblock,paste0(subID,"_post_thirdblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
  third4bkblock <-read.csv(file=post_filename,skip=192,nrows=24)
  write.table(third4bkblock,paste0(subID,"_post_thirdblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
  df <- cbind('Trial','Nback','Sound','Response','RT_seconds','NBackTrue','isCorrect')
  write.table(df,paste0(subID,"_post_fourthblocks.csv"),sep=",",row.names = FALSE, col.names=FALSE,append=TRUE)
  
  fourth2bkblock <-read.csv(file=post_filename,skip=216,nrows=24)
  write.csv(fourth2bkblock,paste0(subID,"_post_fourthblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
  fourth3bkblock <-read.csv(file=post_filename,skip=240,nrows=24)
  write.table(fourth3bkblock,paste0(subID,"_post_fourthblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
  fourth4bkblock <-read.csv(file=post_filename,skip=264,nrows=24)
  write.table(fourth4bkblock,paste0(subID,"_post_fourthblocks.csv"),sep=",",row.names = FALSE,col.names = FALSE,append = TRUE)
  
}
