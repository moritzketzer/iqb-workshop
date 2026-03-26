# dagitty-helpers.R — simulation, plotting, and gallery for the Open Science DAG exercise

library(tidyverse)
library(broom)

# --- Plot style (scientific data palette — see R/tokens.R) ---

STYLE_PAPER   <- "#FAFBFC"
STYLE_INK     <- "#1B2B3A"
STYLE_MUTED   <- "#506070"
STYLE_AXIS    <- "#8A9AAA"
STYLE_PRIMARY <- "#107895"

theme_set(theme_minimal(base_size = 11))
theme_update(
  plot.background  = element_rect(fill = STYLE_PAPER, colour = NA),
  panel.background = element_rect(fill = STYLE_PAPER, colour = NA),
  panel.grid.minor = element_blank(),
  panel.grid.major = element_line(colour = STYLE_AXIS, linewidth = 0.25),
  axis.text  = element_text(colour = STYLE_MUTED),
  axis.title = element_text(colour = STYLE_INK),
  plot.title = element_text(colour = STYLE_INK),
  strip.text = element_text(face = "bold", colour = STYLE_INK)
)


simulate_open_science <- function(n = 5000, seed = 20230509) {
  set.seed(seed)

  field <- sample(1:2, n, replace = TRUE)
  rigour <- rnorm(n)
  novelty <- rnorm(n)

  open_data <- rbinom(n, 1, plogis(-3 + 0.1 * rigour + c(1, 5)[field]))
  published <- rbinom(n, 1, plogis(-1 + 1 * novelty + 2 * rigour + 8 * open_data))
  data_reuse <- -1 + 2 * open_data + 1 * novelty + rnorm(n)
  reproducibility <- 1 + 0.4 * open_data + 1 * rigour + rnorm(n)
  citations <- -1 + 2 * novelty + 2 * rigour + 2 * published +
    2 * data_reuse + c(10, 20)[field] + rnorm(n)

  tibble(novelty, rigour, field = factor(field), open_data,
         published, data_reuse, reproducibility, citations)
}


plot_bias <- function(data, dag = NULL) {
  true_effect <- 5.4

  model_naive <- lm(citations ~ open_data, data = data)
  model_correct <- lm(citations ~ open_data + field + rigour, data = data)
  model_salad <- lm(citations ~ open_data + field + rigour +
                       data_reuse + published + novelty + reproducibility,
                     data = data)

  results <- tibble(
    model = c("Naive\n(no controls)",
              "True DAG\n(Field, Rigour)",
              "Causal salad\n(control for everything)"),
    estimate = c(coef(model_naive)["open_data"],
                 coef(model_correct)["open_data"],
                 coef(model_salad)["open_data"]),
    ci_lower = c(confint(model_naive)["open_data", 1],
                 confint(model_correct)["open_data", 1],
                 confint(model_salad)["open_data", 1]),
    ci_upper = c(confint(model_naive)["open_data", 2],
                 confint(model_correct)["open_data", 2],
                 confint(model_salad)["open_data", 2])
  )

  subtitle_text <- NULL

  if (!is.null(dag)) {
    dag_result <- tryCatch({
      adj_sets <- adjustmentSets(dag, exposure = "Open Data", outcome = "Citations",
                                 type = "minimal")
      if (length(adj_sets) == 0) {
        list(subtitle = "Your DAG: no valid adjustment set exists",
             label = "Your DAG\n(no valid set)",
             model = lm(citations ~ open_data, data = data))
      } else {
        adj_vars <- adj_sets[[1]]
        r_names <- gsub(" ", "_", tolower(adj_vars))
        available <- r_names[r_names %in% names(data)]
        missing_vars <- adj_vars[!r_names %in% names(data)]
        sub <- if (length(missing_vars) > 0) {
          paste0("Your adjustment set: ", paste(adj_vars, collapse = ", "),
                 " (", paste(missing_vars, collapse = ", "), " not in data)")
        } else {
          paste("Your adjustment set:", paste(adj_vars, collapse = ", "))
        }
        if (length(available) == 0) {
          list(subtitle = sub, label = "Your DAG\n(no measurable adjustors)",
               model = lm(citations ~ open_data, data = data))
        } else {
          formula_yours <- as.formula(paste("citations ~ open_data +",
                                            paste(available, collapse = " + ")))
          list(subtitle = sub,
               label = paste0("Your DAG\n(", paste(adj_vars, collapse = ", "), ")"),
               model = lm(formula_yours, data = data))
        }
      }
    }, error = function(e) NULL)

    if (!is.null(dag_result)) {
      subtitle_text <- dag_result$subtitle
      yours <- tibble(
        model = dag_result$label,
        estimate = coef(dag_result$model)["open_data"],
        ci_lower = confint(dag_result$model)["open_data", 1],
        ci_upper = confint(dag_result$model)["open_data", 2]
      )
      results <- bind_rows(yours, results)
    }
  }

  results <- results %>% mutate(model = fct_inorder(model))

  ggplot(results, aes(x = model, y = estimate)) +
    geom_hline(yintercept = true_effect, linetype = "dashed", color = STYLE_MUTED) +
    geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper),
                    size = 0.8, linewidth = 0.8, color = STYLE_PRIMARY) +
    annotate("text", x = 0.6, y = true_effect, label = "true effect",
             color = STYLE_MUTED, hjust = 0, vjust = -0.5, size = 3.5) +
    labs(x = NULL, y = "Estimated effect of Open Data on Citations",
         subtitle = subtitle_text) +
    coord_cartesian(ylim = c(-2, 15)) +
    theme(plot.subtitle = element_text(colour = STYLE_MUTED, size = 10))
}


submit <- function(pair_name) {
  pair_name <- trimws(pair_name)
  if (nchar(pair_name) == 0) stop("Please provide a pair name, e.g. submit('Ada & Judea')")

  gallery_dir <- "/var/lib/gallery"
  if (!dir.exists(gallery_dir)) stop("Gallery directory not found. Are you on the workshop server?")

  safe_name <- gsub("[^A-Za-z0-9_-]", "_", pair_name)
  timestamp <- format(Sys.time(), "%H%M%S")
  prefix <- file.path(gallery_dir, paste0(safe_name, "_", timestamp))

  # Save DAG plot (base R graphics)
  if (exists("open_science_dag", envir = .GlobalEnv)) {
    png(paste0(prefix, "_dag.png"), width = 1800, height = 1500, res = 150, bg = "white", type = "cairo")
    par(cex = 1.4, font = 2, lwd = 7, col = "black")
    plot(get("open_science_dag", envir = .GlobalEnv))
    dev.off()
    message("  DAG plot saved.")
  } else {
    message("  'open_science_dag' not found -- skipping DAG plot.")
  }

  # Save bias plot (ggplot2) — includes "Your DAG" estimator when DAG is available
  if (exists("df", envir = .GlobalEnv)) {
    dag_obj <- if (exists("open_science_dag", envir = .GlobalEnv)) {
      get("open_science_dag", envir = .GlobalEnv)
    }
    ggsave(paste0(prefix, "_bias.png"), plot_bias(get("df", envir = .GlobalEnv), dag_obj),
           width = 7, height = 5, dpi = 300, bg = "white")
    message("  Bias plot saved.")
  } else {
    message("  'df' not found -- run df <- simulate_open_science() first.")
  }

  # Extract adjustment sets from DAG for metadata
  adjustment_sets <- list()
  if (exists("open_science_dag", envir = .GlobalEnv)) {
    dag <- get("open_science_dag", envir = .GlobalEnv)
    adj <- tryCatch(
      adjustmentSets(dag, exposure = "Open Data", outcome = "Citations",
                     type = "minimal"),
      error = function(e) list()
    )
    adjustment_sets <- unname(lapply(adj, function(x) I(as.character(x))))
  }

  # Metadata (written last -- gallery scanner keys off this file)
  writeLines(
    jsonlite::toJSON(list(pair_name = pair_name, user = Sys.info()[["user"]],
                          time = as.character(Sys.time()),
                          adjustment_sets = adjustment_sets), auto_unbox = TRUE),
    paste0(prefix, "_meta.json")
  )

  message("Submitted to gallery as '", pair_name, "'!")
}
