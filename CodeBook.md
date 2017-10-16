## Description

This document contains a code-book that describes the variables, the data, and any transformations or work that you performed to clean up the data.

### Source Data

A full description of the data used in this project can be found at [The UCI Machine Learning Repository](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).

The source data for this project can be found [here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip).

### Data Set Information

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

### Attribute Information

For each record in the dataset it is provided:

* Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
* Triaxial Angular velocity from the gyroscope.
* A 561-feature vector with time and frequency domain variables.
* Its activity label.
* An identifier of the subject who carried out the experiment.

The dataset includes the following files:

* 'README.txt'
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

#### Notes: 
- Features are normalized and bounded within [-1,1].
- Each feature vector is a row on the text file.

## Code Description

### Section 1. Merge the training and the test sets to create one data set.

We first read the subject, activity, and measurements as follows:
```r
# Reading test data
data1 = read.table(".\\UCI HAR Dataset\\test\\X_test.txt")
data2 = read.table(".\\UCI HAR Dataset\\test\\y_test.txt")
data3 = read.table(".\\UCI HAR Dataset\\test\\subject_test.txt")

# Reading training data
data4 = read.table(".\\UCI HAR Dataset\\train\\X_train.txt")
data5 = read.table(".\\UCI HAR Dataset\\train\\y_train.txt")
data6 = read.table(".\\UCI HAR Dataset\\train\\subject_train.txt")

# Reading activity labels and features
activity_labels<-read.table(".\\UCI HAR Dataset\\activity_labels.txt")
features<-read.table(".\\UCI HAR Dataset\\features.txt")
```

We then change the column names for feature data-frame using the features in "features.txt" file. We also changed the column names of activities and subjects accordingly.

```r
# Changing Column Names
names(data1)<-features[,2]
names(data2)<-"Activity"
names(data3)<-"Subject"
names(data4)<-features[,2]
names(data5)<-"Activity"
names(data6)<-"Subject"
```


### Section 2. Extract only the measurements on the mean and standard deviation for each measurement.
merged_data contains the merged measurements of only mean and std.


```r
# Finding the Index of Mean and std Columns
mean_indices<-grep("mean\\(\\)",features[,2])
std_indices <-grep("std\\(\\)", features[,2])
indices<-union(mean_indices,std_indices)

# Tasks 1 and 2: Merging Data, Extrcating only Mean() and Std() Columns
data1_c<-cbind(data3,data2,data1[,indices])
data4_c<-cbind(data6,data5,data4[,indices])
merged_data<-rbind(data1_c,data4_c)
```




### Section 3. Use descriptive activity names to name the activities in the data set

We replaced the activity code on second column of merged_data with their respective activity description obtained from activity_label vector. 

```r
merged_data[,2]<-activity_labels$V2[merged_data[,2]]
```

### Section 4. Appropriately label the data set with descriptive activity names.

The column names were initially borrowed from the file "features.txt". We next editted the column names by replacing prefixes "t" and "f" with suffix "Time" and "FFT", respectively, using lapply.   
```r
t_indices<-grep("^t",names(merged_data))
f_indices<-grep("^f",names(merged_data))
names(merged_data)[t_indices]<-lapply(names(merged_data)[t_indices],paste,"-Time",sep="")
names(merged_data)[f_indices]<-lapply(names(merged_data)[f_indices],paste,"-FFT",sep="")
names(merged_data)<-sub("^t|^f","",names(merged_data))
```

We also replaced all dashes "-" with dots ".". Finally, we removed all paranthesis from column names, using gsub function.  

```r
names(merged_data)<-gsub("-",".",names(merged_data))
names(merged_data)<-gsub("\\(|\\)","",names(merged_data))
```

### Section 5. Create a second, independent tidy data set with the average of each variable for each activity and each subject.

```r
tidy_data<-merged_data %>% 
  group_by(.dots=c("Subject","Activity")) %>% 
  summarise_all(funs(mean)) %>%
  as.data.frame()
```
