#import "@preview/fletcher:0.5.8" as fletcher: diagram, node
#import "_edge.typ": causal

#let teal = rgb("#107895")
#let muted = rgb("#506070")
#set page(width: auto, height: auto, margin: .8cm)
#set text(font: "Source Sans 3", size: 13pt, fill: teal, weight: "semibold")

#let snode(pos, label, ..args) = node(
  pos, align(center + horizon, label),
  width: 1.6cm,
  corner-radius: 4pt,
  inset: 6pt,
  ..args,
)

#let dag-block(title, body) = box(
  width: 8cm,
  align(center, stack(dir: ttb, spacing: 12pt,
    text(size: 16pt, weight: "bold", fill: teal, title),
    body,
  ))
)

#grid(
  columns: (8cm, 8cm),
  rows: (auto, auto),
  column-gutter: 1.5cm,
  row-gutter: 1.2cm,

  // (1) Collider: X → Z ← Y, X → Y
  dag-block[(1) Collider][#diagram(
    node-stroke: 0.8pt, edge-stroke: 0.7pt,
    spacing: (1.2cm, 1cm),
    snode((0, 0), [X], name: <c:X>),
    snode((1, 0), [Y], name: <c:Y>),
    snode((0.5, 1), [Z], name: <c:Z>),
    causal(<c:X>, <c:Y>),
    causal(<c:X>, <c:Z>),
    causal(<c:Y>, <c:Z>),
  )],

  // (2) Confounder: Z → X, Z → Y, X → Y
  dag-block[(2) Confounder][#diagram(
    node-stroke: 0.8pt, edge-stroke: 0.7pt,
    spacing: (1.2cm, 1cm),
    snode((0.5, 0), [Z], name: <f:Z>),
    snode((0, 1), [X], name: <f:X>),
    snode((1, 1), [Y], name: <f:Y>),
    causal(<f:Z>, <f:X>),
    causal(<f:Z>, <f:Y>),
    causal(<f:X>, <f:Y>),
  )],

  // (3) Mediator: X → Z → Y
  dag-block[(3) Mediator][#diagram(
    node-stroke: 0.8pt, edge-stroke: 0.7pt,
    spacing: (1.2cm, 0cm),
    snode((0, 0), [X], name: <m:X>),
    snode((1, 0), [Z], name: <m:Z>),
    snode((2, 0), [Y], name: <m:Y>),
    causal(<m:X>, <m:Z>),
    causal(<m:Z>, <m:Y>),
  )],

  // (4) M-bias: U1 → X, U1 → Z ← U2, U2 → Y, X → Y
  dag-block[(4) M-bias][#diagram(
    node-stroke: 0.8pt, edge-stroke: 0.7pt,
    spacing: (1cm, 0.8cm),
    snode((0, 0), [U#sub[1]], name: <b:U1>),
    snode((2, 0), [U#sub[2]], name: <b:U2>),
    snode((1, 0), [Z], name: <b:Z>),
    snode((0, 1), [X], name: <b:X>),
    snode((2, 1), [Y], name: <b:Y>),
    causal(<b:U1>, <b:Z>),
    causal(<b:U2>, <b:Z>),
    causal(<b:U1>, <b:X>),
    causal(<b:U2>, <b:Y>),
    causal(<b:X>, <b:Y>),
  )],
)
