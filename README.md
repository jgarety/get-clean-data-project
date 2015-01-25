# get-clean-data-project
Getting and Cleaning Data Course Project

##Script run_analysis.R
This script runs the analysis needed for the Getting and Cleaning Data Course Project.  It assumes the data file has been downloaded from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip to the working directory and is called uci_har.zip.  The results of this script will be a file written to the working directory called subjActVarAvg.txt.  The script also assumes it is running under the Windows operating system.  Remember to download the data file with mode="wb" to properly download the content.

When invoked, the script will first verify the uci_har.zip file exists in the working directory.  Assuming it does, the script will make sure packages dplyr and tidyr are installed and loaded/attached for use later in the script.  A rawdata sub-directory will be created in the working directory if it does not exist.  If the uci_har.zip file top directory does not exist in the rawdata sub-directory, uci_har.zip will be unzipped to rawdata; otherwise, the existing unzipped data will be processed.

The test and training data sets are read and merged together in the following order:

1. Measurement data (X) is assembled first

2. Feature names are added to the columns of X

3. Subject column is added to X

4. Activity Set (y) is added to X

The result of the previous steps is the assembled data set.  The mean and standard deviation columns are extracted, along with the subject and activity columns.  The activity information is then replaced with human-readable values.  The data set has different sensors, with correspondng signal values, as separate columns and this is not tidy.  These columns are gathered together in the sensor and signal columns to tidy the data.

Once the data set has been assembled and tidied up, it can be used in the final steps of the script; calculating the averages of each sensor variable of each activity of each subject.  The data set is grouped by those columns and the average is calculated.  The results are written the the working directory in the file subjActVarAvg.txt.

####Special Note
This script cleans up after itself except for one value; keepClean.  Anyone wishing to analyze the script itself can change the value of keepClean in the script to FALSE before running it.  This change will keep all the intermediate variable in place instead of removing them.  After the first run with keepClean FALSE, the merging of the test and training data sets will be reused from the previous run instead of being rebuilt.  This will save processing time if you're only concerned about the steps that follow the data being assembled.  Removing holdX, rm(holdX), will force the next run to rebuild X.
