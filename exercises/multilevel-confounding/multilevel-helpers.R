# ==============================================================================
# Multilevel Location-Scale DGP + brms Model
#
# Take-home reference code. This file contains:
#   1. The data generating process used in the exercise
#   2. The brms distributional model formula
#   3. How to fit the brms model yourself
#
# You need: MASS, brms, cmdstanr (or rstan)
# ==============================================================================


# --- Data Generating Process -------------------------------------------------

generate_multilevel_location_scale <- function(
    number_of_clusters    = 50,
    number_of_individuals = 30,
    true_causal_effect    = 0.6,
    fixed_intercept_X     = 0,
    fixed_intercept_Y     = 0,
    log_sigma_X           = 0,
    sigma_Y               = 1,
    sd_random             = c(
      intercept_X   = 1.0,
      log_sigma_X   = 0.5,
      intercept_Y   = 1.0,
      slope_YX      = 0.8
    ),
    correlation_matrix    = matrix(c(
       1.0,  0.2, -0.3,  0.1,
       0.2,  1.0,  0.1, -0.7,
      -0.3,  0.1,  1.0,  0.2,
       0.1, -0.7,  0.2,  1.0
    ), nrow = 4, byrow = TRUE)
) {
  covariance_matrix <- diag(sd_random) %*% correlation_matrix %*% diag(sd_random)

  eigenvalues <- eigen(covariance_matrix, symmetric = TRUE, only.values = TRUE)$values
  if (!all(eigenvalues > 1e-12)) {
    stop("Covariance matrix is not positive definite. Check parameters.")
  }

  random_effects <- MASS::mvrnorm(
    n     = number_of_clusters,
    mu    = c(0, 0, 0, 0),
    Sigma = covariance_matrix
  )

  M <- number_of_clusters
  N <- number_of_individuals

  cluster_id <- rep(1:M, each = N)

  U_X_mu    <- random_effects[, 1][cluster_id]
  U_X_sigma <- random_effects[, 2][cluster_id]
  U_Y_mu    <- random_effects[, 3][cluster_id]
  U_YX      <- random_effects[, 4][cluster_id]

  eta_X_sigma <- exp(log_sigma_X + U_X_sigma)

  E_X <- rnorm(M * N)
  E_Y <- rnorm(M * N, sd = sigma_Y)

  X <- (fixed_intercept_X + U_X_mu) + eta_X_sigma * E_X
  Y <- (fixed_intercept_Y + U_Y_mu) + (true_causal_effect + U_YX) * X + E_Y

  data.frame(
    cluster_id = factor(cluster_id),
    X          = X,
    Y          = Y
  )
}


# --- brms Distributional Model -----------------------------------------------

# This is the model that recovers the true causal effect.
# It models both location (mean) and scale (variance) of X,
# estimating the full covariance of random effects via |p|.

fit_brms_distributional <- function(data, chains = 4, iter = 4000, warmup = 2000) {
  library(brms)

  model_formula <- bf(
    X ~ 1 + (1 |p| cluster_id),
    sigma ~ 1 + (1 |p| cluster_id)
  ) + bf(
    Y ~ 1 + X + (1 + X |p| cluster_id)
  ) + set_rescor(FALSE)

  brm(
    formula = model_formula,
    data    = data,
    chains  = chains,
    iter    = iter,
    warmup  = warmup,
    cores   = parallel::detectCores() - 1
  )
}


# --- Example usage -----------------------------------------------------------
#
# data <- generate_multilevel_location_scale()
#
# fitted_model <- fit_brms_distributional(data)
#
# summary(fitted_model)
# # Check the Y_X fixed effect — should be close to 0.6
