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
  text(size: 20pt, weight: "bold", fill: teal, [(4) M-bias]),
  diagram(
    node-stroke: 0.8pt, edge-stroke: 0.7pt,
    spacing: (1.2cm, 1cm),
    snode((0, 0), [U#sub[1]], name: <U1>),
    snode((2, 0), [U#sub[2]], name: <U2>),
    snode((1, 0), [Z], name: <Z>),
    snode((0, 1), [X], name: <X>),
    snode((2, 1), [Y], name: <Y>),
    causal(<U1>, <Z>),
    causal(<U2>, <Z>),
    causal(<U1>, <X>),
    causal(<U2>, <Y>),
    causal(<X>, <Y>),
  ),
))
