// Plate helper for fletcher diagrams
// Creates an enclosing box with a label, used for plate notation in graphical models.

#import "@preview/fletcher:0.5.8" as fletcher: node

// Alias Typst's built-in label() so we can still call it even if a function
// parameter is named `label`.
#let _mklabel = label

/// Creates a plate (enclosing box) for graphical model diagrams.
///
/// - name: String identifier for the plate (e.g., "plate:N"). Helper nodes
///   will be named `<name:tl>` and `<name:br>`.
/// - top-left: Coordinate tuple for the top-left corner.
/// - bottom-right: Coordinate tuple for the bottom-right corner.
/// - enclose: Array of node names/coords to enclose (alternative to corners).
/// - label: Content to display as the plate label (e.g., `$N$`).
/// - label-corner: Corner for the label ("bottom-right", "bottom-left",
///   "top-right", "top-left"). Default: "bottom-right".
/// - label-offset: Absolute offset distance for the label (default: 8pt).
///   The direction is determined automatically based on label-corner.
/// - stroke: Stroke style for the plate border (default: black + 0.5pt).
/// - corner-radius: Corner radius for the plate (default: 7pt).
#let plate(
  name: none,
  top-left: none,
  bottom-right: none,
  enclose: none,
  inset: 0pt,
  label: none,
  label-corner: "bottom-right",
  label-offset: 8pt,
  stroke: black + 0.5pt,
  corner-radius: 7pt,
) = {
  assert(name != none, message: "plate: name is required")

  if enclose != none and (top-left != none or bottom-right != none) {
    error("plate: use enclose or top-left/bottom-right, not both.")
  }

  // Determine alignment and offset direction based on label-corner.
  // Offsets always push the label inward (inside the plate).
  let label-content = if label != none {
    let (label-align, dx, dy) = if label-corner == "bottom-right" {
      (bottom + right, -label-offset, -label-offset)
    } else if label-corner == "bottom-left" {
      (bottom + left, label-offset, -label-offset)
    } else if label-corner == "top-right" {
      (top + right, -label-offset, label-offset)
    } else if label-corner == "top-left" {
      (top + left, label-offset, label-offset)
    } else {
      panic("plate: invalid label-corner '" + label-corner + "'. Use bottom-right, bottom-left, top-right, or top-left.")
    }
    align(label-align)[
      #move(dx: dx, dy: dy)[#label]
    ]
  }

  if enclose != none {
    return (
      node(
        name: _mklabel(name),
        enclose: enclose,
        stroke: stroke,
        corner-radius: corner-radius,
        inset: inset,
        snap: false,
        if label != none { label-content },
      ),
    )
  }

  assert(top-left != none, message: "plate: top-left is required")
  assert(bottom-right != none, message: "plate: bottom-right is required")

  let tl-name = name + ":tl"
  let br-name = name + ":br"

  (
    // Helper node: top-left corner
    node(name: _mklabel(tl-name), top-left, stroke: none, fill: none, snap: false),
    // Helper node: bottom-right corner
    node(name: _mklabel(br-name), bottom-right, stroke: none, fill: none, snap: false),
    // Enclosing plate box
    node(
      name: _mklabel(name),
      enclose: (_mklabel(tl-name), _mklabel(br-name)),
      stroke: stroke,
      corner-radius: corner-radius,
      inset: 0pt,
      snap: false,
      if label != none { label-content },
    ),
  )
}
