#Merge training data and test to merge data set
 
train = read.table("UCI HAR Dataset/train/subject_train.txt", col.names=c("subject_id"))  
train$ID <- as.numeric(rownames(subject_train))  
X_train = read.table("UCI HAR Dataset/train/X_train.txt")  
X_train$ID <- as.numeric(rownames(X_train)) 
y_train = read.table("UCI HAR Dataset/train/y_train.txt", col.names=c("activity_id"))  # max = 6 
y_train = merge(y_train, activity_labels) 
y_train$ID <- as.numeric(rownames(y_train))
 
#Merge train and y_train

train <- merge(subject_train, y_train, all=TRUE) 
train <- merge(train, X_train, all=TRUE)
 
test = read.table("UCI HAR Dataset/test/subject_test.txt", col.names=c("subject_id")) 
test$ID <- as.numeric(rownames(subject_test))

X_test = read.table("UCI HAR Dataset/test/X_test.txt") 
X_test$ID <- as.numeric(rownames(X_test)) 
y_test = read.table("UCI HAR Dataset/test/y_test.txt", col.names=c("activity_id"))  # max = 6 
y_test = merge(y_test, activity_labels) 
y_test$ID <- as.numeric(rownames(y_test))
 
test <- merge(subject_test, y_test, all=TRUE)   
test <- merge(test, X_test, all=TRUE)  
data1 <- rbind(train, test) 

 
#Extract only measurement of mean and SD

features = read.table("UCI HAR Dataset/features.txt", col.names=c("feature_id", "feature_label"),)  #561   
selected_features <- features[grepl("mean\\(\\)", features$feature_label) | grepl("std\\(\\)", features$feature_label), ] 
data2 <- data1[, c(c(1, 2, 3), selected_features$feature_id + 3) ] 

activity_labels = read.table("UCI HAR Dataset/activity_labels.txt", col.names=c("activity_id", "activity_label"),) 
data3 = merge(data2, activity_labels) 
 
#label data set

selected_features$feature_label = gsub("\\(\\)", "", selected_features$feature_label) 
selected_features$feature_label = gsub("-", ".", selected_features$feature_label) 
for (i in 1:length(selected_features$feature_label)) { 
	colnames(data3)[i + 3] <- selected_features$feature_label[i] 
} 
data4 = data3 
 
#Create cleansed data set

drops <- c("ID","activity_label") 
data5 <- data4[,!(names(data4) %in% drops)] 
aggdata <-aggregate(data5, by=list(subject = data5$subject_id, activity = data5$activity_id), FUN=mean, na.rm=TRUE) 
drops <- c("subject","activity") 
aggdata <- aggdata[,!(names(aggdata) %in% drops)] 
aggdata = merge(aggdata, activity_labels) 
write.csv(file="submit_data.csv", x=aggdata) 
