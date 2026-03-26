#!/usr/bin/env bash
# Pre-render hook: sync shared resources.
# Optionally copies fresh CSS/bibliography from global paths if available.
# CI: skips gracefully (uses committed custom.css and references.bib).

# -- Undraw SVG recoloring -------------------------------------------------
# Replace undraw's default purple with the project's theme accent.
# Idempotent: already-recolored files are unchanged.
UNDRAW_DEFAULT="#6c63ff"
UNDRAW_ACCENT="#107895"
UNDRAW_DIR="images/illustrations-undraw"

if [[ -d "$UNDRAW_DIR" ]]; then
  for svg in "$UNDRAW_DIR"/*.svg; do
    [[ -f "$svg" ]] || continue
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i '' "s/${UNDRAW_DEFAULT}/${UNDRAW_ACCENT}/gI" "$svg"
    else
      sed -i "s/${UNDRAW_DEFAULT}/${UNDRAW_ACCENT}/gI" "$svg"
    fi
  done
fi

# -- Shared resources -------------------------------------------------------
global_css="$HOME/.config/quarto/revealjs-global.css"
global_bib="$HOME/.references/references.bib"

if [[ -f "$global_css" ]]; then
  cp "$global_css" _includes/custom.css
fi

# -- Bibliography -----------------------------------------------------------
# Locally: extract only cited entries from the global bib into references.bib.
# CI: references.bib is already committed (small, project-scoped).
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ -f "$global_bib" ]]; then
  "$SCRIPT_DIR/extract-refs.sh" "$global_bib" references.bib ./*.qmd
fi
