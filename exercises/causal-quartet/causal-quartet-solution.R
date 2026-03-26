# ==============================================================================
# Solution: The Causal Quartet
# ==============================================================================

library(tidyverse)
library(quartets)
library(broom)

data <- as_tibble(causal_quartet)

collider   <- data %>% filter(dataset == "(1) Collider")
confounder <- data %>% filter(dataset == "(2) Confounder")
mediator   <- data %>% filter(dataset == "(3) Mediator")
m_bias     <- data %>% filter(dataset == "(4) M-Bias")


# ==============================================================================
# Part 1: Explore
# ==============================================================================

ggplot(collider, aes(x = exposure, y = outcome)) +
  geom_point() + geom_smooth(method = "lm")
ggplot(confounder, aes(x = exposure, y = outcome)) +
  geom_point() + geom_smooth(method = "lm")
ggplot(mediator, aes(x = exposure, y = outcome)) +
  geom_point() + geom_smooth(method = "lm")
ggplot(m_bias, aes(x = exposure, y = outcome)) +
  geom_point() + geom_smooth(method = "lm")

# All four slopes are approximately 0.5:
lm(outcome ~ exposure, data = collider)
lm(outcome ~ exposure, data = confounder)
lm(outcome ~ exposure, data = mediator)
lm(outcome ~ exposure, data = m_bias)

# Correlations between X and Z:
cor(collider$exposure, collider$covariate)
cor(confounder$exposure, confounder$covariate)
cor(mediator$exposure, mediator$covariate)
cor(m_bias$exposure, m_bias$covariate)

# Key insight: the data alone cannot tell you whether to adjust.
# All four datasets look statistically identical.


# ==============================================================================
# Part 2: Predict
# ==============================================================================

# (1) Collider:   Z is a collider (X -> Z <- Y).
#     Should NOT adjust. Adjusting opens a non-causal path.
#
# (2) Confounder: Z is a confounder (X <- Z -> Y).
#     Should adjust. Z creates a backdoor path.
#
# (3) Mediator:   Z is a mediator (X -> Z -> Y).
#     Should NOT adjust for the total effect. Adjusting blocks the
#     causal mechanism.
#
# (4) M-Bias:     Z is a collider on the backdoor path (U1 -> Z <- U2).
#     Should NOT adjust. Adjusting opens a path through U1 and U2.


# ==============================================================================
# Part 3: Verify
# ==============================================================================

lm(outcome ~ exposure + covariate, data = collider)
lm(outcome ~ exposure + covariate, data = confounder)
lm(outcome ~ exposure + covariate, data = mediator)
lm(outcome ~ exposure + covariate, data = m_bias)

# Dataset | Unadjusted B | Adjusted B | What happened?
# --------|--------------|------------|-----------------------------
# (1)     |  0.50        |  0.00      | Adjusting INTRODUCED bias (collider)
# (2)     |  0.50        |  0.73      | Adjusting REMOVED bias (confounder)
# (3)     |  0.45        |  0.00      | Adjusting BLOCKED the mechanism (mediator)
# (4)     |  0.51        |  0.00      | Adjusting INTRODUCED bias (M-bias)


# ==============================================================================
# Part 4: Reflect
# ==============================================================================

# 1. Adjusting INTRODUCES bias in (1) Collider and (4) M-Bias.
#
# 2. Adjusting REMOVES bias in (2) Confounder.
#
# 3. Adjusting BLOCKS the causal mechanism in (3) Mediator.
#
# 4. You cannot tell from the data alone. You need the DAG — a causal model
#    that encodes your assumptions about which variables cause which.
#
# 5. No — the four datasets are statistically indistinguishable.
#    No algorithm can recover the DAG from observational data alone
#    (without additional assumptions like faithfulness + no latent variables).


# ==============================================================================
# Bonus: lavaan
# ==============================================================================

source("helpers.R")

# (1) Collider:    X -> Y, X -> Z <- Y

model_collider_right <- '
  outcome ~ exposure
  covariate ~ exposure + outcome
'

model_collider_wrong <- '
  outcome ~ exposure + covariate
  covariate ~ exposure
'

compare_models(model_collider_right, model_collider_wrong, collider)


# (2) Confounder:  X -> Y, X <- Z -> Y
# Right: adjust for Z (include Z as predictor of both X and Y)
# Wrong: ignore Z (omit the confounder)

model_confounder_right <- '
  outcome ~ exposure + covariate
  exposure ~ covariate
'

model_confounder_wrong <- '
  outcome ~ exposure
'

compare_models(model_confounder_right, model_confounder_wrong, confounder)


# (3) Mediator:    X -> Z -> Y
# Right: full mediation (no direct X -> Y path)
# Wrong: adjust for Z and add direct path (blocks mediation)

model_mediator_right <- '
  covariate ~ exposure
  outcome ~ covariate
'

model_mediator_wrong <- '
  outcome ~ exposure + covariate
  covariate ~ exposure
'

compare_models(model_mediator_right, model_mediator_wrong, mediator)


# (4) M-Bias:      X -> Y, X <- U1 -> Z <- U2 -> Y
# U1 and U2 are unobserved — we can only specify paths among X, Y, Z.
# Right: just the direct effect, leave Z alone
# Wrong: adjust for Z (opens the M-bias path)

model_mbias_right <- '
  outcome ~ exposure
'

model_mbias_wrong <- '
  outcome ~ exposure + covariate
'

compare_models(model_mbias_right, model_mbias_wrong, m_bias)


# Discussion: The wrong models introduce bias in exactly the same cases
# as the wrong lm() adjustments in Part 3. The lavaan specification
# just makes the assumed causal structure explicit.
