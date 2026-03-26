# helpers.R — utility functions for exercises

library(tidyverse)
library(lavaan)

#' Extract the exposure → outcome coefficient from a lavaan fit
get_effect <- function(fit, predictor = "exposure") {
  beta <- parameterEstimates(fit) %>%
    filter(lhs == "outcome", rhs == predictor) %>%
    pull(est)
  if (length(beta) == 0) 0 else beta
}

#' Compare two lavaan models on the same data: correct vs wrong specification
compare_models <- function(model_correct, model_wrong, data) {
  fit_correct <- sem(model_correct, data = data)
  fit_wrong   <- sem(model_wrong, data = data)

  beta_correct <- get_effect(fit_correct)
  beta_wrong   <- get_effect(fit_wrong)

  tibble(
    model = c("correct DAG", "wrong DAG"),
    beta  = c(beta_correct, beta_wrong),
    bias  = beta - beta_correct
  )
}
