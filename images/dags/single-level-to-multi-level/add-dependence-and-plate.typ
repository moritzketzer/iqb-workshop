#import "@preview/fletcher:0.5.8" as fletcher: diagram, node
#import "../_edge.typ": causal, confound
#import "../_plate.typ": plate

#set page(width: auto, height: auto, margin: .5cm)

#let default-radius = 16pt
#let node = node.with(radius: default-radius)

#diagram(
  node-stroke: 1pt,
  edge-stroke: 0.7pt,

  node(name: <Y_1>, (1, 2), $Y_(1)$),
  node(name: <Y_2>, (2, 2), $Y_(i)$),
  node(name: <Y_dots>, (3, 2), $dots$, stroke: 0pt),
  node(name: <Y_N>, (4, 2), $Y_(N)$),

  node(name: <X_1>, (1, 4), $X_(1)$),
  node(name: <X_2>, (2, 4), $X_(i)$),
  node(name: <X_dots>, (3, 4), $dots$, stroke: 0pt),
  node(name: <X_N>, (4, 4), $X_(N)$),

  causal(<X_1>, <Y_1>),
  causal(<X_2>, <Y_2>),
  causal(<X_N>, <Y_N>),

  // diagram 2
  node(name: <Y_1_d2>, (1, 7), $Y_(1j)$),
  node(name: <Y_2_d2>, (2, 7), $Y_(\ij)$),
  node(name: <Y_dots_d2>, (3, 7), $dots$, stroke: 0pt),
  node(name: <Y_N_d2>, (4, 7), $Y_(\Nj)$),

  node(name: <X_1_d2>, (1, 9), $X_(1j)$),
  node(name: <X_2_d2>, (2, 9), $X_(\ij)$),
  node(name: <X_dots_d2>, (3, 9), $dots$, stroke: 0pt),
  node(name: <X_N_d2>, (4, 9), $X_(\Nj)$),

  causal(<X_1_d2>, <Y_1_d2>),
  causal(<X_2_d2>, <Y_2_d2>),
  causal(<X_N_d2>, <Y_N_d2>),

  confound(<Y_1_d2>, <Y_2_d2>, bend: 50deg),
  confound(<Y_1_d2>, <Y_N_d2>, bend: 50deg),
  confound(<Y_2_d2>, <Y_N_d2>, bend: 50deg),

  confound(<X_1_d2>, <X_2_d2>, bend: -50deg),
  confound(<X_1_d2>, <X_N_d2>, bend: -50deg),
  confound(<X_2_d2>, <X_N_d2>, bend: -50deg),

  ..plate(
    name: "plate:M",
    top-left: (0.3, 5.5),
    bottom-right: (4.7, 10.5),
    inset: 25pt,
    label: $M$,
  ),
)
