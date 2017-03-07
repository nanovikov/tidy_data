## CODE BOOK

### STUDY DESIGN

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

### RAW DATA SUMMARY

For each record in the dataset it is provided: 
* Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration. 
* Triaxial Angular velocity from the gyroscope. 
* A 561-feature vector with time and frequency domain variables. 
* Its activity label. 
* An identifier of the subject who carried out the experiment.

The raw data files include:
* 'features_info.txt': Shows information about the variables used on the feature vector.
* 'features.txt': List of all features.
* 'activity_labels.txt': Links the class labels with their activity name.
* 'train/X_train.txt': Training set.
* 'train/y_train.txt': Training labels.
* 'test/X_test.txt': Test set.
* 'test/y_test.txt': Test labels. 
The following files are available for the train and test data. Their descriptions are equivalent. 
* 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
* 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 
* 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 
* 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 

### CONVERSION OF RAW DATA TO TIDY DATA 

1. Data were downloaded at `https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip`
2. Feature names were extracted from the 'features.txt' file.

    ```features <- read.table("UCI HAR Dataset/features.txt", 
    header = F, col.names = c("number", "name"), stringsAsFactors = F)```

3. Feature names were rendered unique using the `make.unique` function. For example, when the same feature occured the names were given subscripts: 

Original name | New name
--------------|---------
fBodyGyro-bandsEnergy()-1,8|fBodyGyro-bandsEnergy()-1,8.1
fBodyGyro-bandsEnergy()-1,8|fBodyGyro-bandsEnergy()-1,8.2

```
  # make the feature names unique 
  features$name <- make.unique(features$name, sep = ".")
  
```

4. The modified feature names were then simplified by converting  `(`, `)`, `.`, `,`, `-` to  `_` and making the text lowercase:

Original name | New name
--------------|---------
tBodyAcc-mean()-X|tbodyacc_mean_x
angle(tBodyGyroJerkMean,gravityMean)|angle_tbodygyrojerkmean_gravitymean
fBodyGyro-bandsEnergy()-25,48|fbodygyro_bandsenergy_25_48

```
  # clean up the feature names
  features$name <- gsub("\\()", "", features$name)
  features$name <- gsub("\\-", "_", features$name)
  features$name <- gsub("\\.", "_", features$name)
  features$name <- gsub("\\,", "_", features$name)
  features$name <- gsub("\\(", "_", features$name)
  features$name <- gsub("\\)", "", features$name)
  features$name <- tolower(features$name)
```

4. A function `make_table` was written to generate a data table for the "training" and "test" datasets. The functions takes the following arguments: 
  * id_file : A file where each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30, and it is either 'train/subject_train.txt' or 'test/subject_test.txt'. 
  * label_file : A file containing training or test labels of the activities that the subject was doing. The values of the rows are WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, or LAYING.  The file is either 'train/y_train.txt' or 'test/y_test.txt'
  * feature_file : Dataset of 561-variables describes in the 'features.txt' file. The file is either 'train/X_train.txt' or 'test/X_test.txt'

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

5. The `make_table` function is applied to the testing and training data files to create two separate data tables that are then merged together and saved in the 'tidy_data.txt' file.

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


6. The data was subset for variables containing 'mean' or 'std' in their title. The resulting data was saved in the file "tidy_data.txt".

  #select only variables with 'mean' or 'std' in the title using 'idx'
  subset_data <- select(full_data, id, activity, contains("mean"), contains("std"))

  # save the data
  write.table(subset_data, "tidy_data.txt", row.names = F)

7. From the data set in step 6, create a second, independent tidy data set with the average of each variable for each activity and each subject.

  # extract average for each measured variable grouped by subject and activity
  averages <- group_by(full_data, id, activity) %>%
          summarize_each(funs(mean))

  # save the data
  write.table(averages, "tidy_summaries.txt", row.names = F)


### TIDY DATA

The 'tidy_data.txt' file is a data table consisting of 10299 rows and 88 columns that represent variables with 'mean' or 'std' in the titles. The column variables include the following: 
  * id : subject identifier
  * activity : activity performed by subject 
    * walking
    * wakling upstairs (denoted as 'upstairs')
    * walking downstairs (denoted as 'downstairs)
    * sitting
    * standing
    * laying
  * variables in columns 3 through 88 are either mean (mean) or standard deviation (std) values for the following variables (which were previously normalized and bounded within [-1,1]), where 'XYZ' denotes a separate variable for 'X', 'Y', and 'Z':
    * tbodyacc_XYZ
    * tgravityacc_XYZ
    * tbodyaccjerk_XYZ
    * tbodygyro_XYZ
    * tbodygyrojerk_XYZ
    * tbodyaccmag
    * tgravityaccmag
    * tbodyaccjerkmag
    * tbodygyromag
    * tbodygyrojerkmag
    * fbodyacc_XYZ
    * fbodyaccjerk_XYZ
    * fbodygyro_XYZ
    * fbodyaccmag
    * fbodyaccjerkmag
    * fbodygyromag
    * fbodygyrojerkmag
  * Or they are the following variables: 
    * gravitymean
    * tbodyaccmean
    * tbodyaccjerkmean
    * tbodygyromean
    * tbodygyrojerkmean

### CITATION

Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. A Public Domain Dataset for Human Activity Recognition Using Smartphones. 21th European Symposium on Artificial Neural Networks, Computational Intelligence and Machine Learning, ESANN 2013. Bruges, Belgium 24-26 April 2013.
