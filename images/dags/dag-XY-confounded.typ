// DAG: X → Y with unmeasured confounder U → X, U → Y

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node
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

  endo((0, 1), $X$, name: <X>),
  endo((2, 1), $Y$, name: <Y>),
  exo((1, 0), $U$, name: <U>),
  causal(<X>, <Y>),
  causal(<U>, <X>),
  causal(<U>, <Y>),
)
