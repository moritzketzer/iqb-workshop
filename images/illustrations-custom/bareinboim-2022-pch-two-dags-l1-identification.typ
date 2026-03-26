// Bareinboim (2022) PCH Fig. 27.4 — Two DAGs & L₁ identification
// Recreated in project style. Page: 36×24 cm (3:2 slide ratio).
// Fletcher (DAGs) + CeTZ (spatial diagram) hybrid composition.

#import "@preview/cetz:0.3.4"
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "@local/dag-helpers:0.1.0": causal, colors

#set page(width: 36cm, height: 24cm, margin: 1cm, fill: rgb("#FAFBFC"))
#set text(font: "Source Sans 3", fill: colors.ink)
#show math.equation: set text(font: "STIX Two Math")

// ════════════════════════════════════════════════════════════════════════════════
// Left panel: Two DAGs (Fletcher — invisible node strokes, proper edge clipping)
// ════════════════════════════════════════════════════════════════════════════════

#let dag-node = node.with(stroke: none, radius: 18pt)

#let left-panel = stack(dir: ttb, spacing: 1.2cm,
  // DAG G*: X → Z → Y
  stack(dir: ttb, spacing: 14pt,
    align(center, text(size: 23pt, fill: colors.primary)[$cal(G)^*$]),
    diagram(
      node-stroke: none,
      edge-stroke: 0.7pt + colors.ink,
      spacing: (1.2cm, 0cm),
      dag-node((0, 0), text(size: 26pt)[$X$], name: <a:X>),
      dag-node((1, 0), text(size: 26pt)[$Z$], name: <a:Z>),
      dag-node((2, 0), text(size: 26pt)[$Y$], name: <a:Y>),
      causal(<a:X>, <a:Z>, stroke: 1.2pt),
      causal(<a:Z>, <a:Y>, stroke: 1.2pt),
    ),
  ),
  // DAG G': X ← Z ← Y
  stack(dir: ttb, spacing: 14pt,
    align(center, text(size: 23pt, fill: colors.primary)[$cal(G)'$]),
    diagram(
      node-stroke: none,
      edge-stroke: 0.7pt + colors.ink,
      spacing: (1.2cm, 0cm),
      dag-node((0, 0), text(size: 26pt)[$X$], name: <b:X>),
      dag-node((1, 0), text(size: 26pt)[$Z$], name: <b:Z>),
      dag-node((2, 0), text(size: 26pt)[$Y$], name: <b:Y>),
      causal(<b:Z>, <b:X>, stroke: 1.2pt),
      causal(<b:Y>, <b:Z>, stroke: 1.2pt),
    ),
  ),
)

// ════════════════════════════════════════════════════════════════════════════════
// Right panel: Identification diagram (CeTZ — spatial-composition-dominant)
// Named elements + anchor-based connections instead of raw coordinates.
// ════════════════════════════════════════════════════════════════════════════════

#let right-panel = cetz.canvas(length: 1cm, {
  import cetz.draw: *

  set-style(mark: (fill: colors.ink, size: 0.4))

  let dotted = (paint: colors.muted, thickness: 0.8pt, dash: "dotted")

  // ── Background zones ──────────────────────────────────────────────────────

  // SCM dashed rectangle (compact — just wraps M*/M' and title)
  rect((2.5, 13), (11.5, 19.5),
    stroke: (paint: colors.ink, thickness: 1.2pt, dash: "dashed"),
    fill: colors.div-mid,
    name: "scm-zone")

  // Dashed separator (unobserved / observed boundary)
  line((-0.5, 10), (25, 10),
    stroke: (paint: colors.muted, thickness: 1.5pt, dash: "dashed"),
    name: "separator")

  // ── Large ellipses ────────────────────────────────────────────────────────

  // Bayesian Network ellipse
  circle((20, 16), radius: (4.5, 3.5),
    stroke: (paint: colors.ink, thickness: 1pt),
    fill: none,
    name: "bn-ellipse")

  // Observational ellipse (identical radius to interventional)
  circle((5, 5), radius: (5, 3),
    stroke: (paint: colors.ink, thickness: 1pt),
    fill: none,
    name: "obs-ellipse")

  // Interventional ellipse (identical radius to observational)
  circle((19, 5), radius: (5, 3),
    stroke: (paint: colors.ink, thickness: 1pt),
    fill: none,
    name: "int-ellipse")

  // ── Dotted sub-ellipses ───────────────────────────────────────────────────

  circle((19.5, 17), radius: (2.5, 1.2), stroke: dotted, name: "g-star-sub")
  circle((21, 14.5), radius: (2.5, 1.2), stroke: dotted, name: "g-prime-sub")
  circle((17.5, 6), radius: (2.5, 1.2), stroke: dotted, name: "p-star-sub")
  circle((20.5, 4), radius: (2.5, 1.2), stroke: dotted, name: "p-prime-sub")

  // ── Dots & arrows (Fletcher overlay — proper edge-to-node snapping) ───────
  // Coordinate mapping: Fletcher (x, y) → CeTZ (x, 21 - y)
  // Fletcher handles arrow-to-dot clipping automatically.

  content((0, 21), anchor: "north-west", diagram(
    spacing: (1cm, 1cm),
    node-stroke: none,
    edge-stroke: 0.7pt + colors.ink,

    // Invisible bounds nodes to fix coordinate alignment
    node((0, 0), [], stroke: none, fill: none, radius: 0.001cm),
    node((25, 22), [], stroke: none, fill: none, radius: 0.001cm),

    // M* and M' inside SCM zone           — CeTZ (4, 16.5) and (10, 16.5)
    node((5.5, 5.5), [], radius: 0.18cm, fill: colors.ink, name: <M-star>),
    node((8, 5.5), [], radius: 0.18cm, fill: colors.ink, name: <M-prime>),

    // G* and G' at BN sub-ellipse centers  — CeTZ (19.5, 17) and (21, 14.5)
    node((18, 4), [], radius: 0.18cm, fill: colors.ink, name: <G-star>),
    node((19, 6), [], radius: 0.18cm, fill: colors.ink, name: <G-prime>),

    // obs-dot inside observational ellipse — CeTZ (5, 6.2)
    node((5, 13.8), [], radius: 0.18cm, fill: colors.ink, name: <obs>),

    // P* and P' inside interventional      — CeTZ (17, 6.5) and (20.5, 4.5)
    node((16.4, 13.2), [], radius: 0.18cm, fill: colors.ink, name: <P-star>),
    node((19.2, 14.7), [], radius: 0.18cm, fill: colors.ink, name: <P-prime>),

    // Arrows (Fletcher auto-clips at node boundaries)
    causal(<M-star>, <obs>, stroke: 1.2pt),
    causal(<M-prime>, <obs>, stroke: 1.2pt),
    causal(<M-star>, <G-star>, bend: 25deg, stroke: 1.2pt),
    causal(<M-prime>, <G-prime>, bend: 10deg, stroke: 1.2pt),
    causal(<M-star>, <P-star>, stroke: 1.2pt),
    causal(<M-prime>, <P-prime>, bend: 25deg, stroke: 1.2pt),
  ))

  // "?" arrow: Observational → Interventional
  line((10, 0.5), (14, 0.5), mark: (end: ">"))
  content((12, 1.5), text(size: 22pt, weight: "bold")[?])

  // ── Text labels ───────────────────────────────────────────────────────────

  // SCM title (positioned inside the smaller zone)
  content((7, 18.7), text(size: 18pt, weight: "bold")[Structural Causal Models])
  content((7, 17.8), text(size: 16pt, fill: colors.muted)[(Unobserved)])

  // M* and M' labels (above dots)
  content((5, 15.3), text(size: 23pt)[$cal(M)^*$])
  content((8, 15.3), text(size: 23pt)[$cal(M)'$])

  // Bayesian Network label
  content((20, 20), text(size: 16pt, weight: "semibold")[Bayesian Network])

  // G* and G' labels (offset right of dots so text doesn't overlap)
  content((20.2, 17), text(size: 23pt)[$cal(G)^*$])
  content((21.5, 14.5), text(size: 23pt)[$cal(G)'$])

  // Observational ellipse content
  content("obs-ellipse.center", text(size: 18pt)[$P^*(bold(V)) = P'(bold(V))$])

  // Interventional sub-ellipse labels
  content("p-star-sub.center", text(size: 18pt)[$P^*(bold(Y) | "do"(bold(x)))$])
  content("p-prime-sub.center", text(size: 18pt)[$P'(bold(Y) | "do"(bold(x)))$])

  // Observational label stack: L₁ to the left of centered vertical text
  content((5, 0.5), stack(dir: ltr, spacing: 10pt,
    align(horizon, text(size: 22pt, fill: colors.primary, weight: "bold")[$cal(L)_1$]),
    align(center, stack(dir: ttb, spacing: 4pt,
      text(size: 16pt)[Observational],
      text(size: 16pt)[Distributions],
      text(size: 16pt, weight: "bold")[Data],
    )),
  ))

  // Interventional label stack: L₂ to the left of centered vertical text
  content((19, 0.5), stack(dir: ltr, spacing: 10pt,
    align(horizon, text(size: 22pt, fill: colors.primary, weight: "bold")[$cal(L)_2$]),
    align(center, stack(dir: ttb, spacing: 4pt,
      text(size: 16pt)[Interventional],
      text(size: 16pt)[Distributions],
      text(size: 16pt, weight: "bold")[Query],
    )),
  ))
})

// ════════════════════════════════════════════════════════════════════════════════
// Compose panels
// ════════════════════════════════════════════════════════════════════════════════

#align(center + horizon,
  stack(dir: ltr, spacing: 1.5cm,
    align(horizon, box(width: 6cm, left-panel)),
    align(horizon, right-panel),
  )
)
