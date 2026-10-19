# COVID-19 Vaccine Efficacy Analysis (Bayesian Inference)

A Bayesian analysis estimating the Vaccine Efficacy (VE) of the Pfizer-BioNTech (BNT162b2) COVID-19 vaccine using clinical trial counts from the official [FDA Clinical Review Memorandum](https://www.fda.gov/media/152256/download).

**Authors:** Gabriela Landinez Rangel [https://github.com/gabriela-landinez] and Andrés David Rojas Lozano [https://github.com/androjaslo] 

---

## Summary of Results

Using trial counts ($81/20,533$ cases in the vaccine group vs. $854/20,595$ in the placebo group), we estimated $VE = 1 - \frac{p_V}{p_P}$ across two models:

| Model | Posterior Mean $VE$ | 95% Credible Interval |
| :--- | :---: | :---: |
| **Model 1 (Binomial-Beta Conjugate)** | **90.37%** | [88.07%, 92.41%] |
| **Model 2 (Logistic Regression - Stan)** | **90.46%** | [88.20%, 92.46%] |

Both models yield nearly identical posterior distributions due to the large sample size (demonstrating the Bernstein–von Mises theorem).

---

##  How to Run

1. **Install dependencies in R:**
   ```R
   install.packages(c("ggplot2", "cmdstanr"))
   ```
2. **Execute the analysis:**
   Run `R_Code.R` in RStudio or via terminal:
   ```bash
   Rscript R_Code.R
   ```

---

##  Repository Structure

* `R_Code.R`: Complete pipeline (Monte Carlo sampling, Stan MCMC, and posterior predictive checks).
* `Main.pdf`: Full written project report.
