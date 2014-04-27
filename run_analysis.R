# TODO: Add comment
# 
# Author: huberp
###############################################################################

#oldwd <- getwd()
#setwd("./03_GetCleanData/PA/")

library(plyr)

###################################################
# Constant values
###################################################

const <- list(
		"directory"			=		"UCI HAR Dataset", 
		"featureFile"		=		"features.txt",
		"activityFile"		=		"activity_labels.txt",
		"regexp.mean"		=		"\\-mean\\(\\).{,2}$",  #matches e.g. "[...]-mean()" or "[...]-mean()-X"
		"regexp.std"		=		"\\-std\\(\\).{,2}$",   #same as above for std()
		"dirs"				=		c("test","train"),		#from the 'dirs' and the 'frmt.xyz' vars I can build names
		"frmt.measureFile"	= 		"%s/%s/X_%s.txt",		#<basedir>/<dir>/X_<dir>.txt
		"frmt.outcomeFile"	= 		"%s/%s/y_%s.txt",
		"frmt.subjectFile"	=		"%s/%s/subject_%s.txt",
		"result.file.A"		=		"resultA.txt",
		"result.file.B"		=		"resultB.txt"
);

###################################################
# MAIN Function
###################################################

main<-function() {
	features <- loadFeaturesFile()
	print(dim(features))
	colClassSelector <- findColClassVector(features, c(const$regexp.mean, const$regexp.std))
	res <- data.frame()
	for(aDir in const$dirs) {
		singleDataset <- loadJoinedDataSet(dir=aDir, colClassSelector=colClassSelector)
		res<-rbind(res, singleDataset);
	}
	return(res)  
}


###################################################
## load a joined data set
## Files X_<dir>, y_<dir> and subject_<dir> are joined
## The y_<dir> file contains numbers that are matched with
## the activity_labels.txt in order to find a textual representation
loadJoinedDataSet <- function(baseDir=const$directory, dir="", colClassSelector=c()) {
	#precondition check
	assert$notEmpty(assert$notNull(baseDir))
	assert$notEmpty(assert$notNull(dir))
	assert$notNull(colClassSelector)
	
	fileNameX <- sprintf(const$frmt.measureFile,baseDir,dir,dir)
	fileNameY <- sprintf(const$frmt.outcomeFile,baseDir,dir,dir)
	fileNameS <- sprintf(const$frmt.subjectFile,baseDir,dir,dir)
	
	#set check.names = FALSE - otherwise character "()-" will be replaced by "..." 
	#and we get 'tBodyAcc-mean...X' instead of 'tBodyAcc-mean()-X'
	selectedFeatures <- read.table(fileNameX,header=FALSE, col.names=names(colClassSelector), colClasses=colClassSelector, check.names=FALSE) 
	#
	outcomes 		 <- read.table(fileNameY,header=FALSE, colClasses=c("integer"))
	subjects		 <- read.table(fileNameS,header=FALSE, colClasses=c("integer"))
	activities		 <- loadActivityFile(baseDir)
	#
	#translate numeric/integer to textual activities, outcomes[[1]] is the indexes used with FUN `[`
	#textualOutcomes <- sapply(X=outcomes$V1, FUN=function(x) {activities$V2[x]})
	#
	#now transform it as a "factor" type vector
	outcomeFactor <-factor(x=outcomes$V1, labels=activities$V2)
	##
	selectedFeatures <- cbind(outcomeFactor, selectedFeatures)
	names(selectedFeatures)[1]<-"activities"
	##
	selectedFeatures <- cbind(subjects, selectedFeatures)
	names(selectedFeatures)[1]<-"subject"
	
	return(selectedFeatures)
}


###################################################
## find all features that match any of the features
## due to unspecific nature of instructions I decided
## to define two regexps, one will match the "means"
## and one will match the "stds"
##
findFeatureColums <- function(allFeatures, selectorRegexp=".*") {
	#precondition check
	assert$notNull(allFeatures)
	# now I "Extracts only the measurements on the mean and standard deviation for each measurement." 
	logicalSelector <- regexec(selectorRegexp, allFeatures[,2])>=0;
	# I build a vector with index values for selected std and mean columns...
	selectedFeatures <- allFeatures[logicalSelector , 1]
	# ...and I give name to each index entry in the vector
	names(selectedFeatures) <- allFeatures[logicalSelector, 2]
	return(selectedFeatures)
}

################################################################
## builds a colClass-Vector where only the selected columns
## are not null, names are set as names()...
findColClassVector <- function(allFeatures, selectorRegexp=c(".*")) {
	#precondition check
	assert$notNull(allFeatures)
	#build a combined logical selector from "std" and "mean" features 
	combinedSelector <- rep(FALSE, length.out=length(allFeatures[[1]]));
	for(aRegExp in selectorRegexp) { 
		logicalSelector <- regexec(aRegExp, allFeatures[,2])>=0;
		#print(paste(length(logicalSelector), length(combinedSelector)))
		combinedSelector = combinedSelector | logicalSelector;
	}
	colClassVector <- rep(c("numeric"), length.out=length(combinedSelector))
	colClassVector[!combinedSelector]<-"NULL"
	names(colClassVector)<-allFeatures[,2]

	return(colClassVector)
}

###################################################
## I read in the feature.txt file here
loadFeaturesFile <- function(baseDir=const$directory) {
	#precondition check
	assert$notEmpty(assert$notNull(baseDir))
	#load file
	allFeatures <- read.table(paste0(baseDir,"/",const$featureFile) ,header=FALSE, sep=" ", colClasses=c("numeric","character"))
	return(allFeatures)
}

###################################################
## I read the activity labels file
loadActivityFile <- function(baseDir=const$directory) {
	#precondition check
	assert$notEmpty(assert$notNull(baseDir))
	#load file
	allActivity <- read.table(paste0(baseDir,"/",const$activityFile) ,header=FALSE, sep=" ", colClasses=c("numeric","character"))
	return(allActivity)
}

###################################################
# Utility Functions
###################################################
assert <- list(
	"notNull" = function(x,...)  { 
		if(is.null(x)) { 
			stop(paste("Assert not null failed",...)) 
		}
		return(x)
	},	
	"notEmpty" = function(x,...)	{ 
		assert$notNull(x,...); 
		if(0==nchar(x)) { 
			stop(paste("Assert not empty failed",...)) 
		}
		return(x)
	}
);

##
DF1<-main()
write.table(DF1, const$result.file.A)
##
#g<-ddply(r,.(subject, activities),summarize,mean=mean(`tBodyAcc-mean()-X`))
#http://stackoverflow.com/questions/10787640/ddply-summarize-for-repeating-same-statistical-function-across-large-number-of
DF2<-ddply(DF1,.(subject, activities), numcolwise(mean))
write.table(DF2, const$result.file.B)

##
#read back in bith files - use this to check in my posted assignemnt files, too
#NOTE: we have to use check.names=FALSE because 'tBodyAcc-mean()-X' is not a valid R variable name. 
#If we load without check.names=FALSE the name will be replaced to be 'tBodyAcc-mean...X' instead
A<-read.table(const$result.file.A, header=TRUE,check.names = FALSE)
B<-read.table(const$result.file.B, header=TRUE,check.names = FALSE)