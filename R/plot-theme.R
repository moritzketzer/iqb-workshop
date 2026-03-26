# Visual Style — ggplot2 Bindings
# ─────────────────────────────────
# Source at the top of R scripts:
#   source("R/plot-theme.R")
#
# Loads the scientific data palette (R/tokens.R) and sets a consistent
# ggplot2 theme with CVD-safe color scales.
#
# Requires ggplot2 >= 4.0

library(ggplot2)

# ── Load scientific data palette ──────────────────────────────────────────────

source(file.path(dirname(sys.frame(1)$ofile), "tokens.R"))

# ── Base theme ────────────────────────────────────────────────────────────────

theme_set(
  theme_minimal(
    base_size   = 11,
    base_family = "Source Sans 3",
    ink         = STYLE_INK,
    paper       = STYLE_PAPER,
    accent      = STYLE_PRIMARY
  )
)

theme_update(
  panel.grid.minor  = element_blank(),
  panel.grid.major  = element_line(colour = STYLE_AXIS, linewidth = 0.25),
  axis.text         = element_text(colour = STYLE_MUTED),
  axis.title        = element_text(colour = STYLE_INK),
  legend.position   = "top",
  strip.text        = element_text(face = "bold", colour = STYLE_INK)
)

# ── Scale helpers ─────────────────────────────────────────────────────────────

scale_color_qual <- function(n = length(STYLE_QUAL), ...) {
  scale_color_manual(values = STYLE_QUAL[seq_len(n)], ...)
}

scale_fill_qual <- function(n = length(STYLE_QUAL), ...) {
  scale_fill_manual(values = STYLE_QUAL[seq_len(n)], ...)
}

scale_color_seq <- function(reverse = FALSE, ...) {
  if (reverse) {
    scale_color_gradient(low = STYLE_SEQ_DARK, high = STYLE_SEQ_LIGHT, ...)
  } else {
    scale_color_gradient(low = STYLE_SEQ_LIGHT, high = STYLE_SEQ_DARK, ...)
  }
}

scale_fill_seq <- function(reverse = FALSE, ...) {
  if (reverse) {
    scale_fill_gradient(low = STYLE_SEQ_DARK, high = STYLE_SEQ_LIGHT, ...)
  } else {
    scale_fill_gradient(low = STYLE_SEQ_LIGHT, high = STYLE_SEQ_DARK, ...)
  }
}

scale_color_div <- function(midpoint = 0, ...) {
  scale_color_gradient2(
    low      = STYLE_DIV_COOL,
    mid      = STYLE_DIV_MID,
    high     = STYLE_DIV_WARM,
    midpoint = midpoint,
    ...
  )
}

scale_fill_div <- function(midpoint = 0, ...) {
  scale_fill_gradient2(
    low      = STYLE_DIV_COOL,
    mid      = STYLE_DIV_MID,
    high     = STYLE_DIV_WARM,
    midpoint = midpoint,
    ...
  )
}
