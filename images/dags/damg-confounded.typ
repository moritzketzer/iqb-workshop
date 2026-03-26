// DAMG: X → Y with bidirected edge (correlated errors)

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node
#import "_edge.typ": causal, confound

#let ink = rgb("#1B2B3A")

#set page(width: auto, height: auto, margin: .5cm, fill: none)
#set text(font: "Source Sans 3", size: 18pt, fill: ink)

#let default-radius = 18pt
#let endo = node.with(radius: default-radius, stroke: 0.8pt)

#diagram(
  node-stroke: 0.8pt,
  edge-stroke: 0.7pt,
  spacing: (1.8cm, 1.4cm),

  endo((0, 0), $X$, name: <X>),
  endo((2, 0), $Y$, name: <Y>),
  causal(<X>, <Y>),
  confound(<X>, <Y>, bend: 50deg),
)
