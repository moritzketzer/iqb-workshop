#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "_edge.typ": causal, confound
#import "_plate.typ": plate

#set page(width: auto, height: auto, margin: .5cm)

#let default-radius = 16pt
#let node = node.with(radius: default-radius)
#let exogenous = rgb("#b3b3b3").lighten(65%)

#diagram(
  node-stroke: 1pt,
  edge-stroke: 0.7pt,

  node(name: <X>, (1, 1), $X$),
  node(name: <Y>, (3, 1), $Y$),
  causal(<X>, <Y>),

  // exogenous nodes level-2
  node(name: <U_Xμ>, (1, -0.3), $U^(X mu)$, fill: exogenous),
  node(name: <U_Y>, (3, -0.3), $U^Y$, fill: exogenous),
  node(name: <U_YX>, (2.36, -0.3), $U^(Y X)$, fill: exogenous),
  node(name: <U_Xσ>, (1.64, -0.3), $U^(X sigma)$, fill: exogenous),

  // directed edges
  causal(<U_Xμ>, <X>),
  causal(<U_Y>, <Y>),
  causal(<U_YX.south-east>, <Y>, shift: (-4pt, 0pt)),
  causal(<U_Xσ.south-west>, <X>, shift: (4pt, 0pt)),

  // bidirected arrows
  confound(<U_Xμ.north>, <U_Y.north>, bend: 60deg),
  confound(<U_Xμ.north>, <U_YX.north>, bend: 60deg),
  confound(<U_YX.north>, <U_Xσ.north>, bend: -60deg),

  ..plate(
    name: "plate:N_j",
    top-left: (0.1, 0.4),
    bottom-right: (3.81, 1.7),
    label: $N_j$,
  ),

  ..plate(
    name: "plate:M",
    top-left: (0, -1.8),
    bottom-right: (3.9, 2.2),
    label: $M$,
  ),

)
