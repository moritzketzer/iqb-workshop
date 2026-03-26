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

  wnode((0, 0), [Drug],            name: <D>,  height: 1.4cm),
  wnode((1, 0), [Blood Pressure],  name: <BP>, height: 1.4cm),
  wnode((2, 0), [Recovery],        name: <R>,  height: 1.4cm),
  causal(<D>, <BP>),
  causal(<BP>, <R>),
  causal(<D.north>, <R.north>, bend: 40deg),
)
