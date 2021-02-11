# Coursera Course: Getting and Cleaning Data
# Final Course Project
# Darrell Gerber
#
# Data Source:  
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  
# Requirements:
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for 
#    each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.


library(dplyr)


# Define the file locations of the raw data and load it in
featuresFile = "./RawData/UCI HAR Dataset/features.txt"
ActivityFile = "./RawData/UCI HAR Dataset/activity_labels.txt"
X_TestFile = "./RawData/UCI HAR Dataset/test/X_test.txt"
Y_TestFile = "./RawData/UCI HAR Dataset/test/Y_test.txt"
Sub_TestFile = "./RawData/UCI HAR Dataset/test/Subject_test.txt"
X_TrainFile = "./RawData/UCI HAR Dataset/train/X_train.txt"
Y_TrainFile = "./RawData/UCI HAR Dataset/train/Y_train.txt"
Sub_TrainFile = "./RawData/UCI HAR Dataset/train/Subject_train.txt"
# Load in all of the files we need
features <- (read.table(featuresFile,stringsAsFactors=FALSE))
activities <- (read.table(ActivityFile,stringsAsFactors=FALSE))
X_Test <- (read.table(X_TestFile,stringsAsFactors=FALSE))
Y_Test <- (read.table(Y_TestFile,stringsAsFactors=FALSE))
Sub_Test <- (read.table(Sub_TestFile,stringsAsFactors=FALSE))
X_Train <- (read.table(X_TrainFile,stringsAsFactors=FALSE))
Y_Train <- (read.table(Y_TrainFile,stringsAsFactors=FALSE))
Sub_Train <- (read.table(Sub_TrainFile,stringsAsFactors=FALSE))

# 1. Arrange the data sets and attach them
Test <- cbind(Sub_Test, Y_Test, X_Test, make.row.names = FALSE )
Train <- cbind(Sub_Train, Y_Train,X_Train, make.row.names = FALSE )
combinedData <- rbind(Test, Train, make.row.names = FALSE)
# Attach the variable names
features <- cbind("Subject","Activity", t(features), make.row.names = FALSE)
names(combinedData) <- features[2,]
# combinedData <- rbind(features[2,], combinedData, make.row.names = FALSE)

# 2. Remove all columns that don't have 'mean' or 'std' in the variable name
trimmedData <- combinedData[,grep("(mean|std|Subject|Activity)", names(combinedData) )]

# 3. Replace Activity Numbers with Names
trimmedData[,2] <- activities[trimmedData[,2],2]

# 4. Replace variable names with plain language versions and 
#    clean up special characters
colnames(trimmedData) <- gsub("tBodyAcc", "Body.Accelerometer.Time.Domain", colnames(trimmedData))
colnames(trimmedData) <- gsub("tGravityAcc", "Gravity.Accelerometer.Time.Domain", colnames(trimmedData))
colnames(trimmedData) <- gsub("fBodyAcc", "Body.Accelerometer.Frequency.Domain", colnames(trimmedData))
colnames(trimmedData) <- gsub("fGravityAcc", "Gravity.Accelerometer.Frequency.Domain", colnames(trimmedData))
colnames(trimmedData) <- gsub("tBodyGyro", "Body.Gyroscope.Time.Domain", colnames(trimmedData))
colnames(trimmedData) <- gsub("fBodyGyro", "Body.Gyroscope.Frequency.Domain", colnames(trimmedData))
colnames(trimmedData) <- gsub("fBodyBodyAcc", "Body.Body.Accelerometer.Frequency.Domain", colnames(trimmedData))
colnames(trimmedData) <- gsub("fBodyBodyGyro", "Body.Body.Gyroscope.Frequency.Domain", colnames(trimmedData))
colnames(trimmedData) <- gsub("Jerk", ".Jerk", colnames(trimmedData))
colnames(trimmedData) <- gsub("Mag", ".Magnitude", colnames(trimmedData))
colnames(trimmedData) <- gsub("meanFreq", "Mean.Frequency", colnames(trimmedData))
colnames(trimmedData) <- gsub("mean", "Mean", colnames(trimmedData))
colnames(trimmedData) <- gsub("std", "Std.Dev", colnames(trimmedData))
colnames(trimmedData) <- gsub("[[:punct:]]+", ".", colnames(trimmedData))
colnames(trimmedData) <- gsub("\\.$", "", colnames(trimmedData))


# 5. Average each Activity for each participant ordered alphabetically
meanTrimmedData <- trimmedData %>% arrange( Subject, Activity) %>%
     group_by(Subject, Activity) %>% 
     summarise(across(.cols = !matches("Activity"), .fns = mean, 
                      .groups = "keep"))

# Write out the resulting tidydata to a new file
# Data is stored as a space separated text file. To read back in, 
# use  data <- read.table(file = "TidyDataSet.txt", header = TRUE, quote = "")
write.table(meanTrimmedData, file = "TidyDataSet.txt", quote = FALSE)
