# Tidy Data Assignment
# =====================
# This script cleans the wearable computing data from here: 
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# 
# The output data table contains observations about 30 people (19-48 year old) 
# in the following columns:
# 1. 'id' identifies the subject performing the activity  
# 2. 'type' identifies the train and test sets
# 3. 'activity' identifies the activity (walking, walking upstairs, walking
#     downstairs, sitting, standing, laying)
# 4. the rest of the columns correspond to mean and standard deviation measurements
#    described in the CodeBook.md


# load required libraries
library(dplyr)

# load the features data set
features <- read.table("UCI HAR Dataset/features.txt", header = F)

# clean up the columns
features <- select(features, names = V2)

# clean up the feature names
features$names <- gsub("\\(", "", features$names)
features$names <- gsub("\\)", "", features$names)
features$names <- gsub("\\-", "", features$names)
features$names <- gsub("\\,", "", features$names)
features$names <- sub("^t", "", features$names)
features$names <- tolower(features$names)

# create an index vector 'idx' that identifies features with either
# 'mean' or 'std' in the name
idx <- grepl("mean|std", features$names)

# 'make_table' is a function that generates a tidy table using inputs: 
# 'id_file' : path to file with subject id's
# 'label_file' : path to file with activity labels
# 'feature_file' : path to feature vector file

make_table <- function(id_file, label_file, feature_file, idx = idx) {
        # load id file and annotate
        id <- read.table(id_file, header = F)
        names(id) <- c("id")
        # load labels file and annotate
        label <- read.table(label_file, header = F)
        names(label) <- c("activity")
        # load feature vector file and annotate
        feature_vector <- read.table(feature_file, header = F)
        names(feature_vector) <- features$names
        feature_vector_subset <- feature_vector[, idx]
        # combine data frames
        full_data <- cbind(id, label, feature_vector_subset)
        # select subset with mean and standard deviation information
        full_data$activity <- factor(full_data$activity, labels = c("walking",
                                                                    "upstairs", 
                                                                    "downstairs",
                                                                    "sitting", 
                                                                    "standing", 
                                                                    "laying"))
        full_data
}

# generate the training data table
train_data <- make_table("UCI HAR Dataset/train/subject_train.txt", 
                         "UCI HAR Dataset/train/y_train.txt", 
                         "UCI HAR Dataset/train/X_train.txt")
train_data$type <- "train"
train_data <- select(train_data, id, type, 2:563)

# generate the test data table
test_data <- make_table("UCI HAR Dataset/test/subject_test.txt", 
                        "UCI HAR Dataset/test/y_test.txt", 
                        "UCI HAR Dataset/test/X_test.txt")
test_data$type <- "test"
test_data <- select(test_data, id, type, 2:563)

# combine the training and test data sets
full_data <- rbind(train_data, test_data)

# save the data
write.csv(full_data, "tidy_data.csv")

# extract average for each measured variable grouped by subject and activity
averages <- group_by(full_data, id, activity) %>%
        select(-type) %>%
        summarize_each(funs(mean))

write.csv(averages, "tidy_summaries.csv")