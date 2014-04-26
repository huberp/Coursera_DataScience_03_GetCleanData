Coursera_DataScience_03_GetCleanData
====================================

This repository contains the code for the programming assignment of the course
"Getting and Cleaning Data" of the Data Science Specialisation track

From the instructions
=====================
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following. 

* Merges the training and the test sets to create one data set.
* Extracts only the measurements on the mean and standard deviation for each measurement. 
* Uses descriptive activity names to name the activities in the data set
* Appropriately labels the data set with descriptive activity names. 
* Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

#Install
* Please clone this repository to a directory <dir>
* Please download the data set, find url above, and unpack it in <dir>
* now you should have a file called "run_analysis.R" and a directory called "UCI HAR Dataset" in the same directory <dir>
* please set your working directory to <dir> use setwd(<fullpathto<dir>)
* if you now type "dir()" into the R console prompt you should see at least
	- [1] "run_analysis.R"                                                                           
	- [2] "UCI HAR Dataset"                                                                          

We will call "UCI HAR Dataset" our <basedir>
    
#Use

Please source in the file `run_analysis.R`. It will automatically run the code.
It will produce two files

* [1] "<basedir>/resultA.txt": File that contains the merged dataset                                                                              
* [2] "<basedir>/resultB.txt": File that contains the "data set with the average of each variable for each activity and each subject" 

#Transformations
## 1st file
For the first task, "the merged" dataset with only "std or mean" columns and "descriptive" activites we go in function "main"

Result will be file "resultA.txt"

### only "std or mean" 
1. Load the file "features.txt" which contains all possible feature, see function "loadFeaturesFile()"
2. Build a col-class vector, see function "findColClassVector", i.e. a vector which contains: 
    * "NULL" for all features that are not selected to be "std" or "mean"
	* "numeric" otherwise 
3. The coll class-vector has been named with the feature names

### add subjects and activities
with the found "col-classes and names" vector we load data for <dataset> in {"train", "test"}, see function "loadJoinedDataSet"

* the file `<basedir>/<dataset>/X_<dataset>.txt` - appyling the col classes on read.table, we end up with only the necessary columns being loaded, leaving everything else away from the begining
* the file `<basedir>/<dataset>/y_<dataset>.txt` - add it as factor column, using `<basedir>/activities.txt` to create the factor-labels; column name "_activities_"
* the file `<basedir>/<dataset>/subject_<dataset>.txt` - add it as column; column name "_subject_"

### merge
finally we join both datasets to just one with columns: `subject|activities|all std/mean columns from X_<dataset>.txt`

## 2nd file
For the second task, i.e. doing the data.frame equivalent of SQL "Select avg(*) group by subject and activities" we use the output of the first file and just go:

DF2<-ddply(r,.(subject, activities), numcolwise(mean))   

Result will be "resultB.txt"