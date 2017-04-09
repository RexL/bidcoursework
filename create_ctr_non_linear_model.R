library(stringr)
library(caret)
library(car)
library(plyr) #for count()
library(xgboost)


CreateNumericParametersFromFactor <- function(df_train, m_train, parameter_name) {
  #Frequency
  freq = count(df_train, vars=parameter_name)
  freq_name = paste (parameter_name, "freq", sep = "") 
  m_train = cbind(m_train, freq[match(df_train[[parameter_name]], freq[[parameter_name]]),2])
  colnames(m_train)[NCOL(m_train)] = freq_name
  
  #CTR
  click_freq = count(df_train, c(parameter_name, "click"))
  click_freq = click_freq[(click_freq$click=="1"),]
  click_freq$ctr = 100 * click_freq$freq/freq[match(click_freq[[parameter_name]], freq[[parameter_name]]),2]
  ctr_name = paste (parameter_name, "ctr", sep = "")
  m_train = cbind(m_train, click_freq[match(df_train[[parameter_name]], click_freq[[parameter_name]]),4])
  colnames(m_train)[NCOL(m_train)] = ctr_name
  
  return(m_train)
}

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

setwd("D:/SSE/Web_Economics/Coursework")

#Read csv files
df_train = read.csv("Dataset/train.csv", colClasses=c(rep('factor', 15), 'numeric', 'numeric', 'factor', 'factor', 'numeric', 'factor', 'numeric', 'numeric', rep('factor', 3)))
df_validate = read.csv("Dataset/validation.csv", colClasses=c(rep('factor', 15), 'numeric', 'numeric', 'factor', 'factor', 'numeric', 'factor', 'numeric', 'numeric', rep('factor', 3)))

#remove logs with bidprice lower or equal to payprice
df_train = filter(df_train, bidprice>payprice)
df_validate = filter(df_validate, bidprice>payprice)

#Group levels of slotvisibility: 0->FirstView, 1->SecondView, 2->ThirdView
levels(df_train$slotvisibility) = c("FirstView", "SecondView", "ThirdView", "Na", "FifthView", "FirstView", "FourthView", "Na", "OtherView", "SecondView", "ThirdView")
levels(df_validate$slotvisibility) = c("FirstView", "SecondView", "ThirdView", "Na", "FifthView", "FirstView", "FourthView", "Na", "OtherView", "SecondView", "ThirdView")

m_train = as.matrix(subset(df_train, select=c(slotwidth, slotheight, slotprice)))

#Transform categoric parameters to numeric
m_train = CreateNumericParametersFromFactor(df_train, m_train, "weekday")
m_train = CreateNumericParametersFromFactor(df_train, m_train, "hour")
m_train = CreateNumericParametersFromFactor(df_train, m_train, "useragent")
m_train = CreateNumericParametersFromFactor(df_train, m_train, "region")
m_train = CreateNumericParametersFromFactor(df_train, m_train, "city")
m_train = CreateNumericParametersFromFactor(df_train, m_train, "adexchange")
m_train = CreateNumericParametersFromFactor(df_train, m_train, "slotvisibility")
m_train = CreateNumericParametersFromFactor(df_train, m_train, "slotformat")
m_train = CreateNumericParametersFromFactor(df_train, m_train, "keypage")
m_train = CreateNumericParametersFromFactor(df_train, m_train, "advertiser")

#extract 'click' values as labels from train and validate
labels_train = as.matrix(df_train['click'])
labels_validate = as.matrix(df_validate['click'])

ctr_model <- xgboost(data = m_train, label = labels_train, max.depth = 2, eta = 1, nround = 2, nthread = 2, objective = "binary:logistic")

#WriteSolutionCsv(labels_train, df_train)

