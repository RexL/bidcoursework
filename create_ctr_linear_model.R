library(stringr)
library(caret)
library(car)
library(dplyr)
library(ROCR) #analyse performance of model

setwd("/cs/student/msc/sse/2016/dmagrina/web_economics_space/bidding_model")

#Read csv files
df_train = read.csv("dataset/train.csv", colClasses=c(rep('factor', 19), 'numeric', 'factor', 'numeric', 'numeric', rep('factor', 3)))
df_validate = read.csv("dataset/validation.csv", colClasses=c(rep('factor', 19), 'numeric', 'factor', 'numeric', 'numeric', rep('factor', 3)))

#remove logs with bidprice lower or equal to payprice
df_train = filter(df_train, bidprice>payprice)
df_validate = filter(df_varmlidate, bidprice>payprice)

#extract 'click' values as labels from train and validate
labels_train = df_train['click']
labels_validate = df_validate['click']

#remove unused columns
df_train = subset(df_train, select=-c(click, bidid, logtype, userid, city, url, urlid, slotprice, bidprice, payprice, keypage, usertag))
df_validate = subset(df_validate, select=-c(click, bidid, logtype, userid, city, url, urlid, slotprice, bidprice, payprice, keypage, usertag))

#calculate logistic regression model for click 
model = glm(unlist(labels_train) ~weekday+hour+region+slotwidth+slotheight+slotvisibility+slotformat+advertiser,family=binomial(link='logit'),data=df_train)

#predict click for validate dataset
p = predict(model, newdata = df_validate, type="response")

#analyse performance
pr = prediction(p, labels_validate)
prf = performance(pr, measure = "tpr", x.measure="fpr")
plot(prf)
auc = performance(pr, measure = "auc")
auc = auc@y.values[[1]]
auc
