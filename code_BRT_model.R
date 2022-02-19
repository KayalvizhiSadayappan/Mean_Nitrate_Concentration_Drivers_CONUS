library(xgboost)
library(Metrics)
library(hydroGOF)
library(MLmetrics)
library(caret)
library(corrplot)
library(RColorBrewer)
library(dendextend)
library(iml)
library(readxl)
library(metR)


Data <- read_excel("Data_Mean_Nitrate_Concentration_Drivers_CONUS.xlsx", 
                   sheet = "Sheet1")

sel_att=c("NITR_APP_KG_SQKM","DEVNLCD06","T_AVG_BASIN",
          "PPTAVG_BASIN","SANDAVE")
pred=Data[sel_att]
obs_y=log(Data$Cmean,10)

#Building the BRT model

ntrain=floor(0.8*nrow(pred))

set.seed(809)#model with median performance 

training.samples <- sample(1:nrow(pred), ntrain, replace=FALSE)

train_data  <- pred[training.samples, ]
test_data <- pred[-training.samples, ]

process_train <- caret::preProcess(train_data, method = c("center", "scale"))
train_data <- predict(process_train,train_data)#rf
test_data <- predict(process_train,test_data)

train_label <- obs_y[training.samples]
test_label <- obs_y[-training.samples]

dtrain <- xgb.DMatrix(data = data.matrix(train_data), label= data.matrix(train_label))#XGBoost
dtest <- xgb.DMatrix(data =  data.matrix(test_data), label= data.matrix(test_label))

set.seed(123)
fit <- xgboost(dtrain
               , max_depth = 7
               , eta = 0.005
               , nrounds = 1400#500
               , subsample = .8
               , colsample_bytree = .9
               ,min_child_weight=9
               ,gamma=0
               #,reg_lambda=2.5
               #,reg_alpha=0.5
               , booster = "gbtree"
               , eval_metric = "rmse"
               , objective="reg:linear")

y_hat_xgb <- predict(fit,xgb.DMatrix(data =  data.matrix(test_data)))
xgb.train <- predict(fit,xgb.DMatrix(data =  data.matrix(train_data)))

R2_Score(y_hat_xgb,test_label) #Test R2 score
rmse(y_hat_xgb,test_label) #Test RMSE
R2_Score(xgb.train,train_label)#Train R2 score
rmse(xgb.train,train_label)#Train RMSE