library(plyr); library(dplyr)

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


# Changing Column Names
names(data1)<-features[,2]
names(data2)<-"Activity"
names(data3)<-"Subject"
names(data4)<-features[,2]
names(data5)<-"Activity"
names(data6)<-"Subject"


# Finding the Index of Mean and std Columns
mean_indices<-grep("mean\\(\\)",features[,2])
std_indices <-grep("std\\(\\)", features[,2])
indices<-union(mean_indices,std_indices)


# Tasks 1 and 2: Merging Data, Extrcating only Mean() and Std() Columns
data1_c<-cbind(data3,data2,data1[,indices])
data4_c<-cbind(data6,data5,data4[,indices])
merged_data<-rbind(data1_c,data4_c)

# Erasing unnessary variables from memory
rm("data1","data2","data3","data4","data5","data6","data1_c","data4_c")

# Task 3. Use descriptive activity names to name the activities in the data set  
merged_data[,2]<-activity_labels$V2[merged_data[,2]]

# Task 4. Appropriately labels the data set with descriptive variable names
t_indices<-grep("^t",names(merged_data))
f_indices<-grep("^f",names(merged_data))

names(merged_data)[t_indices]<-lapply(names(merged_data)[t_indices],paste,"-Time",sep="")
names(merged_data)[f_indices]<-lapply(names(merged_data)[f_indices],paste,"-FFT",sep="")
names(merged_data)<-sub("^t|^f","",names(merged_data))
names(merged_data)<-gsub("-",".",names(merged_data))
names(merged_data)<-gsub("\\(|\\)","",names(merged_data))


# Task 5. From the data set in step 4, creates a second, 
# independent tidy data set with the average of each variable 
# for each activity and each subject.

tidy_data<-merged_data %>% 
  group_by(.dots=c("Subject","Activity")) %>% 
  summarise_all(funs(mean)) %>%
  as.data.frame()

write.table(tidy_data, ".\\tidy_data.txt", sep="\t")
