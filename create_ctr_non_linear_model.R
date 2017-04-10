library(stringr)
library(caret)
library(car)
library(plyr) #for count()
library(xgboost)

FACTOR_PARAMETERS = c("weekday", "hour", "region", "city", "adexchange", "slotvisibility", "slotformat", "keypage", "advertiser", "os", "browser")
LIMIT_BUDGET = 6250
BASE_BID = 0.7

TransformDataFrame <- function(data_frame){
  
  #remove logs with bidprice lower or equal to payprice
  data_frame = subset(data_frame, bidprice>payprice);
  
  #Group levels of slotvisibility: 0->FirstView, 1->SecondView, 2->ThirdView
  levels(data_frame$slotvisibility) = c("FirstView", "SecondView", "ThirdView", "Na", "FifthView", "FirstView", "FourthView", "Na", "OtherView", "SecondView", "ThirdView");
  
  m_os_and_browser = str_split_fixed(data_frame$useragent, "_", 2)
  colnames(m_os_and_browser) = cbind("os", "browser")
  data_frame = cbind(data_frame, m_os_and_browser)
  
  data_frame = TransformFactorParameterToNumeric(data_frame, "weekday");
  
  for(parameter in FACTOR_PARAMETERS){
    data_frame = TransformFactorParameterToNumeric(data_frame, parameter);  
  }
  
  return(data_frame)
}

TransformFactorParameterToNumeric <- function(data_frame, parameter_name) {
  #Frequency
  freq = count(data_frame, vars=parameter_name)
  freq_name = paste (parameter_name, "freq", sep = "") 
  data_frame[[freq_name]] = freq[match(data_frame[[parameter_name]], freq[[parameter_name]]),2]
  
  #CTR
  click_freq = count(data_frame, c(parameter_name, "click"))
  click_freq = click_freq[(click_freq$click=="1"),]
  click_freq$ctr = 100 * click_freq$freq/freq[match(click_freq[[parameter_name]], freq[[parameter_name]]),2]
  ctr_name = paste (parameter_name, "ctr", sep = "")
  data_frame[[ctr_name]] = click_freq[match(data_frame[[parameter_name]], click_freq[[parameter_name]]),4]
  
  return(data_frame)
}

WriteSolutionCsv <- function(labels_train) {
  
  df_test = read.csv("Dataset/test.csv", colClasses=c(rep('factor', 18), rep('factor', 4)))
  levels(df_test$slotvisibility) = c("FirstView", "SecondView", "ThirdView", "Na", "FifthView", "FirstView", "FourthView", "Na", "OtherView", "SecondView", "ThirdView")
  average_ctr_train = sum(with(labels_train, click==1))/nrow(labels_train)
  bidprice = base_bid/average_ctr_train * test_predict
  df_submission = data_frame(df_test$bidid, bidprice)
  colnames(df_submission) <- c("bidid","bidprice")
  write.csv(df_submission, file = "Submission.csv", row.names = FALSE, quote=FALSE)
}

setwd("D:/SSE/Web_Economics/Coursework")

df_train = read.csv("Dataset/train.csv", colClasses=c(rep('factor', 15), 'numeric', 'numeric', 'factor', 'factor', 'numeric', 'factor', 'numeric', 'numeric', rep('factor', 3)))
df_validate = read.csv("Dataset/validation.csv", colClasses=c(rep('factor', 15), 'numeric', 'numeric', 'factor', 'factor', 'numeric', 'factor', 'numeric', 'numeric', rep('factor', 3)))

df_train = TransformDataFrame(df_train)

m_data_train = as.matrix(subset(df_train, select=c(slotwidth, slotheight, slotprice, weekdayfreq, hourfreq, regionfreq, cityfreq, adexchangefreq, slotvisibilityfreq, slotformatfreq, keypagefreq, advertiserfreq, osfreq, browserfreq, weekdayctr, hourctr, regionctr, cityctr, adexchangectr, slotvisibilityctr, slotformatctr, keypagectr, advertiserctr, osctr, browserctr)))
m_labels_train = as.matrix(df_train['click']);
dm_train = xgb.DMatrix(data = m_data_train, label= m_labels_train);

df_validate = TransformDataFrame(df_validate)

m_data_validate = as.matrix(subset(df_validate, select=c(slotwidth, slotheight, slotprice, weekdayfreq, hourfreq, regionfreq, cityfreq, adexchangefreq, slotvisibilityfreq, slotformatfreq, keypagefreq, advertiserfreq, osfreq, browserfreq, weekdayctr, hourctr, regionctr, cityctr, adexchangectr, slotvisibilityctr, slotformatctr, keypagectr, advertiserctr, osctr, browserctr)))
m_labels_validate = as.matrix(df_validate['click']);
dm_validate = xgb.DMatrix(data = m_data_validate, label= m_labels_validate);

watchlist = list(train=dm_train, test=dm_validate)

pctr_model = xgb.train(data = dm_train, max.depth = 4, eta = 0.1, nround = 200, nthread = 4, watchlist= watchlist, verbose = 1, eval.metric = "error", eval.metric = "rmse", eval.metric = "auc", objective = "binary:logistic")

pctr = predict(pctr_model, m_data_validate)

average_ctr_train = sum(m_labels_train==1)/nrow(m_labels_train)
our_bid_price = BASE_BID*(pctr/average_ctr_train);

impressions = sum(our_bid_price > df_validate$payprice)
cost = sum((our_bid_price > df_validate$payprice)*df_validate$payprice)/1000
clicks = sum((our_bid_price> df_validate$payprice)*(df_validate$click=="1"))
ctr = clicks/impressions
cpc = cost/clicks

#WriteSolutionCsv(labels_train, df_train)
