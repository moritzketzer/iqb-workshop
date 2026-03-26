// DAMG version of scm-example-full: Z/U_Z removed, bidirected X ↔ Y
// Same grid as scm-example-full-z-unobserved.typ so slides toggle cleanly

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "_edge.typ": causal, confound

#let ink = rgb("#1B2B3A")
#let exo-fill = rgb("#b3b3b3").lighten(65%)

#set page(width: auto, height: auto, margin: .5cm, fill: none)
#set text(font: "Source Sans 3", size: 18pt, fill: ink)

#let default-radius = 18pt
#let endo = node.with(radius: default-radius, stroke: 0.8pt)
#let exo = node.with(radius: default-radius, stroke: 0.8pt + rgb("#888"), fill: exo-fill)
#let hidden = node.with(radius: 0pt, stroke: none, fill: none)

#diagram(
  node-stroke: 0.8pt,
  edge-stroke: 0.7pt,
  spacing: (1.8cm, 1.4cm),

  // Row 0: invisible spacer (preserves vertical extent)
  hidden((1, 0), none, name: <U_Z>),

  // Row 1: U_X, invisible spacer, U_Y
  exo((0, 1), $U_X$, name: <U_X>),
  hidden((1, 1), none, name: <Z>),
  exo((2, 1), $U_Y$, name: <U_Y>),

  // Row 2: X, Y
  endo((0, 2), $X$, name: <X>),
  endo((2, 2), $Y$, name: <Y>),

  // U → endogenous
  causal(<U_X>, <X>),
  causal(<U_Y>, <Y>),

  // Causal + bidirected
  causal(<X>, <Y>),
  confound(<X.north>, <Y.north>, bend: -40deg),
)
