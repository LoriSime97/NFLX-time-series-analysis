# NFLX-time-series-analysis
The aim of the project is to perform a detailed analysis of the Netflix time series. In particular, we have to 
focus on the daily closing price. 
After having downloaded the multivariate time series1
, we are ready to start.
The first thing to do is to plot the time series, its estimated autocorrelation function and its estimated 
partial autocorrelation function, in order to perform a preliminary graphical analysis.
![1](https://user-images.githubusercontent.com/90756113/133443302-93e7b2be-c068-47e2-b240-c09ed688f5d9.png)
As we can see the data are not satisfactory for our purposes. First of all, the time series seems to be 
nonstationary, indeed we can detect a sort of random behavior and there seem to be periods of low 
volatility and periods of high volatility2
. Moreover, the sample ACF is not acceptable3
. 
This kind of behavior is typical of a random walk which is a process characterized by a strong persistence in 
the ACF. The problem is that if we are dealing with a nonstationary stochastic process all our estimates and 
predictions are useless. 
However, to have more precise information, we need to rely on a formal test to investigate the stationarity 
of the process. In particular, we will use the Augmented Dickey-Fuller test. 
This hypothesis test considers as null hypothesis the presence of a unit root, meaning the non-stationarity 
of the process, therefore our aim is to reject it.
The following table shows the result of the formal test:
![2](https://user-images.githubusercontent.com/90756113/133443416-cc4d5f07-2d46-4988-b279-50ded3781d7d.PNG)
How do we read this table? It is quite straightforward; the variables of interest are the p-value and the test 
statistic. We look at them and make a comparison with the critical values and the fixed significance level. 
Since the p-value is about 9%, considering a 5% or a 1% significance level, we fail to reject the null 
hypothesis, meaning that the process is nonstationary. The same if we consider the observed test statistic. 
Since the ADF statistic is a negative number, considering the 0.7813 observed value, which is higher than all 
the critical values, we do not reject H0, again the process does not seem stationary.
Therefore, the process appears to be nonstationary; any further analysis will be meaningless. It means that
we need to find a proper transformation of the data in order to deal with it, otherwise we cannot overcome 
the problem and we cannot rely on the analysis.
In the provided R code, it is possible to see that the suggested transformation consists in taking the first 
difference of the time series; in other words, we are differentiating the process.

![3](https://user-images.githubusercontent.com/90756113/133443478-708f81b6-185c-4d2d-bb67-ac47e57f14ee.PNG)
In this case the results are quite satisfactory. In particular, we observe both an extremely small p-value and 
a very negative test statistic, greater in absolute value than the critical values. This means that thanks to 
the applied transformation the new time series appears to be stationary. We have to be careful. Indeed, we 
are not sure about this. The time series may be stationary, but we have to deeply analyze its behavior and 
the one of the residuals to assess if this is true or not. For the moment let us assume that everything is fine. 
Therefore, we can proceed with the analysis4
. Before going on, it is interesting to notice that the first 
difference of the process seems to be stationary, while the original process is not stationary. If this is the 
case, meaning if the differentiated process is truly stationary, it means that the starting process is an 
integrated stochastic process of order 1.
![4](https://user-images.githubusercontent.com/90756113/133443572-a67294d1-e47b-4fc8-9e0c-e8e472c5bf98.png)
These are respectively the new time series, the new estimated ACF and the new estimated PACF. 
Considering the fact that these are real data we can say that they behave really well. In particular, both the 
ACF and the PACF decay exponentially fast and they do not seem to be truncated. This may suggest that the 
investigated model is an ARMA process, but in order to assess this further analysis are needed.
The problem is that even in this new time series it is possible to spot some sort of volatility clusters. The 
question is: is this due to the presence of conditional heteroskedasticity or is it due to “real”
heteroskedasticity? Answering this question is extremely important since in the first case we may be able 
to manage the issue, while in the second case we cannot overcome the problem. We will answer in the 
latter part of the paper.
At this point we have said that, excluding for the moment the volatility issue, the process may be assumed 
to be stationary. Therefore, we can try to find the model generating the data. 
Two important remarks are needed. First of all, we will never be able to observe the real model generating 
the data5
. Secondly, we do not even know if a model generating the data exists. It means that we simply try 
to detect a reasonable model and we investigate if it is able to fit the data in a proper way
Using the Akaike information criterion (AIC) and the Bayesian information criterion (BIC), which are two 
methods for model selection, the best models we find are the following ones:
![6](https://user-images.githubusercontent.com/90756113/133443843-ce679eed-b804-40df-9729-ed657e2bc494.PNG)

![7](https://user-images.githubusercontent.com/90756113/133443851-670b84a9-e023-4ec4-af4c-c153bca6adde.PNG)
This means that the AIC suggests an ARMA (1,3) model, while the BIC provides a different model, namely a 
White Noise (ARMA (0,0))6
. On which one should we rely? Since we want to avoid redundancy of the 
parameters and we aim to be as parsimonious as possible, we should choose the simplest model. However, 
are we sure that these two models fit the data in a proper way? To answer these questions, we must rely 
on the residual diagnostic. Indeed, by exploiting the function tsdiag it is possible to perform a graphical 
analysis of the residual behavior.
![8](https://user-images.githubusercontent.com/90756113/133443924-c5446984-e9bf-419d-8598-604ff3fab743.png)
We see that the model suggested by the AIC criterion performs quite well. Even if the standardized 
residuals show the same volatility clusters we have already spotted, they seem to have 0 mean, as 
expected. Moreover, the ACF is almost the same as the theoretical one. Lastly, the p-values from the Ljung-Box test7 are quite satisfactory. They are way above the significance level for the first lags and only from lag 
8 on they are close to the critical threshold. In any case, since we are considering a long time series we 
know that the test is extremely sensible and even small deviations from the null hypothesis are captured 
and are able to affect the results even if they are not that important. Therefore, according to these results
we can say that the model seems to fit the data properly.
Now, consider the residuals of the model suggested by the BIC criterion
![9](https://user-images.githubusercontent.com/90756113/133444007-ae388ca2-f1a3-484c-bc55-255b13337142.png)
Also in this case we notice that the standardized residuals seem to have a 0 mean and again the volatility 
changes over time. Even the ACF is almost the same as before, but what differ is the p-value from the 
Ljung-Box test. This is an extremely important change since all the p-values are either below or close to the 
significance level. Therefore, we can say that this model fitting appears to be not satisfactory. 
To draw some initial conclusions, we can say that the model suggested by the BIC is extremely more 
parsimonious than the one provided by the AIC. This is quite usual since the BIC introduces a stronger 
penalization in order to avoid overparameterized models and redundancy. However, the residuals of the 
BIC suggested model appear to be autocorrelated, that is why we choose to rely on the ARMA (1,3) model, 
the one detected by the AIC, from now on. 
Once we have chosen the model it may be useful to perform a further analysis on the residuals in order to 
verify if they really behave like a White Noise.
The next figures show respectively the residual time series, the residual ACF and the residual PACF, and the 
residual mean and variance.
![10](https://user-images.githubusercontent.com/90756113/133444088-009e3f92-5dd7-4770-ade1-fbda0a214f9f.png)


![11](https://user-images.githubusercontent.com/90756113/133444158-6c1cb909-4273-484b-b03b-1b6b99f46115.PNG)

What can we say from these results? First of all, we know that a White Noise process has 0 mean and a 
variance which is constant over time. From this point of view, the estimates are quite satisfactory. Indeed, 
the only issue regards the variance, since we spot periods of high volatility and periods of low volatility,
which seems to change over time, but for the moment assume it is fine8
. 
Even the estimated ACF and PACF are extremely good. In particular, we know that a WN process has an ACF 
and a PACF which are equal to 1 at lag 0, and then are constantly equal to 0. Here, we see that the first lags, 
which are the most reliable ones, are extremely close to 0. Moreover, also subsequent lags are really small 
and only few of them exceed the boundaries. This is probably due to some kind of estimation error, in 
other words, considering the length of the time series we can assume that it is due to chance. 
Altogether we are satisfied with the result. Then, not only the model seems to fit the data properly, but 
also its residuals behave quite well. At this point, we can check other properties of the residuals, in 
particular it is interesting to investigate if they are normally distributed, meaning if the process is a 
Gaussian White Noise (GWN). In order to do that, we rely on the QQ plot to perform a graphical analysis
and on a hypothesis test to conduct a formal analysis.
![12](https://user-images.githubusercontent.com/90756113/133444205-b9d73148-4efe-4057-ae61-1bb8507f877d.png)
With the QQ plot we compare the theoretical quantiles of the standardized normal distribution with the 
empirical observed quantiles, therefore the more the points are aligned on the line the more likely the 
process generating the data is normally distributed. In this case we are not sure about the result, so it is 
better to rely on a formal test.
![13](https://user-images.githubusercontent.com/90756113/133444291-b8beabd3-d128-417b-82d1-334f23d33aa6.PNG)

The Jarque-Bera test is a test for normality. Since the p-value is extremely small we reject H0 and conclude 
that the process is not normally distributed9
. 
At this point we have a model which seems to fit the data properly, and we have investigated the residuals 
which may be considered a white noise process if we exclude the changes in volatility. Therefore, we can 
compute some forecast. 
As already mentioned, we use the observed time series, which is the first sub-sample, as a sort of training 
data set, meaning that it is used to teach the process about the model generating the data. Then we 
compute a forecast and by relying on the second sub-sample, which represents the real observed data for 
the forecast horizon, we assess the goodness of the prediction. 
In order to better evaluate the prediction, I decided to rely on two different functions of R: the function 
forecast, and the function predict.
The following plots show the provided results

![14](https://user-images.githubusercontent.com/90756113/133444393-988f129e-c31f-42b6-8000-4b43f90f2526.png)
![15](https://user-images.githubusercontent.com/90756113/133444411-aeb2ee4f-52c7-4437-aea3-c0687c449a33.png)
The plots are slightly different, but we can say that they are almost the same. As we can see we get a more 
or less constant prediction but despite of the appearance the forecast is pretty good. Indeed, the prediction 
error is quite small, and all the values lie inside the boundaries10
. Moreover, we notice that the confidence 
interval does not increase significantly over time, this is a confirmation of the fact that the process may 
really be stationary. Indeed, if it was not the case, the prediction interval should increase as the forecast 
horizon increases. 
Finally, we can analyze the volatility and the fact that it seems to change over time. During the paper we 
have noticed that the process seems to have a variance which is not constant, in particular, it is possible to 
detect periods of high volatility and periods of low volatility. We already know that if the process is non 
stationary we are not able to deal with it, therefore it is crucial to understand if the process is truly 
heteroskedastic, and in that case we are not able to overcome the problem and all the estimates, the 
forecasts and the inference we have done are meaningless, or if the process is conditionally 
heteroskedastic, meaning that the process is still stationary but its squared residuals are autocorrelated 
and they can be represented with a more complex model. 

Let us start by having a look at the following plots:![16](https://user-images.githubusercontent.com/90756113/133444532-4817147c-e0a0-476c-8b6f-f54f5a845c37.png)
Thanks to these graphs we can analyze in a clearer way the volatility. Particularly, in the first plot we see 
the behavior of the squared residuals and the fact its variability changes over time. Indeed, there are 
periods characterized by high peaks and periods with an extremely small volatility. In the second plot it is 
possible to observe the ACF of the squared residuals. We can spot some significant correlated coefficients 
even in small lags. This is something we definitely do not like. Finally, in the third plot we observe that all 
the p-values of the McLeod-Li test lie below the significance level, meaning that there is autocorrelation in 
the squared residuals. 
So far, we have said that the model fitting is satisfactory, and the standardized residuals behave well, but 
there is a sort of strange behavior in the squared residuals. Then, the only thing we can do is to try to refine 
the model to account for these volatility clusters by adding an ARCH/GARCH component. If we are not able 
to do this the model is useless. Therefore, we have to detect the best model for the squared residuals. 
The result is shown in the table below:
![17](https://user-images.githubusercontent.com/90756113/133444596-53e4a6a0-f2e2-4c14-8a14-1d8cdf0a4bd2.PNG)

It means that the model we fit to the squared residuals is an ARMA (1, 1). This is really good since as a rule 
of thumb we should at first start considering an ARCH (1, 1) component and then, only if the model fitting is 
not satisfactory, increase the order. This because by adding too many parameters there may arise some 
problems
Now, we have to check if the model fitting is satisfactory. As usual, we have to analyze the behavior of the 
standardized residuals of the fitted model.
![18](https://user-images.githubusercontent.com/90756113/133444729-7b707822-8205-4f2e-9f78-6d8a69ee6e80.png)

From these results, we can conclude that the model fitting is acceptable. Indeed, we are considering a long 
time series and the squared residuals; therefore, it makes sense that there may be some estimation errors 
which can affect the results even in a stronger way than before. Then, to keep the model as parsimonious 
as possible it makes sense to accept this representation.
At this point we have all what we need: the fitted model and the ARCH component, so we can define the
refined model. In particular, the selected model is an ARIMA (1, 0, 3)/ARCH (1, 1). 
The following image shows the output of the R code:![19](https://user-images.githubusercontent.com/90756113/133444799-5941b640-1c6c-4371-bbbb-5a95f2b76008.PNG)
![19b](https://user-images.githubusercontent.com/90756113/133444823-701672d9-7fe6-4366-9613-3b63976295ad.PNG)

As we can see this is a very long output showing all the estimates of the parameters, both the ones of the 
ARIMA and the ones of the ARCH, with the associated errors. Moreover, we see other useful information 
provided by different tests. For instance, in this case we see that we reject the null hypothesis of the 
Jarque-Bera test, therefore we can say that the model is not normally distributed. 
Additional information are provided by the following plots: 
![20](https://user-images.githubusercontent.com/90756113/133444925-4e813da2-d5c8-4f58-94f8-d0068b9fa7d4.png)

In particular, in the first plot we see the time series and some bounds which are computed relying on the 
conditional volatility12. As we can notice, periods of high volatility are characterized by higher estimated 
standard deviations which means the interval boundaries are wider.
Then we see the standardized residuals and the ACF of the standardized residuals and the one of the 
squared residuals. Basically, these results tell us that both they are not autocorrelated. It is extremely good.
In this case what is not fully satisfactory is the last plot which shows the QQ plot of the standardized 
residuals. As we can see, they do not seem to be normally distributed since there are fat tails. Therefore, 
we can try to improve the model by changing the normality assumption. 
In particular, the next table shows the results when we assume the distribution to be sstd, namely skew 
student t distribution.

![21](https://user-images.githubusercontent.com/90756113/133444997-5c7a7cc7-3bf1-4931-91a4-23378cd78649.PNG)
![21b](https://user-images.githubusercontent.com/90756113/133445004-d22978ba-2c00-4497-a9f1-10561b6d5699.PNG)
![22](https://user-images.githubusercontent.com/90756113/133445034-09749263-2b60-4368-a9fb-075a6bd0c63d.png)
At the end we can conclude that we have more or less the same results. What really changes is the QQ plot 
which now behaves much better since almost all the points are aligned on the line. This means that by 
changing the conditional distribution we have been able to improve the model fitting and that the sstd
distribution probably fits the data in a better way than the normal distribution.
The last thing left to do is to compute again the forecast by using the new refined model to see if it 
improved. In particular, since the model with the sstd distribution performs better we will rely on it. ![23](https://user-images.githubusercontent.com/90756113/133445129-254c96f2-d27b-403d-95b2-14e0a441d044.png)




![24](https://user-images.githubusercontent.com/90756113/133445158-231048da-483f-409d-a01a-7c3d7892a2ab.PNG)

The plot and the table above show the forecast computed with the conditional variance, meaning the 
variance computed keeping into account the past information. We immediately notice that all the values lie 
in the confidence interval and, as in the previous cases, the prediction is more or less a constant line.

![25](https://user-images.githubusercontent.com/90756113/133445224-5f8197c3-9969-4b9e-b658-e4103754cc98.png)
![26](https://user-images.githubusercontent.com/90756113/133445250-6dc2007d-4274-4d53-8806-ce35125bf145.PNG)
Here we have the same graphs but computed relying on the unconditional variance. What is strange is that 
theoretically the conditional variance has to provide safer predictions, meaning wider intervals, but in this 
case, it is the opposite. However, by looking at the errors we see that the unconditional forecast has a 
higher error than the conditional one. In any case, both predictions perform quite well since alle the 
observations lie in the confidence interval and the estimation errors are very small
