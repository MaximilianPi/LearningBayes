# ABC Rejection Algorithm
# 
# Proposed by Tavare, 1997
#
# Implemented by Florian Hartig http://florianhartig.wordpress.com/ 
# Following the pseudocode from http://onlinelibrary.wiley.com/doi/10.1111/j.1461-0248.2011.01640.x/suppinfo , supporting information
# reuse under http://creativecommons.org/licenses/by-sa/4.0/

# assumingwe have observed 10 data points from a simulation model that is Weilbull distributed

observedData =  rweibull(20, 2, 5)
observedSummary = c(mean(observedData), sd(observedData))

# The summary here is used because simulation-based methods are typically more efficient 
# when the dimensionality of the data is low.
# In general, one has to check whether information is lost by such a reduction(sufficiency). 
# I'm actually not sure if it is with this choice, it might be depending on the parameters, 
# but we will see that the summary is good enough 

# Defining a stochastic model with Weilbull output
# For convenience I do the summary in the same step

model <- function(par){
  simulatedData <- rweibull(20, par[1,1], par[1,2])
  simulatedSummary <- c(mean(simulatedData), sd(simulatedData))
  return(simulatedSummary)
}

# Now, here's the ABC-Rejection algorithm 

n = 20000
fit = data.frame(shape = runif(n, 0.01, 6), scale = runif(n, 0.01,10), summary1 = rep(NA, n), summary2 = rep(NA, n), distance = rep(NA, n))

for (i in 1:n){
  prediction <- model(fit[i,1:2])
  deviation = sqrt(sum(( prediction- observedSummary)^2))
  fit[i,3:5] = c(prediction, deviation)
}

# I had already calculated the euclidian distance between observed and simulated summaries
# We now plot parameters for different acceptance intervals

plot(fit[fit[,5] < 1.5, 1:2], xlim = c(0,6), ylim = c(0,10), col = "lightgrey", main = "Accepted parameters for \n different values of epsilon")
points(fit[fit[,5] < 1, 1:2],  pch = 18, col = "gray")
points(fit[fit[,5] < 0.5, 1:2],  pch = 8, col = "red")

legend("topright", c("< 1.5", "< 1", "< 0.5"), pch = c(1,18,8), col = c("lightgrey", "gray", "red"))

abline(v = 2)
abline(h = 5) 

# for comparison
fitdistr(observedData, "weibull")


# alternatively, you can use library(abc) to calculate the acceptance and do some plots 