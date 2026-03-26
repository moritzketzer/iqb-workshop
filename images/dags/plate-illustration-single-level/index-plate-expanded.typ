#import "@preview/fletcher:0.5.8" as fletcher: diagram, node
#import "../_edge.typ": causal
#import "../_panel.typ": panel_label
#import "../_plate.typ": plate

#set page(width: auto, height: auto, margin: .5cm)

#let default-radius = 16pt
#let node = node.with(radius: default-radius)

#diagram(
  node-stroke: 1pt,
  edge-stroke: 0.7pt,

  panel_label("A", (1.2, 1.5)),
  panel_label("B", (3.2, 1.5)),
  panel_label("C", (6.2, 1.5)),

  node(name: <hidden>, (1, 2), stroke: none, fill: none),

  node(name: <A:X>, (2, 3.8), $X$, radius: 14pt),
  node(name: <A:Y>, (2, 2), $Y$, radius: 14pt),

  causal(<A:X>, <A:Y>),

  node(name: <B:X_i>, (4.5, 3.8), $X$, radius: 14pt),
  node(name: <B:Y_i>, (4.5, 2), $Y$, radius: 14pt),

  causal(<B:X_i>, <B:Y_i>),

  ..plate(
    name: "B:plate:N",
    top-left: (3.8, 1.4),
    bottom-right: (5.2, 4.5),
    inset: 20pt,
    label: $N$,
  ),

  node(name: <C:Y_1>, (7, 2), $Y_1$, radius: 14pt),
  node(name: <C:Y_2>, (8, 2), $Y_2$, radius: 14pt),
  node(name: <C:Y_dots>, (9, 2), $dots$, stroke: 0pt),
  node(name: <C:Y_N>, (10, 2), $Y_N$, radius: 14pt),

  node(name: <C:X_1>, (7, 3.8), $X_1$, radius: 14pt),
  node(name: <C:X_2>, (8, 3.8), $X_2$, radius: 14pt),
  node(name: <C:X_dots>, (9, 3.8), $dots$, stroke: 0pt),
  node(name: <C:X_N>, (10, 3.8), $X_N$, radius: 14pt),

  causal(<C:X_1>, <C:Y_1>),
  causal(<C:X_2>, <C:Y_2>),
  causal(<C:X_N>, <C:Y_N>),
)
