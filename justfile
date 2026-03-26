# IQB Workshop Presentations

default:
    @just --list

# Clean build artifacts leaked to root by quarto extensions (but preserve site_libs/revealjs)
_clean-artifacts:
    rm -f mathjax-config.js

# After render: copy revealjs from root staging into _site, then clean root staging
_post-render:
    #!/usr/bin/env bash
    if [ -d site_libs/revealjs ]; then
      mkdir -p _site/site_libs
      cp -R site_libs/revealjs _site/site_libs/revealjs
      rm -rf site_libs
    fi

# Render Day 1 presentation
render-day1: _clean-artifacts
    quarto render day1-fundamentals.qmd
    @just _post-render

# Render Day 2 presentation
render-day2: _clean-artifacts
    quarto render day2-advanced.qmd
    @just _post-render

# Render all presentations
render: render-day1 render-day2
    @echo "✓ All presentations rendered"

# Preview Day 1 with hot reload
preview-day1:
    quarto preview day1-fundamentals.qmd

# Preview Day 2 with hot reload
preview-day2:
    quarto preview day2-advanced.qmd

# Run the surviving plot script (requires R + ggplot2)
plots:
    Rscript R/plot_fork_simpsons_scatter.R

# Convert Day 1 to PDF (requires decktape)
pdf-day1: render-day1
    decktape reveal day1-fundamentals.html day1-fundamentals.pdf --size 1920x1080

# Convert Day 2 to PDF (requires decktape)
pdf-day2: render-day2
    decktape reveal day2-advanced.html day2-advanced.pdf --size 1920x1080

# Build all PDFs
pdf: pdf-day1 pdf-day2
    @echo "✓ All PDFs ready"

# Clean generated files
clean:
    rm -f *.html *.pdf
    rm -rf *_cache *_files .quarto _site docs

# Publish to GitHub Pages
publish:
    quarto publish gh-pages

# Open GitHub repository in browser
github:
    open https://github.com/moritzketzer/iqb-workshop

# Open published site in browser
site:
    open https://moritzketzer.github.io/iqb-workshop/
