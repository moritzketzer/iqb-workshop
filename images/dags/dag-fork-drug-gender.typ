#import "@preview/fletcher:0.5.8" as fletcher: diagram, node
#import "_edge.typ": causal

#set page(width: auto, height: auto, margin: .5cm)
#set text(font: "Source Sans 3", size: 11pt)

#let wnode(pos, label, ..args) = node(
  pos, align(center, label),
  width: 2.8cm,
  corner-radius: 5pt,
  inset: 8pt,
  ..args,
)

#diagram(
  node-stroke: 0.8pt,
  edge-stroke: 0.7pt,
  spacing: (3cm, 2cm),

  wnode((1, 0), [Gender],    name: <G>),
  wnode((0, 1), [Drug],      name: <D>),
  wnode((2, 1), [Recovery],  name: <R>),
  causal(<G>, <D>),
  causal(<G>, <R>),
  causal(<D>, <R>),
)
