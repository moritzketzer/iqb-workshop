// Conditioning vs Intervening — adapted from Neal (2020) Fig. 4.2
// Four columns: Population, Subpopulations, Conditioning, Intervening
// Two rows: T=1 (top), T=0 (bottom)

#import "@preview/cetz:0.4.2"

#let teal     = rgb("#107895")
#let ink      = rgb("#1B2B3A")
#let blue-bg  = rgb("#B8D4E3")   // T=0 fill
#let red-bg   = rgb("#E8B0A8")   // T=1 fill
#let paper    = rgb("#FAFBFC")

#set page(width: auto, height: auto, margin: .5cm, fill: paper)
#set text(font: "Source Sans 3", fill: ink, size: 11pt)

#cetz.canvas({
  import cetz.draw: *

  let r = 1.5        // circle radius
  let col-gap = 4.0  // horizontal gap between columns
  let row-gap = 4.5  // vertical gap between rows

  // Column x-positions
  let x-pop = 0
  let x-sub = col-gap
  let x-cond = 2 * col-gap
  let x-int = 3 * col-gap

  // Row y-positions (top row = T=1, bottom row = T=0)
  let y-top = 0
  let y-bot = -row-gap

  // ── Column headers ──
  content((x-pop, r + 0.6), text(weight: "semibold", size: 12pt)[Population])
  content((x-sub, r + 0.6), text(weight: "semibold", size: 12pt)[Subpopulations])
  content((x-cond, r + 0.6), text(weight: "semibold", size: 12pt)[Conditioning])
  content((x-int, r + 0.6), text(weight: "semibold", size: 12pt)[Intervening])

  // ── 1. Population: empty circle ──
  circle((x-pop, y-top), radius: r, stroke: 1.2pt + ink, fill: none)

  // ── 2. Subpopulations: split circle (T=0 left, T=1 right) ──
  // Left half (T=0, blue)
  merge-path(close: true, fill: blue-bg, stroke: 1.2pt + ink, {
    arc((x-sub, y-top + r), start: 90deg, delta: 180deg, radius: r)
    line((), (x-sub, y-top + r))
  })
  // Right half (T=1, red)
  merge-path(close: true, fill: red-bg, stroke: 1.2pt + ink, {
    arc((x-sub, y-top - r), start: -90deg, delta: 180deg, radius: r)
    line((), (x-sub, y-top - r))
  })
  // Divider line
  line((x-sub, y-top - r), (x-sub, y-top + r), stroke: 1.2pt + ink)
  // Labels
  content((x-sub - 0.75, y-top), text(size: 12pt)[$T = 0$])
  content((x-sub + 0.75, y-top), text(size: 12pt)[$T = 1$])

  // ── 3. Conditioning: sliced circles ──
  // Top: T=1 — red circle with left slice cut off
  merge-path(close: true, fill: red-bg, stroke: 1.2pt + ink, {
    arc((x-cond, y-top - r), start: -90deg, delta: 180deg, radius: r)
    line((), (x-cond, y-top - r))
  })
  content((x-cond + 0.75, y-top), text(size: 12pt)[$T = 1$])

  // "or" label
  content((x-cond, y-top + y-bot / 2), text(style: "italic", size: 12pt)[or])

  // Bottom: T=0 — blue circle with right slice cut off
  merge-path(close: true, fill: blue-bg, stroke: 1.2pt + ink, {
    arc((x-cond, y-bot + r), start: 90deg, delta: 180deg, radius: r)
    line((), (x-cond, y-bot + r))
  })
  content((x-cond - 0.75, y-bot), text(size: 12pt)[$T = 0$])

  // ── 4. Intervening: full circles ──
  // Top: do(T=1) — full red circle
  circle((x-int, y-top), radius: r, stroke: 1.2pt + ink, fill: red-bg)
  content((x-int, y-top), text(size: 12pt)[$"do"(T = 1)$])

  // "or" label
  content((x-int, y-top + y-bot / 2), text(style: "italic", size: 12pt  )[or])

  // Bottom: do(T=0) — full blue circle
  circle((x-int, y-bot), radius: r, stroke: 1.2pt + ink, fill: blue-bg)
  content((x-int, y-bot), text(size: 12pt)[$"do"(T = 0)$])
})
