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

#Frequency for weekdays
weekday_freq = count(df_train, vars="weekday")
df_train$weekdayfreq = weekday_freq[match(df_train$weekday, weekday_freq$weekday),2]

#CTR for weekdays
weekday_click_freq = count(df_train, c("weekday", "click"))
weekday_click_freq = weekday_click_freq[(weekday_click_freq$click=="1"),]
weekday_click_freq$ctr = 100 * weekday_click_freq$freq/weekday_freq[match(weekday_click_freq$weekday, weekday_freq$weekday),2]
df_train$weekdayctr = weekday_click_freq[match(df_train$weekday, weekday_click_freq$weekday),4]

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

