library(stringr)
library(caret)
library(car)
library(dplyr)
library(ROCR) #analyse performance of model


EvaluateModel <- function(base_bid, pctr, average_ctr_train, df_evaluate) {
  
  our_bid_price = base_bid*(pctr/average_ctr_train);
  
  impressions = sum(our_bid_price > df_evaluate$payprice);
  cost = sum((our_bid_price > df_evaluate$payprice)*df_evaluate$payprice)/1000;
  clicks = sum((our_bid_price> df_evaluate$payprice)*(df_evaluate$click=="1"));
  ctr = clicks/impressions;
  cpc = cost/clicks;
  
  return(data.frame(base_bid, impressions, cost, clicks, ctr, cpc));
}


WriteSolutionCsv <- function(model, average_ctr_train, base_bid) {
  
  df_test = read.csv("Dataset/test.csv", colClasses=c(rep('factor', 18), rep('factor', 4)))
  levels(df_test$slotvisibility) = c("FirstView", "SecondView", "ThirdView", "Na", "FifthView", "FirstView", "FourthView", "Na", "OtherView", "SecondView", "ThirdView")
  
  test_predict = predict(model, newdata = df_test, type="response")
  
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

#extract 'click' values as labels from train and validate
labels_train = df_train['click']
labels_validate = df_validate['click']

#Group levels of slotvisibility: 0->FirstView, 1->SecondView, 2->ThirdView
#because originally it was 0 , 1 , 2, 225 , FifthView, FirstView, etc, by change the frist four into FirstView, Secondview, ThirdView, Na, we have more data to look at
levels(df_train$slotvisibility) = c("FirstView", "SecondView", "ThirdView", "Na", "FifthView", "FirstView", "FourthView", "Na", "OtherView", "SecondView", "ThirdView")
levels(df_validate$slotvisibility) = c("FirstView", "SecondView", "ThirdView", "Na", "FifthView", "FirstView", "FourthView", "Na", "OtherView", "SecondView", "ThirdView")

#calculate logistic regression model for click 
model = glm(unlist(labels_train) ~weekday+hour+slotvisibility+advertiser,family=binomial(link='logit'),data=df_train)

#predict click for validate dataset
pctr = predict(model, newdata = df_validate, type="response")

#analyse performance
pr = prediction(pctr, labels_validate)
prf = performance(pr, measure = "tpr", x.measure="fpr")

plot(prf)
auc = performance(pr, measure = "auc")
auc = auc@y.values[[1]]
auc

average_ctr_train = sum(labels_train==1)/nrow(labels_train)
evaluation = data.frame(base_bid=double(), impressions=integer(), cost=double(), clicks=integer(), ctr=double(), cpc=double())

for(base_bid in seq(from=0.4, to=100, by=0.1)){
  
  evaluation = merge(evaluation, EvaluateModel(base_bid, pctr, average_ctr_train, df_validate), all = TRUE);
  
}

write.csv(evaluation, file = "Evaluation_linear.csv", row.names = FALSE, quote=FALSE)

WriteSolutionCsv(model, average_ctr_train, 25)

