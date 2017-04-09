library(stringr)
library(caret)
library(car)
library(plyr) #for count()
library(xgboost)

FACTOR_PARAMETERS = c("weekday", "hour", "useragent", "region", "city", "adexchange", "slotvisibility", "slotformat", "keypage", "advertiser")

GetDataMatrix <- function(data_frame){
  
  #remove logs with bidprice lower or equal to payprice
  data_frame = subset(data_frame, bidprice>payprice)
  
  #Group levels of slotvisibility: 0->FirstView, 1->SecondView, 2->ThirdView
  levels(data_frame$slotvisibility) = c("FirstView", "SecondView", "ThirdView", "Na", "FifthView", "FirstView", "FourthView", "Na", "OtherView", "SecondView", "ThirdView")
  
  #Create matrix with parameters that don't need transformation
  m_data = as.matrix(subset(data_frame, select=c(slotwidth, slotheight, slotprice)));
  
  for(parameter in FACTOR_PARAMETERS){
    m_data = TransformFactorParameterToNumeric(data_frame, m_data, parameter)  
  }
  
  m_labels = as.matrix(data_frame['click'])
  
  dmatrix = xgb.DMatrix(data = m_data, label= m_labels)
  
  return(class(dmatrix))
}

TransformFactorParameterToNumeric <- function(df_train, m_train, parameter_name) {
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

dm_train = GetDataMatrix(df_train)
dm_validate = GetDataMatrix(df_validate)
dmwatchlist = list(train=dm_train, test=dm_validate)

ctr_model = xgb.train(data = dm_train, max.depth = 2, eta = 1, nround = 2, nthread = 2, watchlist= watchlist, objective = "binary:logistic")

#WriteSolutionCsv(labels_train, df_train)
