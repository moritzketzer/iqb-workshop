// Graph surgery: do(X = x)
// Incoming edges to X removed (Z → X, U_X → X)
// Fork layout matching scm-example-full.typ

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "_edge.typ": causal

#let ink = rgb("#1B2B3A")
#let teal = rgb("#107895")
#let exo-fill = rgb("#b3b3b3").lighten(65%)

#set page(width: auto, height: auto, margin: .5cm, fill: none)
#set text(font: "Source Sans 3", size: 18pt, fill: ink)

#let default-radius = 18pt
#let endo = node.with(radius: default-radius, stroke: 0.8pt)
#let exo = node.with(radius: default-radius, stroke: 0.8pt + rgb("#888"), fill: exo-fill)
#let fixed = node.with(radius: default-radius, stroke: 1.6pt + teal)

#diagram(
  node-stroke: 0.8pt,
  edge-stroke: 0.7pt,
  spacing: (1.8cm, 1.4cm),

  // Row 0: U_Z
  exo((1, 0), $U_Z$, name: <U_Z>),

  // Row 1: [empty], Z, U_Y — U_X removed
  endo((1, 1), $Z$, name: <Z>),
  exo((2, 1), $U_Y$, name: <U_Y>),

  // Row 2: X (fixed to x), Y
  fixed((0, 2), text(fill: teal)[$x$], name: <X>),
  endo((2, 2), $Y$, name: <Y>),

  // U → endogenous (surviving)
  causal(<U_Z>, <Z>),
  causal(<U_Y>, <Y>),

  // No Z → X (cut)
  // No U_X → X (cut)

  // Surviving causal edges
  causal(<Z>, <Y.north-west>),
  causal(<X>, <Y>),
)
