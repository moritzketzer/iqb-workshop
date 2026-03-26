# ==============================================================================
# Exercise: The Causal Quartet
#
# You have four datasets. Each has an exposure (X), an outcome (Y),
# and a covariate (Z). Your job: explore, predict, verify.
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
# Part 1: Explore — Can you figure out the right analysis from data alone?
# ==============================================================================

# Your goal: estimate the causal effect of X on Y in each dataset.
# Z is available as a covariate. Can you tell from the data whether
# — and how — to use it?

# Plot outcome vs exposure for each dataset.

ggplot(collider, aes(x = exposure, y = outcome)) +
  geom_point() + geom_smooth(method = "lm")
ggplot(confounder, aes(x = exposure, y = outcome)) +
  geom_point() + geom_smooth(method = "lm")
ggplot(mediator, aes(x = exposure, y = outcome)) +
  geom_point() + geom_smooth(method = "lm")
ggplot(m_bias, aes(x = exposure, y = outcome)) +
  geom_point() + geom_smooth(method = "lm")


# Confirm with numbers — what is the slope in each dataset?

lm(outcome ~ exposure, data = collider)
lm(outcome ~ exposure, data = confounder)
lm(outcome ~ exposure, data = mediator)
lm(outcome ~ exposure, data = m_bias)


# Z is available. Check how it relates to X — does this help you decide
# whether to adjust?

cor(collider$exposure, collider$covariate)
cor(confounder$exposure, confounder$covariate)
cor(mediator$exposure, mediator$covariate)
cor(m_bias$exposure, m_bias$covariate)


# You've tried plots, regressions, and correlations.
# Do you have enough information to decide whether adjusting for Z
# helps or hurts your estimate?


# ==============================================================================
# Part 2: Predict — Use the DAG, not the data
# ==============================================================================

# Open the DAG images in your folder:
#   dag-collider.png, dag-confounder.png, dag-mediator.png, dag-mbias.png
#
# For each dataset, look at its DAG and answer:
#
# Dataset (1) — What role does Z play? ___  Should you adjust? ___  Why? ______
# Dataset (2) — What role does Z play? ___  Should you adjust? ___  Why? ______
# Dataset (3) — What role does Z play? ___  Should you adjust? ___  Why? ______
# Dataset (4) — What role does Z play? ___  Should you adjust? ___  Why? ______


# ==============================================================================
# Part 3: Verify — Adjust for Z and see what happens
# ==============================================================================

# Now fit the ADJUSTED regression: outcome ~ exposure + covariate.
# Compare the slope to the unadjusted slope from Part 1.

lm(outcome ~ exposure + covariate, data = collider)
lm(outcome ~ exposure + covariate, data = confounder)
lm(outcome ~ exposure + covariate, data = mediator)
lm(outcome ~ exposure + covariate, data = m_bias)


# Fill in your results:
#
# Dataset | Unadjusted β | Adjusted β | What happened?
# --------|--------------|------------|---------------
# (1)     |              |            |
# (2)     |              |            |
# (3)     |              |            |
# (4)     |              |            |


# ==============================================================================
# Part 4: Reflect
# ==============================================================================

# 1. In which dataset(s) does adjusting for Z INTRODUCE bias?
#
# 2. In which dataset(s) does adjusting for Z REMOVE bias?
#
# 3. In which dataset(s) does adjusting for Z BLOCK the causal mechanism?
#
# 4. Can you tell from the data alone whether you should adjust?
#    What do you need that the data can't give you?
#
# 5. All four datasets have identical marginal statistics.
#    Could an algorithm look at the data and figure out which DAG generated it?
#    If in doubt, guess!


# ==============================================================================
# Bonus: The same thing in lavaan (for SEM users)
# ==============================================================================
#
# A linear SCM IS a structural equation model.
# Specify each DAG as a lavaan path model — right vs wrong — and see the bias.

# Run this first — loads compare_models()
source("helpers.R")

# (1) Collider:    X → Y, X → Z ← Y

model_collider_right <- '
  outcome ~ exposure
  covariate ~ exposure + outcome
'

model_collider_wrong <- '
  outcome ~ exposure + covariate
  covariate ~ exposure
'

compare_models(model_collider_right, model_collider_wrong, collider)


# (2) Confounder:  X → Y, X ← Z → Y

model_confounder_right <- '
  ...
'

model_confounder_wrong <- '
  ...
'

compare_models(model_confounder_right, model_confounder_wrong, confounder)


# (3) Mediator:    X → Z → Y
# Hint: there is no direct X → Y arrow.

model_mediator_right <- '
  ...
'

model_mediator_wrong <- '
  ...
'

compare_models(model_mediator_right, model_mediator_wrong, mediator)


# (4) M-Bias:      X → Y, X ← U1 → Z ← U2 → Y
# Hint: U1 and U2 are unobserved — what can you specify with only X, Y, Z?

model_mbias_right <- '
  ...
'

model_mbias_wrong <- '
  ...
'

compare_models(model_mbias_right, model_mbias_wrong, m_bias)


# Discussion: In which cases does the wrong model introduce bias?
# How does this match your lm() results from Part 3?
