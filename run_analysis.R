## run analysis steps

keepClean <- TRUE # clean up workspace as you go
print("run_analysis started")
# check for data in working directory
rawFile <- "uci_har.zip"
if (!file.exists(rawFile)) {
        stop(rawFile," not in working directory")
}
# load packages needed later on
if (!require(dplyr)) {
        install.packages("dplyr")
        library(dplyr)
}
if (!require(tidyr)) {
        install.packages("tidyr")
        library(tidyr)
}

## 1. Merge the training and the test sets to create one data set.

# constants for downloading the raw data
fileSep <- "\\" # windows file separator value
rawDir <- "rawdata"
rawSubDir <- paste(rawDir, fileSep, "UCI HAR Dataset", sep="")
resultFile <- "subjActVarAvg.txt"
# extract raw data to subdirectory of working directory, if needed
if (!file.exists(rawDir)) {
        print("Create directory for raw data")
        dir.create(rawDir)
}
if (!file.exists(rawSubDir)) {
        print("Unzip raw data")
        unzip(rawFile, exdir=rawDir) # overwrites files
        # remove holdX to force calc with new unzip of data
        if (exists("holdX")) {rm(holdX)} 
        # remove result file from earlier run, if it exists
        if(file.exists(resultFile)) {
                file.remove(resultFile)
        }
} else {
        print("Raw data already unzipped")
}
# constants
baseDir <- paste(rawSubDir, fileSep, sep="")
testDir <- paste(baseDir, "test", fileSep, sep="")
trainDir <- paste(baseDir, "train", fileSep, sep="")
# holdX exists means X is complete and current, skip rebuilding X to save time
if (!exists("holdX") | !exists("X")) { 
        print("Merge test and training datasets...")
        # build Test Set (X) by merging the train and test information for X
        X <- read.table(paste(trainDir, "X_train.txt", sep=""), 
                        stringsAsFactors=FALSE
                        )
        tempX <- read.table(paste(testDir, "X_test.txt", sep=""), 
                           stringsAsFactors=FALSE
                           )
        X <- rbind(X, tempX)
        if (keepClean) {rm(tempX)}
        # get features for column names of X
        features <- read.table(paste(baseDir, "features.txt", sep=""), 
                               stringsAsFactors=FALSE
                               )
        # set features as column names of X
        colnames(X) <- features[,2]
        if (keepClean) {rm(features)}
        # build Subject Set (subject) by merging the train and test information 
        # for subject
        subject <- read.table(paste(trainDir, "subject_train.txt", sep=""), 
                              stringsAsFactors=FALSE
                              )
        tempSubj <- read.table(paste(testDir, "subject_test.txt", sep=""), 
                              stringsAsFactors=FALSE
                              )
        subject <- rbind(subject, tempSubj)
        if (keepClean) {rm(tempSubj)}
        colnames(subject) <- c("subject")
        # build Activity Set (y) by merging the train and test info for y
        y <- read.table(paste(trainDir, "y_train.txt", sep=""), 
                        stringsAsFactors=FALSE
                        )
        tempy <- read.table(paste(testDir, "y_test.txt", sep=""), 
                            stringsAsFactors=FALSE
                            )
        y <- rbind(y, tempy)
        if (keepClean) {rm(tempy)}
        colnames(y) <- c("activity")
        # add subject and y to Test Set (X)
        X <- cbind(subject, y, X)
        if (keepClean) {
                rm(subject)
                rm(y)
        }
        holdX <- TRUE # X is complete and current
        print("Merge test and training datasets complete")
} else {
        print("Reuse previously merged test and training datasets")
}

## 2. Extract only the measurements on the mean and standard deviation for each 
##    measurement.

print("Extract mean and standard deviation measurements")
# filter column names to keep only -mean() and -std() columns
colsToKeep <- grep("[-](mean|std)[(]", # check using -mean( and -std(
                   colnames(X)
                   )
# keep the first two columns as well: subject and activityId
colsToKeep <- c(c(1, 2), 
                colsToKeep
                )
meanAndStd <- X[,colsToKeep]
if (keepClean) {
        rm(colsToKeep)
        # X could be removed here, but will clean up in a later step to 
        # avoid having to recreate every script run
}

## 3. Use descriptive activity names to name the activities in the data set

print("Use descriptive activity names")
# get the activity ids and names
activity <- read.table(paste(baseDir, "activity_labels.txt", sep=""),
                       stringsAsFactors=FALSE
                       )
colnames(activity) <- c("activityId", "activity")
# replace activity with its label in the Test Set (X)
meanAndStd$activity <- activity$activity[
        match(meanAndStd$activity, activity$activityId)
        ]
if (keepClean) {
        rm(activity)
        # done with constants too
        rm(trainDir)
        rm(testDir)
        rm(baseDir)
        rm(rawFile)
        rm(rawSubDir)
        rm(rawDir)
        rm(fileSep)
}

## 4. Appropriately label the data set with descriptive variable names. 

print("Tidy up the assembled data")
# tidy the sensors and their signals
df <- tbl_df(meanAndStd)
if (keepClean) {
        rm(meanAndStd)
        # catch up X cleanup
        rm(X)
        rm(holdX)
}
tidy <- df %>%
        gather(sensor, signal, -subject, -activity)
if (keepClean) {rm(df)}

## 5. From the data set in step 4, creates a second, independent tidy data set 
##    with the average of each variable for each activity and each subject.

print("Calculate averages for each variable of each activity of each subject")
# group by subject, activity and sensor; compute average
average <- tidy %>%
        group_by(subject, activity, sensor) %>%
        summarize(mean(signal))
if (keepClean) {rm(tidy)}
# write averages to file to working directory
print(paste("Write averages to working directory as:",resultFile))
write.table(average, file=resultFile, row.name=FALSE)
if (keepClean) {
        rm(average)
        rm(resultFile)
}
print("run_analysis complete")
