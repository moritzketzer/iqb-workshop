// SCM example: Z (confounder) → X, Z → Y, X → Y
// With explicit exogenous U_Z, U_X, U_Y
// Fork layout matching dag-fork-confounder.typ

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "_edge.typ": causal

#let ink = rgb("#1B2B3A")
#let exo-fill = rgb("#b3b3b3").lighten(65%)

#set page(width: auto, height: auto, margin: .5cm, fill: none)
#set text(font: "Source Sans 3", size: 18pt, fill: ink)

#let default-radius = 18pt
#let endo = node.with(radius: default-radius, stroke: 0.8pt)
#let exo = node.with(radius: default-radius, stroke: 0.8pt + rgb("#888"), fill: exo-fill)

#diagram(
  node-stroke: 0.8pt,
  edge-stroke: 0.7pt,
  spacing: (1.8cm, 1.4cm),

  //        U_Z
  //         |
  //    U_X  Z  U_Y
  //     |  / \  |
  //      X --> Y

  // Row 0: U_Z above Z
  exo((1, 0), $U_Z$, name: <U_Z>),

  // Row 1: U_X, Z, U_Y
  exo((0, 1), $U_X$, name: <U_X>),
  endo((1, 1), $Z$, name: <Z>),
  exo((2, 1), $U_Y$, name: <U_Y>),

  // Row 2: X, Y
  endo((0, 2), $X$, name: <X>),
  endo((2, 2), $Y$, name: <Y>),

  // U → endogenous
  causal(<U_Z>, <Z>),
  causal(<U_X>, <X>),
  causal(<U_Y>, <Y>),

  // Endogenous causal edges
  causal(<Z>, <X.north-east>),
  causal(<Z>, <Y.north-west>),
  causal(<X>, <Y>),
)
