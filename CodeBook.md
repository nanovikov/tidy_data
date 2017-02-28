### Experiment description

Experiments carried on 30 volunteers (19-48 year old) used the accelerometer and gyroscope of a smartphone (Samsung Galaxy S II) attached at the waist to track 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz during six different activities (walking, wakling upstairs, walking downstairs, sitting, standing, laying).

70% of the volunteers was selected for generating the training data and 30% the test data. 

### Variable Desciptions

* id : subject identifier
* type : type of dataset used, either 'train' or 'test' for training and testing
* activity : activity performed by subject 
  * walking
  * wakling upstairs (denoted as 'upstairs')
  * walking downstairs (denoted as 'downstairs)
  * sitting
  * standing
  * laying

The other variables are as described in the features_info.txt in the 
'UCI HAR Dataset' directory. For names of variables in 'tidy_data.csv', 
all features were convreted to lower case and special character like '(', ')'
'-', ',' were removed. In addition, the beginning 't' was also removed.

For example 'tBodyAcc-mean()-X' was converted to 'bodyaccmeanx'



