library(stringr)
library(caret)
library(car)
library(dplyr)
library(ROCR) #analyse performance of model

setwd("D:/SSE/Web_Economics/Coursework")

#Read csv files
df_train = read.csv("Dataset/train.csv", colClasses=c(rep('factor', 19), 'numeric', 'factor', 'numeric', 'numeric', rep('factor', 3)))
df_validate = read.csv("Dataset/validation.csv", colClasses=c(rep('factor', 19), 'numeric', 'factor', 'numeric', 'numeric', rep('factor', 3)))

#remove logs with bidprice lower or equal to payprice
df_train = filter(df_train, bidprice>payprice)
df_validate = filter(df_validate, bidprice>payprice)

#extract 'click' values as labels from train and validate
labels_train = df_train['click']
labels_validate = df_validate['click']

#remove unused columns
df_train = subset(df_train, select=-c(click, bidid, logtype, userid, region, city, url, urlid, slotprice, bidprice, payprice, keypage, usertag))
df_validate = subset(df_validate, select=-c(click, bidid, logtype, userid, region, city, url, urlid, slotprice, bidprice, payprice, keypage, usertag))

#Group levels of slotvisibility: 0->FirstView, 1->SecondView, 2->ThirdView
levels(df_train$slotvisibility) = c("FirstView", "SecondView", "ThirdView", "Na", "FifthView", "FirstView", "FourthView", "Na", "OtherView", "SecondView", "ThirdView")
levels(df_validate$slotvisibility) = c("FirstView", "SecondView", "ThirdView", "Na", "FifthView", "FirstView", "FourthView", "Na", "OtherView", "SecondView", "ThirdView")

#calculate logistic regression model for click 
model = glm(unlist(labels_train) ~weekday+hour+slotvisibility+advertiser,family=binomial(link='logit'),data=df_train)

#predict click for validate dataset
p = predict(model, newdata = df_validate, type="response")

#analyse performance
pr = prediction(p, labels_validate)
prf = performance(pr, measure = "tpr", x.measure="fpr")

plot(prf)
auc = performance(pr, measure = "auc")
auc = auc@y.values[[1]]
auc

df_test = read.csv("Dataset/test.csv", colClasses=c(rep('factor', 18), rep('factor', 4)))
levels(df_test$slotvisibility) = c("FirstView", "SecondView", "ThirdView", "Na", "FifthView", "FirstView", "FourthView", "Na", "OtherView", "SecondView", "ThirdView")

test_predict = predict(model, newdata = df_test, type="response")

limit_budget = 25000
base_bid = 25
average_ctr_train = sum(with(labels_train, click==1))/nrow(df_train)
bidprice = base_bid/average_ctr_train * test_predict
df_submission = data_frame(df_test$bidid, bidprice)
colnames(df_submission) <- c("bidid","bidprice")
write.csv(df_submission, file = "Submission.csv", row.names = FALSE, quote=FALSE)

