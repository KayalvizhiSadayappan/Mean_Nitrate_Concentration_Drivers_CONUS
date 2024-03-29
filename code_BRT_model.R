library(xgboost)
library(Metrics)
library(MLmetrics)
library(caret)
library(readxl)


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
               , nrounds = 1400
               , subsample = .8
               , colsample_bytree = .9
               ,min_child_weight=9
               ,gamma=0
               , booster = "gbtree"
               , eval_metric = "rmse"
               , objective="reg:linear")

y_hat_xgb <- predict(fit,xgb.DMatrix(data =  data.matrix(test_data)))
xgb.train <- predict(fit,xgb.DMatrix(data =  data.matrix(train_data)))

R2_Score(y_hat_xgb,test_label) #Test R2 score
rmse(y_hat_xgb,test_label) #Test RMSE
R2_Score(xgb.train,train_label)#Train R2 score
rmse(xgb.train,train_label)#Train RMSE

#Insert NITR_APP_KG_SQKM (Nrate or nitrate application rate) in kg/km2/yr, 
#       DEVNLCD06 (Aurban% in paper, Percent developed area) in %,
#       PPTAVG_BASIN (MAP or Mean Annual Precipitation) in cm/yr,
#       T_AVG_BASIN (MAT or Mean Annual Temperature) in degree C,
#       SANDAVE (Sand% or Sand content) in %.

own_data<-data.frame(NITR_APP_KG_SQKM=5500,
                     DEVNLCD06=20,
                     T_AVG_BASIN=15,
                     PPTAVG_BASIN=100,
                     SANDAVE=50
                     )

#Calculate mean nitrate concentration for a particular basin using median BRT models
predicted_log_conc_medianBRT <- predict(fit,xgb.DMatrix(data =  data.matrix(own_data)))
pred_conc_medianBRT <- 10^predicted_log_conc

#Calculate mean nitrate concentration for a particular basin using 1000 BRT models

for (i in 1:1000){
  set.seed(i+123)
  
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
                 , nrounds = 1400
                 , subsample = .8
                 , colsample_bytree = .9
                 ,min_child_weight=9
                 ,gamma=0
                 , booster = "gbtree"
                 , eval_metric = "rmse"
                 , objective="reg:linear")
  xgboost_1000models[[i]]=fit
}

predicted_log_conc=rep(NA,1000)
for (k in 1:1000){
  predicted_log_conc[k] <- predict(xgboost_1000models[[k]],xgb.DMatrix(data =  data.matrix(own_data)))
}
predicted_conc <- 10^(predicted_log_conc)
