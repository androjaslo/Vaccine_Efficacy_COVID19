# Definition of the known parameters for our distribution calculation

# ****************************
#         BINOMIAL
# *****************************


# n_V: Number of persons with vaccine
# y_V: COVID 19 positive cases that were vaccinated
# n_P: Number of persons with placebo
# y_P: COVID 19 positive cases with placebo

n_V<- 20533
y_V<- 81
n_P<- 20595
y_P<- 854

# As we want to determinate the distribution of VE we have to
# calculate S random numbers over a beta distribution with the parameters n and y
# thats the reason why we will compare distributions!!!

# We define the number of samples on 100.000 as an arbitrary number
# 
set.seed(42)
S<- 100000
# As the likelihood is a binomial distribution, we are going to implement a 
# prior Beta(a,b), in that order, for an uniform and not informed 
# Beta(1,1) we have it in the form the posterior defined as:
# Beta(alpha + y, beta+ n  - y):

p_V<- rbeta(S,y_V+1,n_V-y_V+1)
p_P<- rbeta(S,y_P+1,n_P-y_P+1)

#Lets remember that rbeta (r function) does the empirical normalization
# Now as defined the VE , we will compute it and have the distributed values of it 

VE<- 1-(p_V/p_P)

# In this way, the mean value of the distribution of the Vaccine Eficciency will be :
mVE<- mean(VE)
cat('Mean VE :', mVE)

# For the 95% of credible interval we implement the quantile calculation over the distribution:
q95<- quantile(VE,c(0.025,0.975))
cat('Credible interval: ',q95)



library(ggplot2)


df <- data.frame(VE)

# 
ggplot(df, aes(VE)) +
  geom_density(color = 'deeppink', fill = 'deeppink',alpha = 0.25) +
  geom_vline(xintercept = mean(VE), color = "black", size = 0.8) +
  geom_vline(xintercept = quantile(VE, c(0.025, 0.975)), color = "black", linetype = "dotted")+
  labs(title = "Posterior distribution of Vaccine Eficcacy (VE)",
    x = " Eficacy",
    y = "Density"
  )

# **************************
#  Logistic
# **************************

# Implementing the Logistic regression in Stan , we have then :

library(cmdstanr)
stan_code1<-"
data {
  int<lower=1> n_V;  
  int<lower=1> n_P;  
  int<lower=0> y_V;  
  int<lower=0> y_P;  
}
parameters {
  real alpha;
  real beta;
}
model {
  alpha ~ normal(0,5);
  beta  ~ normal(0,5);
  
  y_P ~ binomial_logit(n_P, alpha);
  y_V ~ binomial_logit(n_V, alpha + beta);
}
generated quantities {
  real p_V = inv_logit(alpha + beta);
  real p_P = inv_logit(alpha);
  real VE  = 1 - p_V / p_P;
}
"
writeLines(stan_code1, "binomial_logit.stan")
mod<- cmdstan_model("binomial_logit.stan")

data_list <- list(n_V = n_V, n_P = n_P, y_V = y_V, y_P = y_P)

fit <- mod$sample(
  data = data_list,
  seed = 123,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 4000
)

draws <- fit$draws(format = "df")

VE_summary <- fit$summary("VE", "mean", ~quantile(.x, probs = c(0.025, 0.975)))

print(VE_summary)

df <- data.frame(VE = draws$VE)

ggplot(df, aes(VE)) +
  geom_density(color = 'darkorange', fill = 'darkorange', alpha = 0.25) +
  geom_vline(xintercept = mean(draws$VE), color = "black", linewidth = 0.8) +
  geom_vline(xintercept = quantile(draws$VE, c(0.025, 0.975)), color = "black", linetype = "dotted") +
  labs(title = "Posterior distribution of VE - Logistic model",
       x = "Efficacy",
       y = "Density")

cat(mean(draws$VE), quantile(draws$VE,c(0.025,0.975)))


# *******************
# New estimation
# *******************

# As we have determinate the parameter p_i(risk of disease),
#we can compute the posterior predictive 
# distribution of cases in a hypothetical trial with 20000 participants (10000 per arm)
N=10000

p_V<- rbeta(S,y_V+1,n_V-y_V+1)
p_P<- rbeta(S,y_P+1,n_P-y_P+1)

# As in the first point, then, 

y_V_pred<- rbinom(S, size = N, prob = p_V)
y_P_pred<- rbinom(S, size = N, prob = p_P)



cat("Expected cases with vaccine:", mean(y_V_pred))
cat("Expected cases with placebo:", mean(y_P_pred))






