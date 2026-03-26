# ==============================================================================
# Instructor Version: Does Open Science Help?
#
# Reproduces the simulation and analysis from:
# Klebel & Traag (2024) — "Introduction to causality in science studies"
# Code: https://zenodo.org/records/10639143
#
# One DAG, three causal questions, correct vs. wrong models.
# ==============================================================================

library(tidyverse)
library(dagitty)

theme_set(theme_minimal(base_size = 13))
plot_dir <- "exercises/dagitty-open-science"


# ==============================================================================
# 1. Define the DAG (Figure 1 from the paper)
# ==============================================================================

open_science_dag <- dagitty('dag {
  Novelty [pos="0,0"]
  Rigour [pos="0,2"]
  Open_data [pos="1,1"]
  Published [pos="1,3"]
  Data_reuse [pos="2,0"]
  Reproducibility [pos="2,2"]
  Field [pos="2.5,0.8"]
  Citations [pos="3,0"]

  Novelty -> Citations
  Novelty -> Published
  Novelty -> Data_reuse
  Rigour -> Open_data
  Rigour -> Published
  Rigour -> Citations
  Rigour -> Reproducibility
  Open_data -> Published
  Open_data -> Data_reuse
  Open_data -> Reproducibility
  Data_reuse -> Citations
  Published -> Citations
  Field -> Open_data
  Field -> Citations
}')

plot(open_science_dag)


# ==============================================================================
# 2. Simulate data (Table I from the paper, verified against Zenodo code)
# ==============================================================================

# Coefficients follow the paper's Table I exactly.
# Continuous variables: Normal(mean, sigma=1).
# Binary variables: Bernoulli via logistic link.
# Field is uniform over two fields (coded 1 and 2).

set.seed(20230509)
n <- 5000

# Exogenous variables
field <- sample(1:2, n, replace = TRUE)
rigour <- rnorm(n)
novelty <- rnorm(n)

# Open_data ~ Rigour + Field (binary via logistic)
# Coefficients: intercept = -3, rigour = 0.1, field = c(1, 5)
open_data <- rbinom(n, 1, plogis(-3 + 0.1 * rigour + c(1, 5)[field]))

# Published ~ Novelty + Rigour + Open_data (binary via logistic)
# Coefficients: intercept = -1, novelty = 1, rigour = 2, open_data = 8
published <- rbinom(n, 1, plogis(-1 + 1 * novelty + 2 * rigour + 8 * open_data))

# Data_reuse ~ Open_data + Novelty (continuous)
# Coefficients: intercept = -1, open_data = 2, novelty = 1
data_reuse <- -1 + 2 * open_data + 1 * novelty + rnorm(n)

# Reproducibility ~ Open_data + Rigour (continuous)
# Coefficients: intercept = 1, open_data = 0.4, rigour = 1
reproducibility <- 1 + 0.4 * open_data + 1 * rigour + rnorm(n)

# Citations ~ Novelty + Rigour + Published + Data_reuse + Field (continuous)
# Coefficients: intercept = -1, novelty = 2, rigour = 2, published = 2,
#               data_reuse = 2, field = c(10, 20)
citations <- -1 +
  2 * novelty +
  2 * rigour +
  2 * published +
  2 * data_reuse +
  c(10, 20)[field] +
  rnorm(n)

df <- tibble(
  novelty, rigour, field = factor(field), open_data, published,
  data_reuse, reproducibility, citations
)

cat("n =", nrow(df), "\n")
cat("Open data rate:", round(mean(df$open_data), 3), "\n")
cat("Published rate:", round(mean(df$published), 3), "\n")


# ==============================================================================
# 3. Adjustment sets for all three questions
# ==============================================================================

# --- A: Rigour -> Reproducibility ---
exposures(open_science_dag) <- "Rigour"
outcomes(open_science_dag) <- "Reproducibility"

cat("\n=== A: Rigour -> Reproducibility ===\n")
cat("Adjustment set:\n")
print(adjustmentSets(open_science_dag, type = "minimal"))
# {} -- empty set, no adjustment needed

cat("\nPaths:\n")
print(paths(open_science_dag))


# --- B: Open_data -> Citations ---
exposures(open_science_dag) <- "Open_data"
outcomes(open_science_dag) <- "Citations"

cat("\n=== B: Open_data -> Citations ===\n")
cat("Adjustment set:\n")
print(adjustmentSets(open_science_dag, type = "minimal"))
# { Field, Rigour }

cat("\nPaths:\n")
print(paths(open_science_dag))


# --- C: Open_data -> Reproducibility ---
exposures(open_science_dag) <- "Open_data"
outcomes(open_science_dag) <- "Reproducibility"

cat("\n=== C: Open_data -> Reproducibility ===\n")
cat("Adjustment set:\n")
print(adjustmentSets(open_science_dag, type = "minimal"))
# { Rigour }

cat("\nPaths:\n")
print(paths(open_science_dag))


# ==============================================================================
# 4. Case A: Rigour -> Reproducibility
# ==============================================================================

# True total effect: ~1 (direct = 1, plus tiny indirect via Open_data: 0.1 * 0.4)
# The indirect path goes through Open_data (logistic), so the true total
# effect is computed numerically in the paper's Appendix A. It's close to 1.
# Correct model: simple regression, no controls needed.

model_a_correct <- lm(reproducibility ~ rigour, data = df)

cat("\n=== Case A: Rigour -> Reproducibility ===\n")
cat("True effect: ~1 (direct) + ~0 (indirect via Open_data)\n")
cat("Correct model (no controls):",
    round(coef(model_a_correct)["rigour"], 3), "\n")


# ==============================================================================
# 5. Case B: Open_data -> Citations
# ==============================================================================

# True total effect: ~5.39 (paper's Appendix B, computed numerically)
#   - Via Data_reuse: 2 * 2 = 4
#   - Via Published: 8 (logistic) * 2, but attenuated by the logistic link
#   - The logistic mediation makes the total non-trivial to compute by hand
#
# Correct model: control for confounders { Rigour, Field }
# Wrong model 1: also control for mediators (overcontrol)
# Wrong model 2: "causal salad" -- throw everything in

model_b_correct <- lm(citations ~ open_data + field + rigour, data = df)
model_b_overcontrol <- lm(citations ~ open_data + field + rigour +
                            data_reuse + published, data = df)
model_b_salad <- lm(citations ~ open_data + field + rigour +
                      data_reuse + published + novelty + reproducibility,
                    data = df)

cat("\n=== Case B: Open_data -> Citations ===\n")
cat("True total effect: ~5.39\n")
cat("Correct (+ Field + Rigour):",
    round(coef(model_b_correct)["open_data"], 3), "\n")
cat("Overcontrol (+ mediators):",
    round(coef(model_b_overcontrol)["open_data"], 3), "\n")
cat("Causal salad (everything):",
    round(coef(model_b_salad)["open_data"], 3), "\n")

# Paper's Table II (n=1000): correct ~5.29, causal salad ~-0.06


# ==============================================================================
# 6. Case C: Open_data -> Reproducibility
# ==============================================================================

# True effect: 0.4 (direct, no indirect paths in this direction)
#
# Correct model: control for Rigour, use full sample
# Collider bias: restrict to published papers WITHOUT controlling for Rigour
# Recovered: restrict to published papers WITH Rigour control
#
# The paper shows all three:
#   - Naive published-only analysis reverses the sign (collider bias)
#   - But controlling for Rigour in the published subsample closes the
#     spurious path and recovers the correct estimate

model_c_correct <- lm(reproducibility ~ open_data + rigour, data = df)

published_only <- df %>% filter(published == 1)
model_c_collider_naive <- lm(reproducibility ~ open_data, data = published_only)
model_c_collider_fixed <- lm(reproducibility ~ open_data + rigour,
                              data = published_only)

cat("\n=== Case C: Open_data -> Reproducibility ===\n")
cat("True effect: 0.4\n")
cat("Correct (full sample, + Rigour):",
    round(coef(model_c_correct)["open_data"], 3), "\n")
cat("Collider bias (published only, no Rigour):",
    round(coef(model_c_collider_naive)["open_data"], 3), "\n")
cat("Collider fixed (published only, + Rigour):",
    round(coef(model_c_collider_fixed)["open_data"], 3), "\n")


# ==============================================================================
# 7. Visualize the collider bias (Figure 6 from the paper)
# ==============================================================================

collider_summary <- published_only %>%
  group_by(open_data) %>%
  summarise(
    mean_repro = mean(reproducibility),
    se = sd(reproducibility) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(label = ifelse(open_data == 1, "Open data", "Closed data"))

p_collider <- ggplot(collider_summary,
  aes(x = mean_repro, y = label,
      xmin = mean_repro - 1.96 * se, xmax = mean_repro + 1.96 * se)) +
  geom_pointrange(size = 0.8) +
  labs(
    title = "Collider bias: conditioning on Published",
    subtitle = "Among published papers, open data appears to hurt reproducibility",
    x = "Reproducibility", y = NULL
  )

p_collider
ggsave(file.path(plot_dir, "collider-bias-published.png"),
       p_collider, width = 7, height = 3.5, dpi = 200)


# ==============================================================================
# 8. Stepwise regression gets it wrong (Appendix C from the paper)
# ==============================================================================

# Stepwise regression on Case B removes Open_data and keeps mediators.

full_model <- lm(citations ~ ., data = df)
step_model <- MASS::stepAIC(full_model, direction = "both", trace = FALSE)

cat("\n=== Stepwise regression (Case B) ===\n")
cat("Stepwise formula:", deparse(formula(step_model)), "\n")
cat("Open_data in final model:",
    "open_data" %in% names(coef(step_model)), "\n")
# Stepwise removes Open_data -- concludes it has no effect on Citations!


# ==============================================================================
# 9. Summary table
# ==============================================================================

results <- tribble(
  ~question, ~model, ~estimate, ~true_effect,

  "A: Rigour -> Repro",
  "Correct (no controls)",
  round(coef(model_a_correct)["rigour"], 3), "~1.0",

  "B: Open_data -> Citations",
  "Correct (+ Field, Rigour)",
  round(coef(model_b_correct)["open_data"], 3), "~5.39",

  "B: Open_data -> Citations",
  "Overcontrol (+ mediators)",
  round(coef(model_b_overcontrol)["open_data"], 3), "~5.39",

  "B: Open_data -> Citations",
  "Causal salad (everything)",
  round(coef(model_b_salad)["open_data"], 3), "~5.39",

  "C: Open_data -> Repro",
  "Correct (full sample, + Rigour)",
  round(coef(model_c_correct)["open_data"], 3), "0.4",

  "C: Open_data -> Repro",
  "Collider (published only, no Rigour)",
  round(coef(model_c_collider_naive)["open_data"], 3), "0.4",

  "C: Open_data -> Repro",
  "Collider fixed (published only, + Rigour)",
  round(coef(model_c_collider_fixed)["open_data"], 3), "0.4"
)

cat("\n=== Summary ===\n")
print(results, width = 100)

# Key takeaways:
#
# Case A: No controls needed. All non-causal paths are closed by colliders
#   (Citations, Published). Simple regression recovers the truth.
#
# Case B: Control confounders (Rigour, Field), NOT mediators.
#   - Overcontrol: adding mediators blocks the causal pathway, attenuates.
#   - Causal salad: effect vanishes (~0) because all pathways are blocked.
#   - Stepwise regression removes Open_data entirely -- same wrong conclusion.
#
# Case C: The collider trap.
#   - Analyzing only published papers (= conditioning on a collider) opens
#     the path Open_data -> Published <- Rigour -> Reproducibility.
#   - Without Rigour control: the sign flips (Open_data looks harmful).
#   - With Rigour control: the spurious path is closed, estimate recovers.
#   - Lesson: conditioning on a collider can be fixed IF you also control
#     for the variable that opens the spurious path. But you need the DAG
#     to know which variable that is.
