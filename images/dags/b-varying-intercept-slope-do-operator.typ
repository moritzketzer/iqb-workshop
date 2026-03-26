#import "@preview/fletcher:0.5.8" as fletcher: diagram, node
#import "_edge.typ": causal, confound
#import "../_plate.typ": plate

#set page(width: auto, height: auto, margin: .5cm)

#let default-radius = 16pt
#let node = node.with(radius: default-radius)
#let exogenous = rgb("#b3b3b3").lighten(65%)

#diagram(
  node-stroke: 1pt,
  edge-stroke: 0.7pt,

  node(name: <X>, (7, 4), $X$),
  node(name: <Y>, (9, 4), $Y$),
  causal(<X>, <Y>),

  ..plate(
    name: "plate:N_j",
    top-left: (6.3, 3.3),
    bottom-right: (9.7, 4.7),
    label: $N_j$,
  ),

  node(name: <U_Xμ>, (7, 2), $U^(X mu)$, fill: exogenous),
  node(name: <U_Yμ>, (9, 2), $U^(Y mu)$, fill: exogenous),
  node(name: <U_YX>, (8.3, 2), $U^(Y X)$, fill: exogenous),

  causal(<U_Yμ>, <Y>),
  causal(<U_YX>, <Y>),

  confound(<U_Xμ.north>, <U_Yμ.north>, bend: 60deg),
  confound(<U_YX.north>, <U_Yμ.north>, bend: 60deg),
  confound(<U_YX.north>, <U_Xμ.north>, bend: -60deg),


  ..plate(
    name: "plate:M",
    top-left: (6.18, 0.7),
    bottom-right: (9.82, 5.2),
    label: $M$,
  ),
)
