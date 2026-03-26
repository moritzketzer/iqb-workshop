# ==============================================================================
# Exercise: Multilevel Confounding
#
# You have data from 50 schools, 30 students each.
# X is a continuous predictor, Y is an outcome.
# The true causal effect of X on Y is 0.6.
#
# Your job: fit progressively complex models and see which ones
# recover the true effect — and which ones don't.
# ==============================================================================

library(tidyverse)
library(lme4)

data <- readRDS("multilevel-data.rds")

glimpse(data)


# ==============================================================================
# Part 1: Explore — What does the data look like?
# ==============================================================================

# How many clusters? How many observations per cluster?

data %>%
  count(cluster_id) %>%
  summary()


# Plot Y vs X, colored by cluster (pick a few clusters to keep it readable)

sample_clusters <- sample(levels(data$cluster_id), 9)

data %>%
  filter(cluster_id %in% sample_clusters) %>%
  ggplot(aes(x = X, y = Y)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(~ cluster_id)


# Do all clusters have the same spread in X?
# Compare the within-cluster SD of X across clusters.

data %>%
  group_by(cluster_id) %>%
  summarise(sd_X = sd(X)) %>%
  ggplot(aes(x = sd_X)) +
  geom_histogram(bins = 15) +
  labs(x = "Within-cluster SD of X", y = "Number of clusters")


# Do clusters with more spread in X also have different slopes?
# This is the key question.

cluster_summaries <- data %>%
  group_by(cluster_id) %>%
  summarise(
    sd_X    = sd(X),
    mean_X  = mean(X),
    slope   = coef(lm(Y ~ X))[2]
  )

ggplot(cluster_summaries, aes(x = sd_X, y = slope)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  geom_hline(yintercept = 0.6, linetype = "dashed", color = "grey50") +
  labs(x = "Within-cluster SD of X", y = "Cluster-specific slope",
       caption = "Dashed line = true causal effect (0.6)")


# ==============================================================================
# Part 2: Predict — What should each model give you?
# ==============================================================================

# Before fitting, predict: which models will recover the true effect (0.6)?
# Write down your prediction next to each model.
#
# Model A — lm(Y ~ X)                                          Prediction: ___
# Model B — lm(Y ~ X + cluster_id)   [fixed effects]           Prediction: ___
# Model C — lmer(Y ~ X + (1 + X | cluster_id))                 Prediction: ___
# Model D — lmer(Y ~ X_cw + (1 + X_cw | cluster_id))          Prediction: ___
#           (X_cw = group-mean centered X)
# Model E — Mundlak: lmer(Y ~ X + cluster_mean_X +
#                         X:cluster_mean_X + (1 + X | ...))     Prediction: ___


# ==============================================================================
# Part 3: Verify — Fit the models
# ==============================================================================

# The true causal effect is 0.6.
# Compare each model's estimate of the X slope to that number.

# --- Model A: Simple regression (ignores clustering entirely) ---

model_a <- lm(Y ~ X, data = data)

coef(summary(model_a))["X", ]


# --- Model B: Fixed effects (the econometric "gold standard") ---
# Includes a dummy for each cluster.
# Removes ALL between-cluster confounding (means).
# But the within-cluster estimate is a VARIANCE-WEIGHTED average
# of cluster slopes — clusters with more spread get more weight.

model_b <- lm(Y ~ X + cluster_id, data = data)

coef(summary(model_b))["X", ]


# --- Model C: Random intercept + random slope (uncentered X) ---
# Adds shrinkage: the mixed model pulls extreme cluster slopes toward
# the grand mean. This partially corrects the variance-weighting.

model_c <- lmer(Y ~ X + (1 + X | cluster_id), data = data)

summary(model_c)$coefficients["X", ]


# --- Model D: Group-mean centered X ---
# Centering removes between-cluster mean differences.
# Does it also remove between-cluster variance differences?

data <- data %>%
  group_by(cluster_id) %>%
  mutate(
    cluster_mean_X = mean(X),
    X_cw           = X - cluster_mean_X
  ) %>%
  ungroup()

model_d <- lmer(Y ~ X_cw + (1 + X_cw | cluster_id), data = data)

summary(model_d)$coefficients["X_cw", ]


# --- Model E: Mundlak approach ---
# Adds cluster_mean_X and its interaction with X as fixed effects.
# This decomposes within-cluster and between-cluster effects.

model_e <- lmer(
  Y ~ X + cluster_mean_X + X:cluster_mean_X + (1 + X | cluster_id),
  data = data
)

summary(model_e)$coefficients["X", ]


# --- Compare all estimates ---

results <- tibble(
  model    = c("A: Pooled OLS", "B: Fixed effects",
               "C: RI+RS (uncentered)", "D: RI+RS (centered)",
               "E: Mundlak"),
  estimate = c(
    coef(model_a)["X"],
    coef(model_b)["X"],
    fixef(model_c)["X"],
    fixef(model_d)["X_cw"],
    fixef(model_e)["X"]
  ),
  truth    = 0.6
) %>%
  mutate(bias = estimate - truth)

print(results)


# ==============================================================================
# Part 4: The weighting mechanism — why is fixed effects so biased?
# ==============================================================================

# Fixed effects computes a VARIANCE-WEIGHTED average of within-cluster
# slopes. Let's make this visible.

# You already computed cluster-level slopes in Part 1.
# Now weight them two different ways.

# --- Variance-weighted average (= what fixed effects does) ---
# FE weights each cluster's slope by its within-cluster sum of squares
# of X: SS_X_j = sum((X_ij - mean(X_j))^2).
# Clusters with more spread in X get more weight.

variance_weights <- cluster_summaries$sd_X^2 * 29  # (n-1) * var(X)
variance_weighted <- weighted.mean(cluster_summaries$slope,
                                   w = variance_weights)

cat("Variance-weighted average:", round(variance_weighted, 3), "\n")
cat("Fixed effects estimate:   ", round(coef(model_b)["X"], 3), "\n")
cat("(These should be identical.)\n\n")


# --- Equal-weighted average ---
# Give every cluster the same weight, regardless of spread.

equal_weighted <- mean(cluster_summaries$slope)

cat("Equal-weighted average:   ", round(equal_weighted, 3), "\n")
cat("True causal effect:        0.6\n")
cat("(Much closer — the weighting was the problem.)\n\n")


# --- Visualize the weighting ---

cluster_summaries <- cluster_summaries %>%
  mutate(
    fe_weight    = (sd_X^2 * 29) / sum(sd_X^2 * 29),
    equal_weight = 1 / n()
  )

ggplot(cluster_summaries, aes(x = sd_X, y = slope)) +
  geom_point(aes(size = fe_weight), alpha = 0.5) +
  geom_hline(yintercept = 0.6, linetype = "dashed", color = "grey50") +
  geom_hline(yintercept = variance_weighted, color = "firebrick") +
  geom_hline(yintercept = equal_weighted, color = "steelblue") +
  labs(x = "Within-cluster SD of X", y = "Cluster-specific slope",
       size = "FE\nweight",
       caption = "Dashed = truth (0.6), Red = variance-weighted, Blue = equal-weighted")


# ==============================================================================
# Part 5: Reflect
# ==============================================================================

# 1. Model B (fixed effects) is the MOST biased among the multilevel models.
#    Surprised? This is the model economists recommend for unobserved
#    confounders. Why does it fail here?
#    Hint: it's a pure variance-weighted within-estimator with no shrinkage.
#
# 2. Models C-E (random slopes, centering, Mundlak) do MUCH better.
#    Shrinkage pulls extreme cluster slopes toward the grand mean,
#    partially correcting the distorted weights.
#    But they are STILL biased. Why?
#    Hint: shrinkage reduces the problem but can't eliminate it.
#    The weights are still correlated with the slopes.
#
# 3. The precision-weighted average tracks fixed effects almost perfectly.
#    The equal-weighted average is close to the truth.
#    This proves the mechanism: it's the WEIGHTING, not the estimation.
#
# 4. Centering (Model D) removes between-cluster MEAN differences.
#    But it does NOT change the within-cluster SPREAD of X.
#    Variance-level confounding is a different path than mean-level
#    confounding, and centering can't touch it.
#
# 5. What would a model need to do to close this path?
#    It would need to model cluster-level differences in the VARIANCE of X,
#    not just the mean. That's a distributional model.


# ==============================================================================
# Part 6: The brms solution — a distributional model
# ==============================================================================

# brms can model BOTH location AND scale.
# This is the formula that closes the confounding path:

library(brms)

model_f <- brm(
  bf(
    X ~ 1 + (1 |p| cluster_id),
    sigma ~ 1 + (1 |p| cluster_id)
  ) + bf(
    Y ~ 1 + X + (1 + X |p| cluster_id)
  ) + set_rescor(FALSE),
  data    = data,
  chains  = 4,
  cores   = 2,
  iter    = 2000,
  warmup  = 1000
)

# The key line: sigma ~ 1 + (1 |p| cluster_id)
# This models cluster-level variance heterogeneity in X (U^{X_sigma}).
# The |p| syntax pools all random effects into one covariance matrix,
# so the correlation between U^{X_sigma} and U^{YX} is estimated.

summary(model_f)


# Extract the causal effect estimate

fixef(model_f)["Y_X", ]


# --- Final comparison ---

results_all <- results %>%
  add_row(
    model    = "F: brms distributional",
    estimate = fixef(model_f)["Y_X", "Estimate"],
    truth    = 0.6
  ) %>%
  mutate(bias = estimate - truth)

print(results_all)


# The distributional model recovers the true effect.
# Fixed effects was the most biased multilevel model —
# the econometric "safe choice" is a trap when clusters
# differ in variance, not just in means.
#
# The spectrum: pooled OLS (worst) -> FE (surprisingly bad) ->
# RI+RS (mostly works, shrinkage helps) -> small residual ->
# brms (closes it completely by modeling the variance structure).
