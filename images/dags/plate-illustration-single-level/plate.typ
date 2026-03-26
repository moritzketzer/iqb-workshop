#import "@preview/fletcher:0.5.8" as fletcher: diagram, node
#import "../_edge.typ": causal
#import "../_plate.typ": plate

#set page(width: auto, height: auto, margin: .5cm)

#let default-radius = 16pt
#let node = node.with(radius: default-radius)

#diagram(
  node-stroke: 1pt,
  edge-stroke: 0.7pt,

  node(name: <X>, (1, 4), $X$),
  node(name: <Y>, (1, 2), $Y$),
  causal(<X>, <Y>),

  ..plate(
    name: "B:plate:N",
    top-left: (0.3, 1.3),
    bottom-right: (1.7, 4.7),
    inset: 20pt,
    label: $N$,
  ),
)
