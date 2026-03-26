#import "@preview/fletcher:0.5.8" as fletcher: diagram, node
#import "_edge.typ": causal

#set page(width: 190.34645pt, height: 125.34646pt, margin: .5cm)

#let default-radius = 16pt
#let node = node.with(radius: default-radius)
#let exogenous = rgb("#b3b3b3").lighten(65%)

#diagram(
  node-stroke: 1pt,
  edge-stroke: 0.7pt,

  node(name: <X>, (0, 0), $X$),
  node(name: <Y>, (2, 0), $Y$),
  node(name: <U>, (1, -1), $U$, fill: exogenous),
  causal(<U>, <X>),
  causal(<U>, <Y>),
)
