#import "@preview/fletcher:0.5.8" as fletcher: diagram, node
#import "../images/dags/_edge.typ": causal

#let teal = rgb("#107895")
#set page(width: auto, height: auto, margin: .8cm)
#set text(font: "Source Sans 3", size: 16pt, fill: teal, weight: "semibold")

#let snode(pos, label, ..args) = node(
  pos, align(center + horizon, label),
  width: 2cm,
  corner-radius: 4pt,
  inset: 8pt,
  ..args,
)

#align(center, stack(dir: ttb, spacing: 14pt,
  text(size: 20pt, weight: "bold", fill: teal, [(3) Mediator]),
  diagram(
    node-stroke: 0.8pt, edge-stroke: 0.7pt,
    spacing: (1.5cm, 0cm),
    snode((0, 0), [X], name: <X>),
    snode((1, 0), [Z], name: <Z>),
    snode((2, 0), [Y], name: <Y>),
    causal(<X>, <Z>),
    causal(<Z>, <Y>),
  ),
))
