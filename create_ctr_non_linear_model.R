library(stringr)
library(caret)
library(car)
library(plyr) #for count()
library(xgboost)

setwd("D:/SSE/Web_Economics/Coursework")

#Read csv files
df_train = read.csv("Dataset/train.csv", colClasses=c(rep('factor', 15), 'numeric', 'numeric', 'factor', 'factor', 'numeric', 'factor', 'numeric', 'numeric', rep('factor', 3)))
df_validate = read.csv("Dataset/validation.csv", colClasses=c(rep('factor', 15), 'numeric', 'numeric', 'factor', 'factor', 'numeric', 'factor', 'numeric', 'numeric', rep('factor', 3)))

#remove logs with bidprice lower or equal to payprice
df_train = filter(df_train, bidprice>payprice)
df_validate = filter(df_validate, bidprice>payprice)

#extract 'click' values as labels from train and validate
labels_train = df_train['click']
labels_validate = df_validate['click']

#remove unused columns
df_train = subset(df_train, select=-c(bidid, logtype, userid, IP, domain, url, urlid, slotid, creative, bidprice, payprice, usertag))
df_validate = subset(df_validate, select=-c(bidid, logtype, userid, IP, domain, url, urlid, slotid, creative, bidprice, payprice, usertag))

#Group levels of slotvisibility: 0->FirstView, 1->SecondView, 2->ThirdView
levels(df_train$slotvisibility) = c("FirstView", "SecondView", "ThirdView", "Na", "FifthView", "FirstView", "FourthView", "Na", "OtherView", "SecondView", "ThirdView")
levels(df_validate$slotvisibility) = c("FirstView", "SecondView", "ThirdView", "Na", "FifthView", "FirstView", "FourthView", "Na", "OtherView", "SecondView", "ThirdView")


CreateNumericParametersFromFactor <- function(df_train, parameter_name) {
  #Frequency
  freq = count(df_train, vars=parameter_name)
  freq_name = paste (parameter_name, "freq", sep = "") 
  df_train[freq_name] = freq[match(df_train[[parameter_name]], freq[[parameter_name]]),2]
  
  #CTR
  click_freq = count(df_train, c(parameter_name, "click"))
  click_freq = click_freq[(click_freq$click=="1"),]
  click_freq$ctr = 100 * click_freq$freq/freq[match(click_freq[[parameter_name]], freq[[parameter_name]]),2]
  ctr_name = paste (parameter_name, "ctr", sep = "")
  df_train[ctr_name] = click_freq[match(df_train[[parameter_name]], click_freq[[parameter_name]]),4]
  
  return(df_train)
}

#Parameters for weekdays
df_train = CreateNumericParametersFromFactor(df_train, "weekday")

#WriteSolutionCsv(labels_train, df_train)

WriteSolutionCsv <- function(labels_train) {
  
  df_test = read.csv("Dataset/test.csv", colClasses=c(rep('factor', 18), rep('factor', 4)))
  levels(df_test$slotvisibility) = c("FirstView", "SecondView", "ThirdView", "Na", "FifthView", "FirstView", "FourthView", "Na", "OtherView", "SecondView", "ThirdView")
  
  limit_budget = 25000
  base_bid = 25
  average_ctr_train = sum(with(labels_train, click==1))/nrow(labels_train)
  bidprice = base_bid/average_ctr_train * test_predict
  df_submission = data_frame(df_test$bidid, bidprice)
  colnames(df_submission) <- c("bidid","bidprice")
  write.csv(df_submission, file = "Submission.csv", row.names = FALSE, quote=FALSE)
}

