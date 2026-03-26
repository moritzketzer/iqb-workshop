// Edge helpers for fletcher diagrams.
// `causal` draws solid directed arrowheads.
// `confound` draws solid bidirected arrowheads on dashed lines.
// `covariance-frame` draws a dashed path with solid arrows to multiple nodes,
//   representing an all-to-all covariance structure.

#import "@preview/fletcher:0.5.8" as fletcher

#let causal(..args) = fletcher.edge(..args, marks: (none, "solid"))
#let confound(..args) = fletcher.edge(..args, marks: ("solid", "solid"), "dashed")

/// Creates a covariance frame: a dashed path (rectangle or polygon) with
/// solid-tipped arrows emanating to target nodes.
///
/// - targets: Array of dictionaries, each with:
///   - `node`: The target node label, optionally with anchor (e.g., `<U_Y>` or `<U_Y.north>`)
///   - `from`: Coordinate tuple where the arrow originates on the frame
/// - path: Array of coordinate tuples defining the frame path. The path is
///   automatically closed (last point connects to first).
/// - top-left: Coordinate tuple for the top-left corner (alternative to path).
/// - bottom-right: Coordinate tuple for the bottom-right corner (alternative to path).
/// - stroke: Stroke style for the frame and arrows (default: inherits from diagram).
#let covariance-frame(
  targets: (),
  path: none,
  top-left: none,
  bottom-right: none,
  stroke: none,
) = {
  // Validate arguments: use path OR top-left/bottom-right, not both
  if path != none and (top-left != none or bottom-right != none) {
    panic("covariance-frame: use path or top-left/bottom-right, not both")
  }

  // Build path from corners if provided
  let frame-path = if path != none {
    path
  } else if top-left != none and bottom-right != none {
    let (x1, y1) = top-left
    let (x2, y2) = bottom-right
    // Rectangle: top-left -> top-right -> bottom-right -> bottom-left
    ((x1, y1), (x2, y1), (x2, y2), (x1, y2))
  } else {
    panic("covariance-frame: provide either path or both top-left and bottom-right")
  }

  assert(frame-path.len() >= 3, message: "covariance-frame: path needs at least 3 points")
  assert(targets.len() >= 1, message: "covariance-frame: need at least 1 target")

  // Build closed path: connect all points and return to start
  let closed-path = frame-path + (frame-path.at(0),)

  // Build array of edges: frame + arrows
  let edges = (
    if stroke != none {
      fletcher.edge(..closed-path, "dashed", stroke: stroke, snap-to: none)
    } else {
      fletcher.edge(..closed-path, "dashed", snap-to: none)
    },
  )

  for target in targets {
    let from-coord = target.at("from")
    let to = target.at("node")

    let arrow = if stroke != none {
      fletcher.edge(from-coord, to, "dashed", stroke: stroke, marks: (none, "solid"))
    } else {
      fletcher.edge(from-coord, to, "dashed", marks: (none, "solid"))
    }
    edges.push(arrow)
  }

  edges
}
