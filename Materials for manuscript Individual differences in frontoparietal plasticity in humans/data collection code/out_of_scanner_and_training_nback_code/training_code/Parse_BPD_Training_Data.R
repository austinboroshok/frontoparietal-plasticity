# Austin Boroshok: 2/20/19
# Required Inputs:
  # clone git repo N-Back, copy N-Back/data_behav/BPD*training*.csv into working directory
  # remove unecessary/excluded training files
  # make sure you remove training files if there is also a CORRECTED training .csv with same subID
  # rename any CORRECTED training .csv files to match normal format (BPD0###_training_##_##_##_######.csv)
  # make sure there are no other .csv files in working dir before running: script is looking for any .csv files to loop through


setwd("/Users/mackeylab-adm/Documents/training_behavioral_data/") # set working directory to wherever you copied the training .csv files

filenames <- Sys.glob("*.csv") # search for any .csv files in the current working directory and set them to variable called "filenames"

df <- cbind('subID','TotalTrials','HighestNback','TrialsAt2Back','TrialsAt3Back','TrialsAt4Back','TrialsAt5Back','TrialsAt6Back','TrialsAt7PlusBack','TrialsAtHighestNback','PercentAt2Back','PercentAt3Back','PercentAt4Back','PercentAt5Back','PercentAt6Back','PercentAt7PlusBack','PercentAtHighestNback')
write.table(df,"BPD_Training_Data.csv",sep=",",row.names = FALSE, col.names=FALSE,append=TRUE) # creates data frame for variables (made a few steps later) to be matched to; writes data frame headers to output .csv file (filled with data a few steps later)

for (filename in filenames) { # open for loop to go iteratively through each .csv file in current directory
  ## print(filename) # sanity check step to see that it's actually looping through the files
  
  trainingfile<-read.csv(file=filename,header=TRUE,sep=",") # allows R to read each .csv file
  attach(trainingfile) # attaches header row to let R read them faster without needing the $ every time)

  subID <-strsplit(filename, "_")[[1]][1] # splits each .csv file based on underscore delimiter to get BPD#### ID

  ## nrow(trainingfile) 
  TotalTrials<-nrow(trainingfile) # calculates total number of trials participant completed and sets this to variable called "TotalTrials"
  
  ## max(Nback)
  HighestNback<-max(Nback) # calculates highest Nback level participant got to and sets this as variable called "HighestNback"
  
  TrialsAtHighestNback<-sum(Nback==HighestNback, na.rm=TRUE) # calculates no. of trials spent at highest nback level and sets this as variable called "TrialsAtHighestNback"
  PercentAtHighestNback<-(TrialsAtHighestNback/TotalTrials) # calculates % of trials spent at hgihest nback levels (relative to all other nback levels) and sets this as variable called "PercentAtHighestNback"

  TrialsAt2Back<-sum(Nback == 2, na.rm=TRUE) # calculates no. of trials spent a 2-,3-,4-,5-,6-, and 7+-back
  TrialsAt3Back<-sum(Nback == 3, na.rm=TRUE)
  TrialsAt4Back<-sum(Nback == 4, na.rm=TRUE)
  TrialsAt5Back<-sum(Nback == 5, na.rm=TRUE)
  TrialsAt6Back<-sum(Nback == 6, na.rm=TRUE)
  TrialsAt7PlusBack<-sum(Nback >= 7, na.rm=TRUE)
  
  PercentAt2Back<-(TrialsAt2Back/TotalTrials) # calculates % of trials spent a 2-,3-,4-,5-,6-, and 7+-back
  PercentAt3Back<-(TrialsAt3Back/TotalTrials)
  PercentAt4Back<-(TrialsAt4Back/TotalTrials)
  PercentAt5Back<-(TrialsAt5Back/TotalTrials)
  PercentAt6Back<-(TrialsAt6Back/TotalTrials)
  PercentAt7PlusBack<-(TrialsAt7PlusBack/TotalTrials)
  
  df <- cbind(subID,TotalTrials,HighestNback,TrialsAt2Back,TrialsAt3Back,TrialsAt4Back,TrialsAt5Back,TrialsAt6Back,TrialsAt7PlusBack,TrialsAtHighestNback,PercentAt2Back,PercentAt3Back,PercentAt4Back,PercentAt5Back,PercentAt6Back,PercentAt7PlusBack,PercentAtHighestNback)
  write.table(df,"BPD_Training_Data.csv",sep=",",row.names=FALSE, col.names=FALSE,append=TRUE) # matches all newly-calculated to existing headers in data frame you created at beginning, and then writes that data frame to the output file you created at the beginning
} # close for loop


