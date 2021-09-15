#clean the environment
rm(list = ls())
graphics.off()

# recall of the packages
require(quantmod)
require(timeSeries) 
require(forecast)
require(fGarch)
require(tseries)
require(TSA) 
require(xts)
require(urca) #better adf test

#get the data 
rawdata <- getSymbols('NFLX', from = '2018-02-01', to = '2020-06-23', auto.assign = FALSE)
#rawdata
head(rawdata)
tail(rawdata)

netflix.close <- window(rawdata$NFLX.Close, start = '2018-02-01', end = '2020-06-23')
layout(matrix(c(1,1,2,3), nrow = 2, ncol = 2, byrow = T))
plot(netflix.close, main = 'Timeseries Netflix', ylim = c(150, 500))
acf(netflix.close, main = " ACF Netflix", ylab = '')
pacf(netflix.close, main = 'Partial ACF Netflix', ylab = '')
#not good acf but pacf good.
#the process seems to be non stationary, let's try with a formal test
ADF.test <- ur.df(netflix.close, type = 'none', selectlags = 'BIC') 
print(summary(ADF.test))
#remember: H0 = non stationarity, we want to reject it. Since the p-value is about 9% with a 5% confidence interval we fail to reject H0, the process is non stationary
#the same if we consider the observed test statistic. since it is higher than all the critical values, we do not reject the null hypothesis. the process is non stationary  
#if the process is non stationary any further analysis will be meaningless, therefore we have to try to solve this problem by applying some kind of transformation to the data

adj.netflix <- diff(netflix.close) #take the first difference
adj.netflix <- adj.netflix[-1] #remove the first NA 
#adj.netflix
ADF.test <- ur.df(adj.netflix, type = 'none', selectlags = 'BIC')
print(summary(ADF.test))
#the p-value is extremely small, and the test statistic is much more negative than the critical values, it means that we reject H0 
#the process seems to be stationary.
#since the process appears to be stationary we can perform our analysis

#create the two sub-samples, one for the analysis and the "training process", the other for the forecast
netflix <- window(adj.netflix, start = '2018-02-01', end = '2020-06-08')
#netflix
#dim(netflix)
netflix.f <- window(adj.netflix, start = '2020-06-09', end = '2020-06-23')
#netflix.f
#dim(netflix.f)

layout(matrix(c(1,1,2,3), nrow = 2, ncol = 2, byrow = T))
plot(netflix, main = 'Timeseries first difference Netflix', ylim = c(-40, 30)) #problem: there seems to be some volatility clusters
acf(netflix, main = 'ACF first difference Netflix', ylab = '')
pacf(netflix, main = 'Partial ACF first difference Netflix', ylab= '')
mean(netflix)
#considering they are real data, they behave quite well. 
#it seems to be an ARMA process since both the ACF and the PACF decay exponentially fast (they are not truncated)
#the problem is that, by looking at the time series, there may be conditional heteroskedasticity

#let's fit a model
fit.model.aic <- auto.arima(netflix, max.p = 10, max.q = 10, ic = 'aic', stationary = TRUE, seasonal = FALSE, stepwise = FALSE, test = 'adf')
fit.model.bic <- auto.arima(netflix, max.p = 10, max.q = 10, ic = 'bic', stationary = TRUE, seasonal = FALSE, stepwise = FALSE, test= 'adf')

fit.model.aic
#ARMA(1,3)
fit.model.bic
#WN (so in this case, since the first difference of the process seems to be a WN, the process should be a random walk)

#we have to check the residuals
tsdiag(fit.model.aic)
tsdiag(fit.model.bic)

#even if the model suggested by the BIC is extremely more parsimonious than the one suggested by the AIC, its residuals does not behave well since they appear to be auto-correlated
#therefore, we choose the model proposed by the AIC criterion, which tends to perform better. its residuals seem to be uncorrelated
#the problem is that also in this case there seem to be some volatility clusters in the residuals, we will investigate it later on

#residuals analysis of the selected model
graphics.off() 
residuals <- fit.model.aic$residuals
layout(matrix(c(1,1,2,3), nrow = 2, ncol = 2, byrow = T))
plot(residuals, main = 'Residuals', ylab = '')
abline(h = 0, col = 'red')
mean(residuals) #mean almost 0, good
var(residuals)
acf(residuals, main = "Residuals ACF", ylab = '')
pacf(residuals,  main = "Residuals Partial ACF", ylab = '')
#we see they have more or less a 0 mean with a relatively high variance, probably due to some volatility clusters;
#moreover both the ACF and the PACF seem to be coherent with the ones of a WN process, they are extremely close to 0 in the first lags and even in higher lags it seems reasonable

#question: are they normally distributed?
graphics.off()
qqnorm(residuals, main = "Residuals QQ Plot")
qqline(residuals, col = 'red')
#it is not too clear, we don't see a strong evidence in favor of our hypothesis. better rely on a formal test
jarque.bera.test(residuals)
#p-value extremely small, reject H0, the residuals are not normally distributed
#be careful, the key assumption for this test is that the residuals are independent 

#now let's compute the forecast. we rely on the training sample to teach the program and then try to forecast the future behaviour of the time series
#since forecast and actual variables belong to two different classes we have to play a trick to make them comparable
forecast <- forecast(netflix, h = 10, level = c(0.9, 0.95))
actual <- ts(data.frame(netflix.f), start = 591, end = 600)
plot(forecast, include = 0, fcol = 'red', main = 'Forecast')
lines(actual, lwd = 2, type = 'b')
legend('bottomleft', col = c('red', 'black'), legend = c('Predicted values', 'Observed values'), lty = c(1,1), lwd = c(2,2))
#to check the accuracy of the forecast. we get ME = 0.0016, quite good
#accuracy(forecast, netflix.f)

#try a different way to better evaluate the prediction
new.forecast <- predict(fit.model.aic, n.ahead = length(netflix.f))
alpha <- 0.05
z <- qnorm(1-alpha/2)
#define the upper and lower bounds
upper <- new.forecast$pred + z*new.forecast$se
lower <- new.forecast$pred - z*new.forecast$se

ts.plot(netflix.f, new.forecast$pred, upper, lower, col = c('black', 'red', 'blue', 'blue'), lty = c(1,2,2,2), type = 'b', main = 'Forecast', lwd = c(2,1,1,1))
legend('bottomright', col = c('black', 'red', 'blue', 'blue'), legend = c('Observed values', 'Predicted values', 'Boundaries'), lty = c(1,2,2,2))

#now to  conclude we have to try to deal with the observed volatility
#in particular we want to understand if there is conditional heteroskedasticity or if the model is truly heteroskedastic, meaning we cannot deal with it

squared.residuals <- residuals^2
layout(matrix(c(1,1,2,3), nrow = 2, ncol = 2, byrow = T))
plot(squared.residuals, main = 'Squared Residuals', ylab = '')
acf(squared.residuals, main = 'ACF of Squared Residuals', ylab = '')
#The test checks for the presence of conditional heteroskedascity by computing the Ljung-Box test with the squared data or with the squared residuals from an ARIMA model
McLeod.Li.test(fit.model.aic, main = 'p values for McLeod-Li statistic')
#we can assume that there is conditional heteroskedasticity, are we able to deal with it?

#let's try to fit an ARCH/GARCH component to the model

#first of all let's try to identify the best model for the squared residuals
fit.model.squared.residuals <- auto.arima(squared.residuals, max.p = 5, max.q = 4, ic = 'bic', stationary = TRUE, seasonal = FALSE, stepwise = FALSE)
print(fit.model.squared.residuals)
#the result is an ARMA(1,1), this is extremely good since we want to avoid over-parameterized  models. usually the ARMA(1,1) is the best solution in these situations
#we want to investigate if the model fitting is satisfactory
tsdiag(fit.model.squared.residuals)
#the model fitting seems to be acceptable since the p-values of the first lags, which are the most significant ones, are above the significance level
#we can try to identify an alternative model 

#fit.model.squared.residuals.aic <- auto.arima(squared.residuals, max.p = 5, max.q = 4, ic = 'aic', stationary = TRUE, seasonal = FALSE, stepwise = FALSE)
#print(fit.model.squared.residuals.aic)
#tsdiag(fit.model.squared.residuals.aic)
#we obtain the same result in both the two cases

#now that we have identified the best model for the squared residuals let's define the ARIMA/ARCH process
#in particular our model is an: ARIMA(1,0,3)/ARCH(1,1)
#we use two alternative: normal distribution and skewed student t distribution 
arima.arch.norm <- garchFit(formula = ~arma(1,3) + garch(1,1),data = netflix, 
                     cond.dist = 'norm', trace = F)
print(summary(arima.arch.norm))
layout(matrix(c(1,1,2:5), nrow = 3, ncol = 2, byrow=T))
plot(arima.arch.norm, which = 3)
plot(arima.arch.norm, which = 9)
plot(arima.arch.norm, which = 10)
plot(arima.arch.norm, which = 11)
plot(arima.arch.norm, which = 13)

arima.arch.sstd <- garchFit(formula = ~arma(1,3) + garch(1,1),data = netflix, 
                            cond.dist = 'sstd', trace = F)
print(summary(arima.arch.sstd))
layout(matrix(c(1,1,2:5), nrow = 3, ncol = 2, byrow=T))
plot(arima.arch.sstd, which = 3)
plot(arima.arch.sstd, which = 9)
plot(arima.arch.sstd, which = 10)
plot(arima.arch.sstd, which = 11)
plot(arima.arch.sstd, which = 13)

#at this point, all it remains it is to make a new forecast and observe if it is improved
#since the sstd distribution performs a better analysis we rely on it 
#again, we have two possible alternatives: conditional and unconditional variance
graphics.off()
new.forecast.cond <- predict(arima.arch.sstd, nx = 5, plot = T, mse = 'cond', n.ahead = length(netflix.f))
points(as.numeric(c(rep(NA, 5), netflix.f)), type = 'b')
summary(new.forecast.cond)

new.forecast.uncond <- predict(arima.arch.sstd, nx = 5, plot = T, mse = 'uncond', n.ahead = length(netflix.f))
points(as.numeric(c(rep(NA, 5), netflix.f)), type = 'b')
summary(new.forecast.uncond)
#strangely, the unconditional seems to provide a safer estimate. in any case, it has a slightly higher error

