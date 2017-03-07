# Tidy Data Assignment
# =====================
# This script converts the raw data from the UCI HAR dataset into tidy data 
# according to the steps outlined in the accompanying CodeBook.md file

# load required libraries
library(dplyr)

# load the features data set
features <- read.table("UCI HAR Dataset/features.txt", header = F, col.names = c("number", "name"), stringsAsFactors = F)

# make the feature names unique
features$name <- make.unique(features$name, sep = ".")

# clean up the feature names
features$name <- gsub("\\()", "", features$name)
features$name <- gsub("\\-", "_", features$name)
features$name <- gsub("\\.", "_", features$name)
features$name <- gsub("\\,", "_", features$name)
features$name <- gsub("\\(", "_", features$name)
features$name <- gsub("\\)", "", features$name)
features$name <- tolower(features$name)

# create an index vector 'idx' that identifies features with either
# 'mean' or 'std' in the feature name
idx <- grepl("mean|std", features$name)

# 'make_table' is a function that generates a data table using the following inputs -
# 'id_file' : path to file with subject ids
# 'label_file' : path to file with activity labels
# 'feature_file' : path to feature vector file

make_table <- function(id_file, label_file, feature_file) {
        # load id file and annotate
        id <- read.table(id_file, header = F)
        names(id) <- c("id")
        # load labels file and annotate
        label <- read.table(label_file, header = F)
        names(label) <- c("activity")
        # load feature vector file and annotate
        feature_vector <- read.table(feature_file, header = F)
        names(feature_vector) <- features$name
        # combine data frames
        full_data <- cbind(id, label, feature_vector)
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

# generate the test data table
test_data <- make_table("UCI HAR Dataset/test/subject_test.txt", 
                        "UCI HAR Dataset/test/y_test.txt", 
                        "UCI HAR Dataset/test/X_test.txt")

# combine the training and test data sets
full_data <- rbind(train_data, test_data)

# select only variables with 'mean' or 'std' in the title using 'idx'
subset_data <- select(full_data, id, activity, contains("mean"), contains("std"))
  
# save the data
write.table(subset_data, "tidy_data.txt", row.names = F)

# extract average for each measured variable grouped by subject and activity
averages <- group_by(subset_data, id, activity) %>%
        summarize_each(funs(mean))

# save the data
write.table(averages, "tidy_summaries.txt", row.names = F)
