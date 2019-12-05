#####
# Final Project
# Regression Analysis

clin_opiate = info.percent
clin_opiate = info.class
spec=c("Pain Management", "Interventional Pain Management", "Anesthesiology", 
       "Physical Medicine and Rehabilitation Family Practice", "General Surgery", "Family Practice", "Internal Medicine",
       "Rheumatology", "Physical Medicine and Rehabilitation", "Addiction Medicine", "General Practice", "Neurology",
       "Emergency Medicine","Orthopedic Surgery", "Infectious Disease","Geriatric Medicine")
st = c("KY", "NH", "NM", "OH", "WV")

# clin_opiate = clin_opiate[info.all.back$Specialty %in% spec,]
#clin_opiate = clin_opiate[clin_opiate$State %in% st,]

#clin_opiate10 = clin_opiate[clin_opiate$opiate>50,]
#clin_opiate = clin_opiate[info.class$opiate<500,]

# Choose either Pain Management, Anesthesiology, Interventional Pain Management, or Physical Medicine and Rehabilitation Family Practice

mydata = clin_opiate

set.seed(101) # reproduceable dataset

# Separate 80%/20% of data as training/testing 
sample <- sample.int(n = nrow(mydata), size = floor(.75*nrow(mydata)), replace = F)
train.info.class <- mydata[sample, ]
test.info.class  <- mydata[-sample, ]

# Separate our data into predictors and responses
x.train = train.info.class[,2:73]
# x.train = train.info.class[,3:13]
# x.train$opiate=NULL
x.train$Opioid.Prescriber=NULL

y.train =train.info.class$deathper100k
# y.train =train.info.class$opiate
# y.train=as.numeric(gsub(",","",train.info.class$Deaths,fixed=TRUE))

x.test = test.info.class[,2:73]
# x.test = test.info.class[,3:13]
# x.test$opiate=NULL
x.test$Opioid.Prescriber=NULL
# x.test = cbind(test.info.class[,3:11],test.info.class[,13])

y.test =test.info.class$deathper100k
# y.test =test.info.class$opiate
# y.test=as.numeric(gsub(",","",test.info.class$Deaths,fixed=TRUE))

# library(PerformanceAnalytics)
# pairs(cbind(x.test,y.test),pch=".")

# Import libraries
library(glmnet)
library(ElemStatLearn)


# Linear Regression
lmfit=lm(y~. , data=data.frame(x=x.train,y=y.train))

# AIC & BIC Analysis
lmfitAICstep= step(lmfit , direction="both",trace=0, k=2)
lmfitAICfor = step(lm(y~1, data=data.frame(x=x.train,y=y.train)) , scope=list (upper=lmfit , lower=~1), direction="forward",trace=0)

# BIC
lmfitBICstep= step(lmfit , direction="both",trace=0, k=log(ncol(x.train))) 
lmfitBICfor = step(lm(y~1, data=data.frame(x=x.train,y=y.train)) , scope=list (upper=lmfit , lower=~1), direction="forward",trace=0, k=log(ncol(x.train)))

# Ridge Regression
ridge.fit=cv.glmnet(y=y.train,x=as.matrix(x.train),alpha = 0, nfolds=5)
round(coef(ridge.fit, s = "lambda.min"),3)
ridge.fit$lambda.min

# Lasso Regression
lasso.fit = cv.glmnet(x=as.matrix(x.train),y=y.train, nfolds = 5)
round(coef(lasso.fit, s = "lambda.min"),3)
lasso.fit$lambda.min

# Predictions
pred.lm        = predict(lmfit,data.frame(x=x.test))
pred.AICstep   = predict(lmfitAICstep,data.frame(x=x.test))
pred.AICfor    = predict(lmfitAICfor,data.frame(x=x.test))
pred.BICstep   = predict(lmfitBICstep,data.frame(x=x.test))
pred.BICfor    = predict(lmfitBICfor,data.frame(x=x.test))
pred.ridge     = predict(ridge.fit,newx=as.matrix(x.test),s="lambda.min")
pred.lasso     = predict(lasso.fit,newx=as.matrix(x.test),s="lambda.min")

mselm          = mean((pred.lm - y.test)^2)
mseAICstep     = mean((pred.AICstep - y.test)^2)
mseAICfor      = mean((pred.AICfor - y.test)^2)
mseBICstep     = mean((pred.BICstep - y.test)^2)
mseBICfor      = mean((pred.BICfor - y.test)^2)
mseridge       = mean((pred.ridge - y.test)^2)
mselasso       = mean((pred.lasso - y.test)^2)

# 
library(gridExtra)
library(grid)

mseresults= matrix(c(mselm,mseAICstep,mseAICfor,mseBICstep,mseBICfor,mseridge,mselasso),ncol=1,byrow=TRUE)
mseresults=round(mseresults,5)
colnames(mseresults) = c("MSE")
rownames(mseresults) = c("Linear Reg","AIC Step","AIC Forward","BIC Step","BIC Forward","Ridge Reg","Lasso Reg")
mseresults = as.table(mseresults)
plot.new()
grid.table(mseresults)


# rf = randomForest(x.train,y.train,ytest=y.test, xtest=x.test, importance = TRUE, ntree = 500)

# knn
library(kknn)

# msetest=0
# K=5
# # pred = matrix(NA, K, length(x))
# 
# for ( k in 1:K ) {
#   knn.fit = kknn(formula=y~., train=cbind(data.frame(y=y.train),x.train), test=cbind(data.frame(y=y.test),x.test), k = k*10, kernel= "rectangular",distance=1)
#   # pred[k,] = knn.fit$fitted.values
#   msetest[k] = mean((knn.fit$fitted.values - y.test)^2)
# }
# 
# mseresults2= matrix(msetest,ncol=1,byrow=TRUE)
# mseresults2=round(mseresults2,5)
# colnames(mseresults2) = c("MSE")
# rownames(mseresults2) = c("k=10","k=20","k=30","k=40","k=50")
# mseresults = as.table(mseresults2)
# plot.new()
# grid.table(mseresults2)
