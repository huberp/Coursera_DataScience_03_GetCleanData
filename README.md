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
* please set your working directory to <dir> use setwd(<full_path_to<dir>)
* if you now type "dir()" into the R console prompt you should see at least
** [1] "run_analysis.R"                                                                           
** [2] "UCI HAR Dataset"                                                                          

We will call "UCI HAR Dataset" our &lt;basedir&gt;
    
#Use

Please source in the file. It will automatically run the code.
It will produce two files
* [1] "resultA.txt": File that contains the merged dataset                                                                              
* [2] "resultB.txt": File that contains the "data set with the average of each variable for each activity and each subject" 

#Transformations
## 1st file
For the first task, "the merged" dataset with only "std or mean" columns and "descriptive" activites we go in function "main"
Result will be file "resultA.txt"
* Load the file "features.txt" which contains all possible feature (function "loadFeaturesFile()")
* Build a named col-class vector (function "findColClassVector"), i.e. a vector which contains 
** "NULL" for all features that are not selected to be "std" or "mean"
** "numeric" otherwise 
* The coll class-vector has been named with the feature names
* with the found col-classes and names we load data for &lt;dataset&gt; in {"train", "test"} (function "loadJoinedDataSet")
** the file &lt;basedir&gt;/&lt;dataset&gt;/X_&lt;dataset&gt;.txt (appyling the col classes on read.table, we end up with only the necessary columns be loaded)
** the file &lt;basedir&gt;/&lt;dataset&gt;/y_&lt;dataset&gt;.txt and add is as factor column using &lt;basedir&gt;/activities.txt to create the factor; column name "activities"
** the file &lt;basedir&gt;/&lt;dataset&gt;/subject_&lt;dataset&gt;.txt and add it as column; column name "subject"
* finally we join both datasets to just one with columns: subject|activities|<all std/mean columns from X_&lt;dataset&gt;.txt

## 2nd file
For the second task, i.e. doing the data.frame equivalent of SQL "Select avg(*) group by subject and activities" we use the output of the first line and just go:
DF2<-ddply(r,.(subject, activities), numcolwise(mean))   
Result will be "resultB.txt"