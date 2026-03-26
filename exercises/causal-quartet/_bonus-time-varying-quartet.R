# ==============================================================================
# Bonus: The Time-Varying Quartet
#
# You saw that four datasets with identical statistics need different
# adjustment strategies. The DAG told you which.
#
# But what if you're unsure about the DAG?
#
# This exercise introduces a powerful heuristic: temporal ordering.
# The same four scenarios, now measured at baseline and follow-up.
# ==============================================================================

library(tidyverse)
library(quartets)
library(broom)


# --- Style (matches workshop theme) ---

STYLE_PAPER   <- "#FAFBFC"
STYLE_INK     <- "#1B2B3A"
STYLE_MUTED   <- "#506070"
STYLE_AXIS    <- "#8A9AAA"
STYLE_PRIMARY <- "#107895"
STYLE_WARN    <- "#C03B26"

theme_set(theme_minimal(base_size = 13))
theme_update(
  plot.background  = element_rect(fill = STYLE_PAPER, colour = NA),
  panel.background = element_rect(fill = STYLE_PAPER, colour = NA),
  panel.grid.minor = element_blank(),
  panel.grid.major = element_line(colour = STYLE_AXIS, linewidth = 0.25),
  axis.text  = element_text(colour = STYLE_MUTED),
  axis.title = element_text(colour = STYLE_INK),
  plot.title = element_text(colour = STYLE_INK, face = "bold"),
  plot.subtitle = element_text(colour = STYLE_MUTED),
  strip.text = element_text(face = "bold", colour = STYLE_INK, size = 13)
)


# ==============================================================================
# Part 1: Explore the time structure
# ==============================================================================

# The quartets package includes time-varying versions of all four datasets.
# Each variable is now measured at baseline (before treatment) and follow-up.

data <- causal_quartet_time %>%
  mutate(dataset = factor(dataset, levels = c(
    "(1) Collider", "(2) Confounder", "(3) Mediator", "(4) M-Bias"
  )))

# What columns do we have?
glimpse(data)

# Baseline vs follow-up: look at the collider dataset.
# How does the covariate relate to the exposure at each time point?

collider <- data %>% filter(dataset == "(1) Collider")

ggplot(collider, aes(x = exposure_baseline, y = covariate_baseline)) +
  geom_point(alpha = 0.5, color = STYLE_MUTED) +
  geom_smooth(method = "lm", se = FALSE, color = STYLE_PRIMARY) +
  labs(title = "Baseline: Exposure vs Covariate",
       x = "Exposure (baseline)", y = "Covariate (baseline)")

ggplot(collider, aes(x = exposure_baseline, y = covariate_followup)) +
  geom_point(alpha = 0.5, color = STYLE_MUTED) +
  geom_smooth(method = "lm", se = FALSE, color = STYLE_PRIMARY) +
  labs(title = "Cross-time: Exposure (baseline) vs Covariate (follow-up)",
       x = "Exposure (baseline)", y = "Covariate (follow-up)")


# ==============================================================================
# Part 2: Predict
# ==============================================================================

# From the cross-sectional quartet, you know:
#   (1) Collider:   Z is caused by X and Y      -- don't adjust
#   (2) Confounder: Z causes both X and Y       -- adjust
#   (3) Mediator:   X causes Z, Z causes Y      -- don't adjust (for total effect)
#   (4) M-Bias:     Z is on a non-causal path   -- don't adjust
#
# Now imagine you DON'T know the DAG, but you DO know when things were measured.
#
# Simple rule: "Only adjust for pre-exposure covariates."
#
# Before running any code, predict:
#
# Dataset        | Adjust baseline Z | Adjust follow-up Z | Which gives correct ATE?
# ---------------|-------------------|--------------------|-------------------------
# (1) Collider   |                   |                    |
# (2) Confounder |                   |                    |
# (3) Mediator   |                   |                    |
# (4) M-Bias     |                   |                    |


# ==============================================================================
# Part 3: Three strategies — run them all
# ==============================================================================

# For each dataset, we fit three models:
#   A) Unadjusted:                outcome_followup ~ exposure_baseline
#   B) Adjust for follow-up Z:    outcome_followup ~ exposure_baseline + covariate_followup
#   C) Adjust for baseline Z:     outcome_followup ~ exposure_baseline + covariate_baseline

true_effects <- tibble(
  dataset = c("(1) Collider", "(2) Confounder", "(3) Mediator", "(4) M-Bias"),
  true_ate = c(1.0, 0.5, 1.0, 1.0)
)

results <- data %>%
  group_by(dataset) %>%
  summarise(
    unadjusted      = coef(lm(outcome_followup ~ exposure_baseline))[2],
    adjust_followup  = coef(lm(outcome_followup ~ exposure_baseline + covariate_followup))[2],
    adjust_baseline  = coef(lm(outcome_followup ~ exposure_baseline + covariate_baseline))[2],
    .groups = "drop"
  ) %>%
  left_join(true_effects, by = "dataset")

# Look at the results:
print(results)

# Which strategy recovers the true effect in each case?
# Compare your predictions from Part 2!


# ==============================================================================
# Part 4: Visualize the comparison
# ==============================================================================

results_long <- results %>%
  pivot_longer(
    cols = c(unadjusted, adjust_followup, adjust_baseline),
    names_to = "strategy",
    values_to = "estimate"
  ) %>%
  mutate(
    strategy = factor(strategy,
      levels = c("unadjusted", "adjust_followup", "adjust_baseline"),
      labels = c("Unadjusted", "Adjust follow-up Z", "Adjust baseline Z")
    ),
    bias = abs(estimate - true_ate) > 0.08
  )

ggplot(results_long, aes(x = strategy, y = estimate, color = bias)) +
  geom_hline(aes(yintercept = true_ate), linetype = "dashed", color = STYLE_MUTED) +
  geom_point(size = 4) +
  scale_color_manual(values = c("FALSE" = STYLE_PRIMARY, "TRUE" = STYLE_WARN), guide = "none") +
  facet_wrap(~dataset, nrow = 1) +
  labs(
    title = "Same data, three adjustment strategies",
    subtitle = "Dashed line = true causal effect. Blue = close. Red = biased.",
    x = NULL, y = "Estimated effect of X on Y"
  ) +
  theme(axis.text.x = element_text(angle = 35, hjust = 1, size = 10))


# ==============================================================================
# Part 5: Why does this work?
# ==============================================================================

# Think about WHY adjusting for baseline Z helps:
#
# (1) Collider:   At follow-up, Z is caused by both X and Y (post-treatment).
#                 At baseline, X hasn't caused anything yet -- no collider path.
#
# (2) Confounder: Z at baseline already captures the common cause.
#                 Adjusting for it removes confounding. Same as cross-sectional.
#
# (3) Mediator:   At follow-up, Z sits between X and Y (post-treatment).
#                 Adjusting for it blocks the causal path.
#                 At baseline, X hasn't yet caused Z -- path stays open.
#
# (4) M-Bias:     Z can be measured before X. The pre-exposure rule
#                 doesn't protect you here. But strict M-bias structures
#                 are very rare in practice (Rubin 2009, Gelman 2011).


# ==============================================================================
# Part 6: Reflect
# ==============================================================================

# 1. In the cross-sectional quartet, you NEEDED the full DAG to decide.
#    With time information, a simple rule solved 3 out of 4 cases.
#    What does this tell you about study design?
#
# 2. The pre-exposure rule is widely recommended by causal inference
#    methodologists (Rubin & Thomas 1996, Rosenbaum 2002).
#    Why might educational researchers not always follow it?
#
# 3. When is the pre-exposure rule NOT enough?
#    (Hint: think about unmeasured confounders, or variables that could
#    plausibly be measured before the exposure but still lie on
#    non-causal paths.)
#
# 4. What is the take-home message for your own research?
#    Think of a specific study you're working on:
#    - Do you have pre-exposure measures of your covariates?
#    - Would temporal ordering change your adjustment decisions?
