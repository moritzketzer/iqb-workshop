#import "@preview/fletcher:0.5.8" as fletcher: diagram, node
#import "_edge.typ": causal

#let teal = rgb("#107895")
#set page(width: auto, height: auto, margin: .5cm)
#set text(font: "Source Sans 3", size: 14pt, fill: teal, weight: "semibold")

#let wnode(pos, label, ..args) = node(
  pos, align(center + horizon, label),
  width: 3.2cm,
  corner-radius: 5pt,
  inset: 10pt,
  ..args,
)

#diagram(
  node-stroke: 0.8pt,
  edge-stroke: 0.7pt,
  spacing: (1.5cm, 1.2cm),

  wnode((1, 0), [Stone Size], name: <S>),
  wnode((0, 1), [Treatment],  name: <T>),
  wnode((2, 1), [Recovery],   name: <R>),
  causal(<S>, <T.north>),
  causal(<S>, <R.north>),
  causal(<T>, <R>),
)
