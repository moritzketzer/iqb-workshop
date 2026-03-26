#import "@preview/fletcher:0.5.8" as fletcher: diagram, node
#import "../_edge.typ": causal

#set page(width: auto, height: auto, margin: .5cm)

#let default-radius = 16pt
#let node = node.with(radius: default-radius)

#diagram(
  node-stroke: 1pt,
  edge-stroke: 0.7pt,

  node(name: <X>, (1, 4), $X_i$),
  node(name: <Y>, (1, 2), $Y_i$),
  causal(<X>, <Y>),
)
