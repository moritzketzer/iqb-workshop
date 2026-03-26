// Panel label helper for fletcher diagrams.
// Renders a bold upright sans letter without affecting layout.

#import "@preview/fletcher:0.5.8" as fletcher: node

#let panel_label(panel, pos, size: 1.5em) = {
  assert(type(panel) == str, message: "panel_label: panel must be a string, e.g. \"A\".")
  node(
    name: label(panel + ":panel"),
    pos,
    $upright(bold(sans(#text(size)[#panel])))$,
    radius: 0pt,
    stroke: none,
  )
}
