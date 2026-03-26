# Scientific Data Palette — R Tokens
# ─────────────────────────────────────
# Sourced by R/plot-theme.R
# Do NOT source this file directly — use plot-theme.R.

# ── Figure ground ──────────────────────────────────────────────────────────
STYLE_PAPER   <- "#FAFBFC"
STYLE_INK     <- "#1B2B3A"
STYLE_MUTED   <- "#506070"
STYLE_AXIS    <- "#8A9AAA"
STYLE_PRIMARY <- "#107895"

# ── Qualitative palette — Okabe-Ito Clean (default, CVD-safe, max 6) ────────
STYLE_QUAL <- c(
  "#107895",  # qual-1: primary teal (matches accent)
  "#E69F00",  # qual-2: warm orange
  "#009E73",  # qual-3: bluish green
  "#D55E00",  # qual-4: vermilion
  "#CC79A7",  # qual-5: reddish purple
  "#808080"   # qual-6: neutral gray (de-emphasis / other)
)

# ── Qualitative palette — Okabe-Ito Original (verbatim 2008, 8 colors) ──────
# Use when matching a collaborator's palette or needing the full set.
# No built-in scale helper — pass to scale_color_manual(values = STYLE_QUAL_OI[1:n]).
STYLE_QUAL_OI <- c(
  "#000000",  # black
  "#E69F00",  # orange
  "#56B4E9",  # sky blue
  "#009E73",  # bluish green
  "#F0E442",  # yellow
  "#0072B2",  # blue
  "#D55E00",  # vermilion
  "#CC79A7"   # reddish purple
)

# ── Sequential scale endpoints ─────────────────────────────────────────────
STYLE_SEQ_LIGHT <- "#D4EBF5"  # light end
STYLE_SEQ_DARK  <- "#064D63"  # dark end

# ── Diverging scale poles ──────────────────────────────────────────────────
STYLE_DIV_COOL <- "#107895"   # cool pole (teal)
STYLE_DIV_MID  <- "#EFF3F6"   # midpoint (cooled neutral)
STYLE_DIV_WARM <- "#C07000"   # warm pole (amber)
